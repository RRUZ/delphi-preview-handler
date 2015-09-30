/********************************************************
*                                                       *
*                Delphi Runtime Library                 *
*                                                       *
* Copyright(c) 1995-2015 Embarcadero Technologies, Inc. *
*                                                       *
*   Copyright and license exceptions noted in source    *
*                                                       *
********************************************************/

#ifdef _UNIX
#include <stdlib.h>
#include <string.h>
#include <signal.h>

void ThrowError(int iError)
{
   raise(iError);
}
#include <errno.h>
#include <pthread.h>
#else
#include <windows.h>
#include <string.h>
#include <wtypes.h>
#include <initguid.h>
#include <olectl.h>
#include <stdarg.h>
#include <stdio.h>

#define __attribute__(x)

#endif  // #ifdef _UNIX

// NOTE: these must come before alctypes.h, otherwise linker will complain about GUID-definitions

#pragma hdrstop
#include "alchemy.h"
#include "dspickle.h"

#if defined(__ANDROID__)
#include <dlfcn.h>
#endif

#if defined(__arm__) || defined(__arm64__)
void* WEAKATTR operator new(size_t size)
{
    return ::malloc(size);
}

void* WEAKATTR operator new[](size_t size)
{
    return ::malloc(size);
}
#endif

#ifdef _UNIX
#define STDAPI extern "C" HRESULT EXPORTS DBIFN
#if defined(__arm__) || defined(__arm64__)
#define CDECLAPI extern "C" HRESULT
#else
#define CDECLAPI extern "C" HRESULT EXPORTS __attribute__ ((__cdecl__))
#endif
#else
#define CDECLAPI STDAPI
#endif

#ifndef _UNIX
HRESULT CreateRegKey(pCHAR pKey, pCHAR pValueName, pCCHAR pValue);
HRESULT DeleteRegKey(pCHAR pKey);
HRESULT Register_IF(pCHAR pszDllPath, pCCHAR pszPROGID, pCCHAR pszPROGID_DESC, pCCHAR pszPROGID_CURVER,
   pCCHAR pszPROGID_VERINDEP, REFGUID pClsId, BOOL bReg);
#endif   // #ifndef _UNIX

INT32 iObjCount = 0;
INT32 iLckCount = 0;

#if defined(__ANDROID__)
pVOID WEAKATTR HICUUC = NULL;

typedef pCHAR (*tu_strToUTF8)(pCHAR,
               INT32,
               INT32 *,
               const UChar *,
               INT32,
               UErrorCode *);

typedef UChar* (*tu_strFromUTF8)(UChar *,
                INT32,
                INT32 *,
                pCCHAR,
                INT32,
                UErrorCode *);

typedef UConverter* (*tucnv_open)(pCCHAR, UErrorCode *);

typedef void (*tucnv_close)(UConverter *);

typedef INT32 (*tucnv_toUChars)(UConverter *,
               UChar *, INT32,
               pCCHAR, INT32,
               UErrorCode *);

typedef INT32 (*tucnv_fromUChars)(UConverter *,
               pCHAR, INT32,
               const UChar *, INT32,
               UErrorCode *);

typedef pCCHAR (*tucnv_getDefaultName)(void);

tu_strToUTF8 WEAKATTR pu_strToUTF8;
tu_strFromUTF8 WEAKATTR pu_strFromUTF8;
tucnv_open WEAKATTR pucnv_open;
tucnv_close WEAKATTR pucnv_close;
tucnv_toUChars WEAKATTR pucnv_toUChars;
tucnv_fromUChars WEAKATTR pucnv_fromUChars;
tucnv_getDefaultName WEAKATTR pucnv_getDefaultName;

