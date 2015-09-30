/*-----------------------------------------------------------------------*
 * filename - __open.c
 *
 * function(s)
 *        __open       - opens a file for reading or writing
 *-----------------------------------------------------------------------*/

/*
 *      C/C++ Run Time Library - Version 23.0
 *
 *      Copyright (c) 1991, 2015 by Embarcadero Technologies, Inc.
 *      All Rights Reserved.
 *
 */

/* $Revision: 25423 $        */

#define INCL_ERROR_H

#include <ntbc.h>

#include <_io.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <_tchar.h>

extern  unsigned      _notUmask;

/*-----------------------------------------------------------------------*

Name            ___topen used as __open and __wopen
                __open  - opens a file for reading or writing
                __wopen - opens a file for reading or writing

Usage           #include <fcntl.h>
                #include<sys\stat.h>
                int __open(const char *pathname, int access [,unsigned permiss]);
                int __wopen(const wchar_t *pathname, int access [,unsigned permiss]);

Prototype in    _io.h

Description     ___topen opens the file specified by pathname, then
                prepares it for reading and/or writing as determined by
                the value of access.

                For ___topen, access is constructed by bitwise ORing flags
                from the following two lists. Only one flag from the first
                list may be used; the remaining flags may be used in any
                logical combination.

                List 1: Read/Write flags

                O_RDONLY        Open for reading only.
                O_WRONLY        Open for writing only.
                O_RDWR          Open for reading and writing.


                List 2: Other access flags

                O_APPEND        If set, the file pointer will be set
                                to the end of the file prior to each
                                write.
                O_CREAT         If the file exists, this flag has no effect.
                                If the file does not exist, the file is
                                created, and the bits of permiss are used
                                to set the file attribute bits, as in chmod.
                O_TRUNC         If the file exists, its length is truncated
                                to 0.
                                The file attributes remain unchanged.
                O_EXCL          Used only with O_CREAT. If the file already
                                exists, an error is returned.
                O_BINARY        This flag can be given to explicitly open
                                the file in binary mode.
                O_TEXT          This flag can be given to explicitly open
                                the file in text mode.

                These O_... symbolic constants are defined in fcntl.h.

                If neither O_BINARY nor O_TEXT is given, the file is
                opened in the translation mode set by the global variable
                _fmode.

                If the O_CREAT flag is used in constructing access, you need
                to supply the permiss argument to __open, from the following
                symbolic constants defined in sys\stat.h.

                Value of permiss        Access Permission

                S_IWRITE                Permission to write
                S_IREAD                 Permission to read
                S_IREAD|S_IWRITE        Permission to read and write

                The created file's read/write permission will be have bits
                cleared where the corresponding bits are set by umask().

                For _rtl_open, the value of access is limited to
                O_RDONLY, O_WRONLY, and O_RDWR.  The following
                additional values can also be used:

                O_NOINHERIT     Included if the file is not to be passed to
                                child programs.
                O_DENYALL       Allows only the current handle to have access to
                                the file.
                O_DENYWRITE     Allows only reads from any other open to the
                                file.
                O_DENYREAD      Allows only writes from any other open to the
                                file.
                O_DENYNONE      Allows other shared opens to the file.

                Only one of the O_DENYxxx values may be included in a single
                _rtl_open. These file-sharing attributes are in
                addition to any locking performed on the files.

                The maximum number of simultaneously open files is a system
                configuration parameter.

Return value    On successful completion, ___topen returns a non-negative
                integer (the file handle), and the file pointer
                (that marks the current position in the file) is set to the
                beginning of the file. On error, it returns -1 and errno is
                set to one of the following:

                        ENOENT  Path or file name not found
                        EMFILE  Too many open files
                        EACCES  Permission denied
                        EINVACC Invalid access code

*------------------------------------------------------------------------*/

int _RTLENTRY _EXPFUNC ___topen(const _TCHAR *pathP, int oflag, ...)