//Replicating InitICU in ICU.inc
INT32 InitICUMidas()
{
  INT32 res = 1;
  if (!HICUUC)
  {
    HICUUC = dlopen( "/system/lib/libicuuc.so", RTLD_LAZY);
    if (HICUUC)
    {
      int i = 0;
      pCHAR CStr = (pCHAR)malloc(256);
      pCHAR Mangle = (pCHAR)malloc(5);
      sprintf(CStr, "u_strToUTF8");
      sprintf(Mangle, "");
      if (!dlsym(HICUUC, CStr))
      {
        for (i = 40; i < 100; i++)
        {
          pCHAR Version = (pCHAR)malloc(3);
          sprintf(Version, "%d", i);
          sprintf(Mangle, "_%s", Version);
          sprintf(CStr, "u_strToUTF8%s", Mangle);
          if (!dlsym(HICUUC, CStr))
          {
            sprintf(Mangle, "_%c_%c", Version[0], Version[1]);
            sprintf(CStr, "u_strToUTF8%s", Mangle);
            if (dlsym(HICUUC, CStr))
            {
              res = 0;
              break;
            }
          }
          else
          {
            res = 0;
            break;
          }
        }
      }
      else
        res = 0;

      if (res == 0)
      {
        pu_strToUTF8 = reinterpret_cast<tu_strToUTF8>(dlsym(HICUUC,CStr));
        sprintf(CStr, "u_strFromUTF8%s", Mangle);
        pu_strFromUTF8       = reinterpret_cast<tu_strFromUTF8>(dlsym(HICUUC,CStr));
        sprintf(CStr, "ucnv_open%s", Mangle);
        pucnv_open           = reinterpret_cast<tucnv_open>(dlsym(HICUUC,CStr));
        sprintf(CStr, "ucnv_close%s", Mangle);
        pucnv_close          = reinterpret_cast<tucnv_close>(dlsym(HICUUC,CStr));
        sprintf(CStr, "ucnv_toUChars%s", Mangle);
        pucnv_toUChars       = reinterpret_cast<tucnv_toUChars>(dlsym(HICUUC,CStr));
        sprintf(CStr, "ucnv_fromUChars%s", Mangle);
        pucnv_fromUChars     = reinterpret_cast<tucnv_fromUChars>(dlsym(HICUUC,CStr));
        sprintf(CStr, "ucnv_getDefaultName%s", Mangle);
        pucnv_getDefaultName = reinterpret_cast<tucnv_getDefaultName>(dlsym(HICUUC,CStr));

        if (
         ( !pu_strToUTF8    ) ||
         ( !pu_strFromUTF8  ) ||
         ( !pucnv_open    ) ||
         ( !pucnv_close  ) ||
         ( !pucnv_toUChars    ) ||
         ( !pucnv_fromUChars  ) ||
         ( !pucnv_getDefaultName  ))
          res = 1;
      }
      free(Mangle);
      free(CStr);
    }
    else
      res = 1;
  }
  else
    res = 0;
  return res;
}
#endif

class DS_Factory : public IClassFactory
{
public:
   UINT32 iRefCount;

   DS_Factory();
   ~DS_Factory();

   HRESULT DBIFN QueryInterface( // Dummy
      REFIID riid, void** ppv) = 0;

#if defined(_Windows)
   ULONG DBIFN AddRef( // Increase reference count
      VOID);

   ULONG DBIFN Release( // Decrease reference count
      VOID);
#else
   INT32 DBIFN AddRef( // Increase reference count
      VOID);

   INT32 DBIFN Release( // Decrease reference count
      VOID);
#endif
   HRESULT DBIFN CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj) = 0;
   HRESULT DBIFN LockServer(BOOL bLock);

} COMINTF;

// DSBASE
class DSBASE_Factory : DS_Factory
{

public:

   HRESULT DBIFN QueryInterface(REFIID riid, void** ppv);

   HRESULT DBIFN CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj);

} COMINTF;

// DSCursor
class DSCursor_Factory : DS_Factory
{

public:
   HRESULT DBIFN QueryInterface(REFIID riid, void** ppv);

   HRESULT DBIFN CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj);

} COMINTF;

// DATAPACKETREAD
class DATAPACKETREAD_Factory : DS_Factory
{

public:

   HRESULT DBIFN QueryInterface(REFIID riid, void** ppv);

   HRESULT DBIFN CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj);

} COMINTF;

// DATAPACKETWRITE
class DATAPACKETWRITE_Factory : DS_Factory
{

public:

   HRESULT DBIFN QueryInterface(REFIID riid, void** ppv);

   HRESULT DBIFN CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj);

} COMINTF;

#if defined(_WIN64) && defined(__BORLANDC__)
EXPORTS CDECLAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, pVOID *ppv)
#else
CDECLAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, pVOID *ppv)
#endif
{
   HRESULT rslt = 0;
   DS_Factory *ppvObj = NULL;

   if (ppv == NULL)
      return E_INVALIDARG;

#ifdef MIDAS_DLL
   if (IsEqualCLSID(rclsid, CLSID_MDSBASE_1))
   {
      ppvObj = (DS_Factory*)new DSBASE_Factory();
   }
   else if (IsEqualCLSID(rclsid, CLSID_MDSCURSOR_1))
   {
      ppvObj = (DS_Factory*)new DSCursor_Factory();
   }
   else if (IsEqualCLSID(rclsid, CLSID_MDATAPACKETREAD))
   {
      ppvObj = (DS_Factory*)new DATAPACKETREAD_Factory();
   }
   else if (IsEqualCLSID(rclsid, CLSID_MDATAPACKETWRITE))
   {
      ppvObj = (DS_Factory*)new DATAPACKETWRITE_Factory();
   }
#else
   if (IsEqualCLSID(rclsid, CLSID_DSBASE_1 /* *pClsId */ ) || IsEqualCLSID(rclsid, CLSID_DSBASE_2))
   {
      ppvObj = (DS_Factory*)new DSBASE_Factory();
   }
   else if (IsEqualCLSID(rclsid, CLSID_DSCURSOR_1) || IsEqualCLSID(rclsid, CLSID_DSCURSOR_2))
   {
      ppvObj = (DS_Factory*)new DSCursor_Factory();
   }
   else if (IsEqualCLSID(rclsid, CLSID_DATAPACKETREAD))
   {
      ppvObj = (DS_Factory*)new DATAPACKETREAD_Factory();
   }
   else if (IsEqualCLSID(rclsid, CLSID_DATAPACKETWRITE))
   {
      ppvObj = (DS_Factory*)new DATAPACKETWRITE_Factory();
   }
#endif
   else
   {
      rslt = CLASS_E_CLASSNOTAVAILABLE;
      goto Exit;
   }
   if (ppvObj == NULL)
   {
      rslt = E_OUTOFMEMORY;
      goto Exit;
   }
   rslt = ppvObj->QueryInterface(riid, ppv);
   if (rslt)
      delete ppvObj;
Exit:
   return rslt;
}

extern "C" HRESULT EXPORTS DBIFN DllGetDataSnapClassObject(REFCLSID rclsid, REFIID riid, pVOID *ppv)
{
#if defined(__ANDROID__)
   if (InitICUMidas())
     return E_UNABLETOLOADICU;
   else
#endif
     return DllGetClassObject(rclsid, riid, ppv);
}

#if defined(_WIN64) && defined(__BORLANDC__)
EXPORTS STDAPI DllCanUnloadNow(VOID)
#else
STDAPI DllCanUnloadNow(VOID)
#endif
{
   return(iObjCount == 0 && iLckCount == 0) ? S_OK : S_FALSE;
}

// ----------------------------------------------------------------------------

HRESULT DBIFN DSBASE_Factory::QueryInterface(REFIID riid, void** ppv)
{
   HRESULT rslt = 0;
#if defined(__GNUC__) && defined(_Windows)
   IID local_riid = riid;

   if (ppv == NULL)
      return E_INVALIDARG;
   *ppv = NULL;

   UNREFERENCED_PARAMETER(local_riid);
#else
   if (ppv == NULL)
      return E_INVALIDARG;
   *ppv = NULL;

   UNREFERENCED_PARAMETER(riid);
#endif
   if (!IsEqualCLSID(riid, IID_IUnknown) && !IsEqualCLSID(riid, IID_IClassFactory))
   {
      rslt = CLASS_E_CLASSNOTAVAILABLE;
   }
   else
   {
      *ppv = (pVOID)this;
      AddRef();
   }
   return rslt;
}

HRESULT DBIFN DSBASE_Factory::CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj)
{
   HRESULT rslt = 0;
   DSBASE *pDs;

   if (ppvObj == NULL)
   {
      rslt = E_INVALIDARG;
      goto Exit;
   }
   *ppvObj = NULL;
#ifdef _UNIX
   if (pUnkOuter != NULL && (!(IsEqualCLSID(riid, IID_IUnknown))))
#else
      if (pUnkOuter != NULL && riid != IID_IUnknown)
#endif
      {
         rslt = CLASS_E_NOAGGREGATION;
         goto Exit;
      }
   pDs = new DSBASE();
   if (pDs == NULL)
   {
      rslt = E_OUTOFMEMORY;
      goto Exit;
   }
   rslt = pDs->QueryInterface(riid, ppvObj); // Increment refcount
   if (rslt)
      delete pDs;
Exit:
   return rslt;
}

HRESULT DBIFN DSCursor_Factory::QueryInterface(REFIID riid, void** ppv)
{
   HRESULT rslt = 0;

   if (ppv == NULL)
      return E_INVALIDARG;
   *ppv = NULL;

   if (!IsEqualCLSID(riid, IID_IUnknown) && !IsEqualCLSID(riid, IID_IClassFactory))
   {
      rslt = CLASS_E_CLASSNOTAVAILABLE;
   }
   else
   {
      *ppv = (pVOID)this;
      AddRef();
   }
   return rslt;
}