/*
  Open a new file or replace an existing file with the given pathname.
*/
{
    DWORD   access;             /* read/write access */
    DWORD   sharemode;          /* sharing mode */
    DWORD   disp;               /* creation disposition */
    DWORD   attr;               /* flags and attributes */
    SECURITY_ATTRIBUTES sec;    /* used only to set inheritance flag */
    HANDLE  handle;
    int     rc;

    _lock_all_handles();

    /* Get the default translation mode from _fmode if not specified
     * by oflag.  Then, If O_BINARY is not specified, set O_TEXT
     * so that the flags will be non-zero when stored in _openfd[].
     */
    if ((oflag & (O_TEXT | O_BINARY)) == 0)
        oflag |= _FMODE & (O_TEXT | O_BINARY);
    if ((oflag & O_BINARY) == 0)
        oflag |= O_TEXT;

    /* Map the POSIX O_CREATE, O_EXCL, and O_TRUNC flags to
     * NT's CreateFile dwCreateDisposition parameter:
     *
     * POSIX                NT
     * =====                ====
     * O_CREAT              OPEN_ALWAYS
     * O_CREAT | O_EXCL     CREATE_NEW
     * O_CREAT | O_TRUNC    CREATE_ALWAYS
     * O_TRUNC              TRUNCATE_EXISTING
     * <none>               OPEN_EXISTING
     */
    switch (oflag & (O_CREAT | O_EXCL | O_TRUNC))
    {
    case O_CREAT | O_EXCL:
    case O_CREAT | O_EXCL | O_TRUNC:
        disp = CREATE_NEW;
        break;
    case O_CREAT | O_TRUNC:
        disp = CREATE_ALWAYS;
        break;
    case O_CREAT:
        disp = OPEN_ALWAYS;
        break;
    case O_TRUNC:
    case O_TRUNC | O_EXCL:
        disp = TRUNCATE_EXISTING;
        break;
    default:
        disp = OPEN_EXISTING;
        break;
    }

    /* If file is being created, convert the file attributes to
     * the NT attributes.
     */
    if (oflag & O_CREAT)
    {
        va_list  ap;
        unsigned mode;

        /* Fetch the mode (optional third argument)
         */
        va_start(ap, oflag);
        mode = va_arg(ap,unsigned);
        va_end(ap);

        /* Set the file attributes to normal or read-only.
         */
        mode &= _notUmask;
        if (mode & S_IWRITE)
            attr = FILE_ATTRIBUTE_NORMAL;
        else
            attr = FILE_ATTRIBUTE_READONLY;
    }
    else
    {
        /* Get current attributes of existing file.
         */
        if ((attr = GetFileAttributes((_TCHAR *)pathP)) == (DWORD)-1)
            attr = 0;
    }

    /* Map the access bits to the NT access mode.
     */
    switch (oflag & O_ACCMODE)
    {
    case O_RDONLY:
        access = GENERIC_READ;
        break;
    case O_WRONLY:
        access = GENERIC_WRITE;
        break;
    case O_RDWR:
        access = GENERIC_READ | GENERIC_WRITE;
        break;
    default:
        RETURN (__IOerror(ERROR_INVALID_FUNCTION));
    }

    /* Map the sharing bits to the NT sharing mode.
     */
    switch (oflag & _O_SHAREMODE)   /* sharing mode is in bits 3-6 */
    {
    case O_DENYALL:
        sharemode = 0;
        break;
    case O_DENYWRITE:
        sharemode = FILE_SHARE_READ;
        break;
    case O_DENYREAD:
        sharemode = FILE_SHARE_WRITE;
        break;
    default:
    case O_DENYNONE:
        sharemode = FILE_SHARE_READ | FILE_SHARE_WRITE;
        break;
    }

    if (oflag & _O_SECURE)
    {
	/* Don't allow access unless file is opened read-only */
	if (access == GENERIC_READ)
	    sharemode = FILE_SHARE_READ;
	else
	    sharemode = 0;
    }

    /* Set the inheritance flag in the security attributes.
     */
    sec.nLength = sizeof(sec);
    sec.lpSecurityDescriptor = NULL;
    sec.bInheritHandle = !(oflag & O_NOINHERIT);

    /* At last, we can open the file.
     */
    if ((handle = CreateFile((_TCHAR *)pathP, access, sharemode, &sec, disp,
                          attr, NULL)) == (HANDLE)-1)
    {
        DWORD err;

        if ((err = GetLastError() & 0xffffL) == ERROR_OPEN_FAILED)
            err = (oflag & O_CREAT) ? ERROR_FILE_EXISTS :
                                      ERROR_FILE_NOT_FOUND;
        RETURN (__IOerror((int)err));
    }

    /* Save the open flags and find free file handle table slot.
     * Save the NT file handle in the table, return the table index.
     */
    if (__isatty_osfhandle((long)handle))
        oflag |= O_DEVICE;
    if ((attr & FILE_ATTRIBUTE_READONLY) == 0)
        oflag |= _O_WRITABLE;       /* fstat() uses this bit */
    oflag &= ~_O_RUNFLAGS;          /* clear bits used only at open time */

    if ((rc = _get_handle((long)handle, oflag)) == -1)
    {
        __IOerror(ERROR_TOO_MANY_OPEN_FILES);
        CloseHandle(handle);
    }

exit:
    _unlock_all_handles();

    return rc;

}