HRESULT DBIFN DSCursor_Factory::CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj)
{
   HRESULT rslt = 0;
   DSCursor *pDsCur;

   if (ppvObj == NULL)
   {
      rslt = E_INVALIDARG;
      goto Exit;
   }
   *ppvObj = NULL;
#ifdef _UNIX
   if ((pUnkOuter != NULL) && (!(IsEqualCLSID(riid, IID_IUnknown))))
#else
      if (pUnkOuter != NULL && riid != IID_IUnknown)
#endif
      {
         rslt = CLASS_E_NOAGGREGATION;
         goto Exit;
      }
   pDsCur = new DSCursor();
   if (pDsCur == NULL)
   {
      rslt = E_OUTOFMEMORY;
      goto Exit;
   }
   rslt = pDsCur->QueryInterface(riid, ppvObj); // Increment ref. to classfactory
   if (rslt)
      delete pDsCur;
Exit:
   return rslt;
}

DBIResult EXPORTS DBIFN InitAlchemy(class TAlchemy **ppAlc)
{
   *ppAlc = new TAlchemy;
   return DBIERR_NONE;
}

DBIResult EXPORTS DBIFN ExitAlchemy(class TAlchemy **ppAlc)
{
   TAlchemy *pTmp = *ppAlc;

   if (pTmp != NULL)
      delete pTmp;
   *ppAlc = NULL;
   return DBIERR_NONE;
}

DBIResult DBIFN TAlchemy::MakeDS(class TDSBASE **ppDs)
{
   DBIResult rslt = DBIERR_NONE;
   DSBASE * pDs = new DSBASE();

   if (!pDs)
   {
      rslt = DBIERR_NOMEMORY;
   }
   *ppDs = (TDSBASE*)pDs;
   return rslt;
}

DBIResult DBIFN TAlchemy::MakeCursor(TDSBASE *pDs, TDSCursor **ppCur)
{
   DBIResult rslt = DBIERR_NONE;
   DSCursor *pCur;

   pCur = new DSCursor();
   if (!pCur)
   {
      rslt = DBIERR_NOMEMORY;
   }
   else
      rslt = pCur->InitCursor((pVOID)pDs);
   *ppCur = (TDSCursor*)pCur;
   return rslt;
}

// Standard methods for DS_Factory

DS_Factory::DS_Factory()
{
   iRefCount = 0;
}

DS_Factory::~DS_Factory()
{
   return;
}

#if defined(_Windows)
ULONG DBIFN DS_Factory::AddRef( // Increase reference count
   VOID)
#else
INT32 DBIFN DS_Factory::AddRef( // Increase reference count
   VOID)
#endif
{
   return++iRefCount;
}

#if defined(_Windows)
ULONG DBIFN DS_Factory::Release( // Decrease reference count
   VOID)
#else
INT32 DBIFN DS_Factory::Release( // Decrease reference count
   VOID)
#endif
{
   UINT32 iRefSave;

   if (iRefCount > 0)
      iRefSave = --iRefCount;
   else
      iRefSave = 0;
   if (iRefCount == 0)
      delete this;
   return iRefSave;
}

HRESULT DBIFN DS_Factory::LockServer(BOOL bLock)
{
   if (bLock)
   {
      iLckCount++;
   }
   {
      if (iLckCount > 0)
         iLckCount--;
      // else ASSERT()
   }return 0;
}
// ----------------------------------------------------------------------------------

static void regError(const char* format, ...)
{
#if defined(DEBUG_REG)
   char msg[0x200];
   int rc;
   va_list paramList;

   va_start(paramList, format);
   rc = vsnprintf(msg, sizeof(msg)/sizeof(msg[0]), format, paramList);
   va_end(paramList);
   ::MessageBox(0, DBCLIENT_DLL, msg, MB_OK);
#else
   UNREFERENCED_PARAMETER(format);
#endif
}

#ifdef MIDAS_DLL
#define DBCLIENT_DLL "MIDAS.DLL"
#else
#define DBCLIENT_DLL "DBCLIENT.DLL"
#endif

#if defined(_Windows)

#if defined(_WIN64) && defined(__BORLANDC__)
EXPORTS STDAPI DllRegisterServer(VOID)
#else
STDAPI DllRegisterServer(VOID)
#endif
{
   DBIPATH pszDllPath =
   {
      0
   };
   OLECHAR pszDllPathw[DBIMAXPATHLEN+1] =
   {
      0
   };
   HINSTANCE hInst;
   HRESULT rslt = SELFREG_E_CLASS;

   hInst = GetModuleHandle(DBCLIENT_DLL);
   if (hInst)
   {
      ITypeLib *pTypeLib = 0;

      DWORD dw = GetModuleFileName(hInst, pszDllPath, sizeof(pszDllPath)/sizeof(pszDllPath[0]));
      if (dw < 1)
      {
         regError("ERROR: Unable to retrieve module file name");
      }

      MultiByteToWideChar(0, 0, pszDllPath, -1, pszDllPathw, sizeof(pszDllPathw)/sizeof(pszDllPathw[0]));

      rslt = LoadTypeLib(pszDllPathw, &pTypeLib);
      if (!rslt)
      {
         HRESULT hr = RegisterTypeLib(pTypeLib, pszDllPathw, NULL);
         if (hr != S_OK)
         {
            regError("ERROR: RegisterTypeLib returned %lX", hr);
         }
         pTypeLib->Release();
         pTypeLib = 0;
      }
      else
      {
         regError("ERROR: LoadTypeLib returned %lX", rslt);
      }

#ifdef MIDAS_DLL
      // DSBASE
      rslt = Register_IF(pszDllPath, PROGID_MDSBASE, PROGID_MDSBASE_DESC, PROGID_MDSBASE_1, NULL, CLSID_MDSBASE_1,
         TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_MDSBASE_1, PROGID_MDSBASE_DESC_1, NULL, PROGID_MDSBASE, CLSID_MDSBASE_1,
         TRUE);
      // DSCursor
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_MDSCURSOR, PROGID_MDSCURSOR_DESC, PROGID_MDSCURSOR_1, NULL,
         CLSID_MDSCURSOR_1, TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_MDSCURSOR_1, PROGID_MDSCURSOR_DESC_1, NULL, PROGID_MDSCURSOR,
         CLSID_MDSCURSOR_1, TRUE);
      // DSDATAPACKET
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_MDATAPACKETREAD, PROGID_MDATAPACKETREAD_DESC, NULL, NULL,
         CLSID_MDATAPACKETREAD, TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_MDATAPACKETWRITE, PROGID_MDATAPACKETWRITE_DESC, NULL, NULL,
         CLSID_MDATAPACKETWRITE, TRUE);
#else
      // DSBASE
      rslt = Register_IF(pszDllPath, PROGID_DSBASE, PROGID_DSBASE_DESC, PROGID_DSBASE_2, NULL, CLSID_DSBASE_2, TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_DSBASE_1, PROGID_DSBASE_DESC_1, NULL, NULL, CLSID_DSBASE_1, TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_DSBASE_2, PROGID_DSBASE_DESC_2, NULL, PROGID_DSBASE, CLSID_DSBASE_2,
         TRUE);

      // DSCursor
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_DSCURSOR, PROGID_DSCURSOR_DESC, PROGID_DSCURSOR_2, NULL,
         CLSID_DSCURSOR_2, TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_DSCURSOR_1, PROGID_DSCURSOR_DESC_1, NULL, NULL, CLSID_DSCURSOR_1, TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_DSCURSOR_2, PROGID_DSCURSOR_DESC_2, NULL, PROGID_DSCURSOR,
         CLSID_DSCURSOR_2, TRUE);
      // DSDATAPACKET
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_DATAPACKETREAD, PROGID_DATAPACKETREAD_DESC, NULL, NULL,
         CLSID_DATAPACKETREAD, TRUE);
      if (!rslt)
         rslt = Register_IF(pszDllPath, PROGID_DATAPACKETWRITE, PROGID_DATAPACKETWRITE_DESC, NULL, NULL,
         CLSID_DATAPACKETWRITE, TRUE);
#endif
   }
   return rslt;
}

#if defined(_WIN64) && defined(__BORLANDC__)
EXPORTS STDAPI DllUnregisterServer(VOID)
#else
STDAPI DllUnregisterServer(VOID)
#endif
{
   HRESULT rslt;

   HINSTANCE hInst;

   hInst = GetModuleHandle(DBCLIENT_DLL);
   if (hInst)
   {
      DBIPATH pszDllPath =
      {
         0
      };
      OLECHAR pszDllPathw[DBIMAXPATHLEN+1] =
      {
         0
      };
      GetModuleFileName(hInst, pszDllPath, sizeof(pszDllPath));
      MultiByteToWideChar(0, 0, pszDllPath, -1, pszDllPathw, sizeof(pszDllPathw)/sizeof(pszDllPathw[0]));

      ITypeLib *pTypeLib = 0; ; // oleauto.h
      rslt = LoadTypeLib(pszDllPathw, &pTypeLib);
      if (!rslt)
      {
         TLIBATTR *pLibAttr = 0; // oaidl.h
         pTypeLib->GetLibAttr(&pLibAttr);
         HRESULT hr = UnRegisterTypeLib(pLibAttr->guid, pLibAttr->wMajorVerNum, pLibAttr->wMinorVerNum, pLibAttr->lcid,
            pLibAttr->syskind);
         if (hr != S_OK)
         {
            regError("ERROR: UnregisterTypeLib returned %lX", hr);
         }

         pTypeLib->ReleaseTLibAttr(pLibAttr);
         pTypeLib->Release();
         pTypeLib = 0;
      }
      else
      {
         regError("ERROR: LoadTypeLib returned %lX", rslt);
      }
   }

#ifdef MIDAS_DLL
   // DSBASE
   rslt = Register_IF(NULL, PROGID_MDSBASE, NULL, PROGID_MDSBASE_1, NULL, CLSID_MDSBASE_1, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_MDSBASE_1, NULL, NULL, NULL, CLSID_MDSBASE_1, FALSE);

   // DSCursor
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_MDSCURSOR, NULL, PROGID_MDSCURSOR_1, NULL, CLSID_MDSCURSOR_1, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_MDSCURSOR_1, NULL, NULL, NULL, CLSID_MDSCURSOR_1, FALSE);

   // DSDATAPACKET
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_MDATAPACKETREAD, NULL, NULL, NULL, CLSID_MDATAPACKETREAD, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_MDATAPACKETWRITE, NULL, NULL, NULL, CLSID_MDATAPACKETWRITE, FALSE);
#else
   // DSBASE
   rslt = Register_IF(NULL, PROGID_DSBASE, NULL, PROGID_DSBASE_2, NULL, CLSID_DSBASE_2, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_DSBASE_1, NULL, NULL, NULL, CLSID_DSBASE_1, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_DSBASE_2, NULL, NULL, NULL, CLSID_DSBASE_2, FALSE);

   // DSCursor
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_DSCURSOR, NULL, PROGID_DSCURSOR_2, NULL, CLSID_DSCURSOR_2, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_DSCURSOR_1, NULL, NULL, NULL, CLSID_DSCURSOR_1, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_DSCURSOR_2, NULL, NULL, NULL, CLSID_DSCURSOR_2, FALSE);

   // DSDATAPACKET
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_DATAPACKETREAD, NULL, NULL, NULL, CLSID_DATAPACKETREAD, FALSE);
   if (!rslt)
      rslt = Register_IF(NULL, PROGID_DATAPACKETWRITE, NULL, NULL, NULL, CLSID_DATAPACKETWRITE, FALSE);
#endif
   return rslt;
}

HRESULT Register_IF(pCHAR pszDllPath, pCCHAR pszPROGID, pCCHAR pszPROGID_DESC, pCCHAR pszPROGID_CURVER,
   pCCHAR pszPROGID_VERINDEP, REFGUID pClsId, BOOL bReg)
{
   HRESULT rslt = SELFREG_E_CLASS;
   BYTE ClassIdStr_W[100];
   CHAR ClassIdStr[100];
   // LPCWSTR pClassIdStr_W = (LPCWSTR) &ClassIdStr_W;
   // UINT32  iStrLen = 100;

   if (StringFromGUID2(pClsId, (LPOLESTR)ClassIdStr_W, 100) != 0) // (returns len)
   {
      CHAR szBuf[100];
      pCHAR pMarker;

      // ClassID in unicode. Convert to ANSI.
      WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)ClassIdStr_W, -1, ClassIdStr, 100, NULL, NULL);

      if (bReg)
      {
         HKEY hKey = NULL;

         // PROGID-entry
         lstrcpy(szBuf, pszPROGID);
         // "Borland.DbClient = Borland Client Engine"
         CreateRegKey(szBuf, NULL, pszPROGID_DESC);

         pMarker = &szBuf[lstrlen(szBuf)]; // Points to 0
         lstrcat(szBuf, "\\Clsid");
         // "Borland.DbClient\Clsid = {12343-22 ..}"
         CreateRegKey(szBuf, NULL, ClassIdStr);
         if (pszPROGID_CURVER)
         {
            *pMarker = 0;
            lstrcat(szBuf, "\\CurVer");
            // "Borland.DbClient\CurVer = DSBASE.2"
            CreateRegKey(szBuf, NULL, pszPROGID_CURVER);
            rslt = 0;
         }
         else
         {
            // CLSID-entry
            lstrcpy(szBuf, "CLSID\\"); // "CLDID\"
            lstrcat(szBuf, ClassIdStr);
            // "CLDID\{121212 .. } = Borland Client Engine"
            CreateRegKey(szBuf, NULL, pszPROGID_DESC);
            // ProgID
            pMarker = &szBuf[lstrlen(szBuf)]; // Points to 0
            lstrcat(szBuf, "\\ProgID");
            // "CLDID\{121212 .. }\ProgID = Borland.DbClient"
            CreateRegKey(szBuf, NULL, pszPROGID);
            // InProcServer
            *pMarker = 0; //
            lstrcat(szBuf, "\\InProcServer32");
            // "CLDID\{121212 .. }\InProcServer32 = <j:\t4d\dbclient.dll>"
            CreateRegKey(szBuf, NULL, pszDllPath);
            // We need to add an additional value.
            rslt = RegOpenKeyEx(HKEY_CLASSES_ROOT, szBuf, '\0', KEY_SET_VALUE, &hKey);
            if (rslt == 0)
            {
               // "CLDID\{121212 .. }\InProcServer32 = "ThreadingModel = <Apartment>"
               RegSetValueEx(hKey, "ThreadingModel", 0, REG_SZ, (CONST BYTE*)"Apartment", 10);
               RegCloseKey(hKey);
            }
            rslt = 0; // Succeded

            // VersionIndependentProgID
            if (pszPROGID_VERINDEP)
            {
               *pMarker = 0; //
               lstrcat(szBuf, "\\VersionIndependentProgID");
               // "CLDID\{121212 .. }\InProcServer32 = <j:\t4d\dbclient.dll>"
               CreateRegKey(szBuf, NULL, pszPROGID_VERINDEP);
            }
            *pMarker = 0;

         }
      }
      else
      {
         // Delete CLSID

         if (pszPROGID_CURVER == NULL)
         {
            lstrcpy(szBuf, "CLSID\\");
            lstrcat(szBuf, ClassIdStr);
            pMarker = &szBuf[lstrlen(szBuf)]; // Points to 0

            *pMarker = 0; //
            lstrcat(szBuf, "\\InProcServer32");
            DeleteRegKey(szBuf);

            *pMarker = 0; //
            lstrcat(szBuf, "\\ProgID");
            DeleteRegKey(szBuf);

            *pMarker = 0; //
            lstrcat(szBuf, "\\VersionIndependentProgID");
            DeleteRegKey(szBuf);

            *pMarker = 0; //
            DeleteRegKey(szBuf);
         }

         // delete PROGID
         lstrcpy(szBuf, pszPROGID);
         pMarker = &szBuf[lstrlen(szBuf)]; // Points to 0
         lstrcat(szBuf, "\\Clsid");
         DeleteRegKey(szBuf);
         *pMarker = 0; //
         lstrcat(szBuf, "\\CurVer");
         DeleteRegKey(szBuf);
         *pMarker = 0; //
         DeleteRegKey(szBuf);
         rslt = 0; // Succeded
      }
   }
   return rslt;
}

HRESULT CreateRegKey(pCHAR pKey, pCHAR pValueName, pCCHAR pValue)
{
   HANDLE hHandle;
   ULONG iDisposition;
   HRESULT rslt = RegCreateKeyEx(HKEY_CLASSES_ROOT, pKey, 0, NULL, // class (object) type
      REG_OPTION_NON_VOLATILE, KEY_READ + KEY_WRITE, NULL, (HKEY__ **)&hHandle, &iDisposition);
   if (!rslt)
   {
      rslt = RegSetValueEx((HKEY__*)hHandle, pValueName, 0, REG_SZ, (pBYTE)pValue, (strlen(pValue) +1));

      RegCloseKey((HKEY__*)hHandle);
   }
   return rslt;
}

HRESULT DeleteRegKey(pCHAR pKey)
{
   return RegDeleteKey(HKEY_CLASSES_ROOT, pKey);
}
#endif // #ifdef _Windows

HRESULT DBIFN DATAPACKETREAD_Factory::QueryInterface(REFIID riid, void** ppv)
{
   HRESULT rslt = 0;
#if defined(__GNUC__) && defined(_Windows)
   IID local_riid = riid;

   if (ppv == NULL)
      return E_INVALIDARG;
   *ppv = NULL;

   UNREFERENCED_PARAMETER(local_riid);
#else
   if (ppv == NULL)
      return E_INVALIDARG;
   *ppv = NULL;

   UNREFERENCED_PARAMETER(riid);
#endif
   if (!IsEqualCLSID(riid, IID_IUnknown) && !IsEqualCLSID(riid, IID_IClassFactory))
   {
      rslt = CLASS_E_CLASSNOTAVAILABLE;
   }
   else
   {
      *ppv = (pVOID)this;
      AddRef();
   }
   return rslt;
}

HRESULT DBIFN DATAPACKETREAD_Factory::CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj)
{
   HRESULT rslt = 0;
   DSEXTRACT *pP;

   if (ppvObj == NULL)
   {
      rslt = E_INVALIDARG;
      goto Exit;
   }
   *ppvObj = NULL;
#ifdef _UNIX
   if ((pUnkOuter != NULL) && (!IsEqualCLSID(riid, IID_IUnknown)))
#else
      if (pUnkOuter != NULL && riid != IID_IUnknown)
#endif
      {
         rslt = CLASS_E_NOAGGREGATION;
         goto Exit;
      }
   pP = new DSEXTRACT();
   if (pP == NULL)
   {
      rslt = E_OUTOFMEMORY;
      goto Exit;
   }
   rslt = pP->QueryInterface(riid, ppvObj); // Increment refcount
   if (rslt)
      delete pP;
Exit:
   return rslt;
}

HRESULT DBIFN DATAPACKETWRITE_Factory::QueryInterface(REFIID riid, void** ppv)
{
   HRESULT rslt = 0;
#if defined(__GNUC__) && defined(_Windows)
   IID local_riid = riid;

   if (ppv == NULL)
      return E_INVALIDARG;
   *ppv = NULL;

   UNREFERENCED_PARAMETER(local_riid);
#else
   if (ppv == NULL)
      return E_INVALIDARG;
   *ppv = NULL;

   UNREFERENCED_PARAMETER(riid);
#endif
   if (!IsEqualCLSID(riid, IID_IUnknown) && !IsEqualCLSID(riid, IID_IClassFactory))
   {
      rslt = CLASS_E_CLASSNOTAVAILABLE;
   }
   else
   {
      *ppv = (pVOID)this;
      AddRef();
   }
   return rslt;
}

HRESULT DBIFN DATAPACKETWRITE_Factory::CreateInstance(IUnknown *pUnkOuter, REFIID riid, pVOID *ppvObj)
{
   HRESULT rslt = 0;
   DSDATAPACKET *pP;

   if (ppvObj == NULL)
   {
      rslt = E_INVALIDARG;
      goto Exit;
   }
   *ppvObj = NULL;
#ifdef _UNIX
   if ((pUnkOuter != NULL) && !(IsEqualCLSID(riid, IID_IUnknown)))
#else
      if (pUnkOuter != NULL && riid != IID_IUnknown)
#endif
      {
         rslt = CLASS_E_NOAGGREGATION;
         goto Exit;
      }
   pP = new DSDATAPACKET();
   if (pP == NULL)
   {
      rslt = E_OUTOFMEMORY;
      goto Exit;
   }
   rslt = pP->QueryInterface(riid, ppvObj); // Increment refcount
   if (rslt)
      delete pP;
Exit:
   return rslt;
}

#ifndef _UNIX

extern "C" VOID FAR EXPORTS DBIFN WEP(int bSystemExit)
{
   UNREFERENCED_PARAMETER(bSystemExit);
   return;
}

int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
   UNREFERENCED_PARAMETER(hinst);
   UNREFERENCED_PARAMETER(reason);
   return 1;
}
#endif // #ifndef  _UNIX

#ifdef _UNIX

void InitializeCriticalSection(pCRITICAL_SECTION pCriticalSection)
{
   if (pCriticalSection == NULL)
      ThrowError(DBIERR_INVALIDPARAM);
   else
   {
      pthread_mutexattr_t attr;
      if (pthread_mutexattr_init(&attr) != 0)
        ThrowError(DBIERR_INVALIDPARAM);
      if (pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE) != 0)
        ThrowError(DBIERR_INVALIDPARAM);
      if (pthread_mutex_init(&(pCriticalSection->Mutex), &attr) != 0)
        ThrowError(DBIERR_INVALIDPARAM);
   }
}

void DeleteCriticalSection(pCRITICAL_SECTION pCriticalSection)
{
   if (pCriticalSection == NULL)
      ThrowError(DBIERR_INVALIDPARAM);
}

void EnterCriticalSection(pCRITICAL_SECTION pCriticalSection)
{
   if (pCriticalSection == NULL)
      ThrowError(DBIERR_INVALIDPARAM);
   else
   {
      if (pthread_mutex_lock(&(pCriticalSection->Mutex)) != 0)
         ThrowError(DBIERR_LOCKED);
   }
}

void LeaveCriticalSection(pCRITICAL_SECTION pCriticalSection)
{
   if (pCriticalSection == NULL)
      ThrowError(DBIERR_INVALIDPARAM);
   else
   {
      if (pthread_mutex_unlock(&(pCriticalSection->Mutex)) != 0)
         ThrowError(DBIERR_UNLOCKFAILED);
   }
}
#endif  // #ifdef _UNIX
