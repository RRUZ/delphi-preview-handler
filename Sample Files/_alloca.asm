;[]-----------------------------------------------------------------[]
;|   _ALLOCA.ASM -- allocate temporary stack space                   |
;[]-----------------------------------------------------------------[]

;
;       C/C++ Run Time Library - Version 23.0
; 
;       Copyright (c) 1992, 2015 by Embarcadero Technologies, Inc.
;       All Rights Reserved.
; 

; $Revision: 23293 $

        include rules.asi
        include init.inc

;       Segments Definitions

Header@

; REGSTACK contains the number of bytes taken up in the stack
; by registers saved in the normal function prologue.  This includes
; space for EBX, ESI, and EDI.

REGSTACK   equ     12

;----------------------------------------------------------------------
; Name          _alloca - allocate temporary stack memory
;
; Usage         void *_alloca(size_t size);
;
; Prototype in  _malloc.h
;
; Description   _alloca allocates size bytes on the stack; the allocated
;               space is automatically freed up when the calling function
;               exits.
;
;               Because _alloca modifies the stack pointer, do not place calls
;               to _alloca in an expression that is an argument to a function.
;
;               If the calling function does not contain any references
;               to local variables in the stack, the stack will not
;               be restored correctly when the function exits, resulting
;               in a program crash.  To ensure that the stack is restored
;               correctly, use the following code in the calling function:
;
;                       char *p;
;                       char dummy[1];
;
;                       dummy[0] = 0;
;                       ...
;                       p = alloca(nbytes);
;
;               This is an internal function that corresponds to the
;               user-visible function alloca().  That function is
;               declared in malloc.h.
;
; Return value  Returns a pointer to the allocated stack area on success.
;               If the stack cannot be extended, a NULL pointer is returned.
;               The returned pointer should never be passed to free().
;
; Note          Compatible with Microsoft C and UNIX.  Not recommended.
;               Use malloc() instead.
;----------------------------------------------------------------------

Code_seg@

extrn ___GetStkIndex:proc       ; Gets the _stkindex value (in TLS.C)

Func@   _alloca, _EXPFUNC, cdecl

        pop     edx             ; pop return address
        pop     eax             ; pop size parameter
        add     eax,3           ; round size up to multiple of 4
        and     eax,not 3
        neg     eax             ; negate size
        add     eax,esp         ; add current stack pointer
        cmp     eax,esp         ; would new ESP wrap around?
        ja      bad             ; yes - return error

; Get the current thread's stack base.  The RTL stores this in the
; thread local storage variable named _stkindex.

        push    eax             ; save new ESP
        push    edx             ; save return address
        call    ___GetStkIndex  ; Get the stack base value (in TLS.C)
        add     eax, 4096*4     ;  add four extra pages since NT will
                                ;  fault upon any access to the guard page
                                ;  and the RTL may use up some more stack.

        mov     ecx, eax        ; put stack base in ECX
        pop     edx             ; recover return address
        pop     eax             ; recover new ESP
        add     ecx,REGSTACK    ; adjust base for saved register variables
        cmp     ecx,eax         ; would new ESP fall below stack base?
        ja      bad

; The current stack looks like this, from high to low address:
;       EBX saved by caller (assumed to be present)
;       ESI saved by caller (assumed to be present)
; ESP-> EDI saved by caller (assumed to be present)
;       ... empty space ...
; EAX -> new stack area

; We must probe the stack in 4K increments to force NT to un-guard the
; stack guard pages.  At this point, EAX contains the future value of ESP.

        mov     ecx, esp        ; get a copy of the current ESP
probeloop:
        sub     ecx, 4096       ; bump down to the next page
        cmp     ecx, eax        ; any more stack left to probe?
        jb      pushregs        ; no - we're done
        sub     esp, 4096-4
        push    LARGE 0         ; probe next page by pushing a
                                ; dummy value
        jmp     probeloop

; Before we can return, we need to push on the new stack area the registers
; saved by caller in the old stack area.  We need to copy at least 3 longwords
; (for EBX, ESI, and DI).  We can't tell if these registers were really
; saved, so we assume that they were, and allocate extra space for them.

pushregs:
        mov     ecx,esp         ; get a copy of old ESP into ECX
        mov     esp,eax         ; set up new ESP
        push    dword ptr [ecx+8]  ; push copies of saved reg variables
        push    dword ptr [ecx+4]
        push    dword ptr [ecx+0]
return:
    if PopParms@ eq 0
        sub     esp, 4          ; fake argument for caller to pop
    endif
        jmp     edx             ; return

; Come here if there isn't enough stack space.  Return a null pointer.

bad:
        xor     eax,eax         ; return NULL pointer
        jmp     return

EndFunc@ _alloca

;----------------------------------------------------------------------
; Name          __alloca_helper - allocate temporary stack memory
;
; Usage         void *alloca(size_t size);
;
; Prototype in  malloc.h
;
; Description   __alloca_helper allocates size bytes on the stack; the
;		allocated space is automatically freed up when the calling
;		function exits.
;
;		This function is different from _alloca, because it takes
;		an extra parameter, the number of dwords already pushed
;		for the current statement.
;
;		The current compiler will force a stackframe when it
;		encounters calls to alloca.
;
;               This is an internal function that corresponds to the
;               user-visible function alloca().  That function is
;               declared in malloc.h.
;
; Return value  Returns a pointer to the allocated stack area on success.
;               If the stack cannot be extended, a NULL pointer is returned.
;               The returned pointer should never be passed to free().
;
; Note          Compatible with Microsoft C and UNIX.  Not recommended.
;               Use malloc() instead.
;----------------------------------------------------------------------

Func@   __alloca_helper, _EXPFUNC, cdecl

; current stack:
;	pushed entries?
; 	pushed stack depth
; 	requested size of alloca
; 	return address

        pop     edx             ; pop return address
        pop     eax             ; pop size parameter
	pop	ecx		; pop pushed stack depth

; We need an extra register further down. We do this by keeping the return
; addrress on the stack and moving it along with any previously pushed entries.
; The drawback is that we probe one more DWORD than the user requested.

	push	edx		; store return address
	inc	ecx		; make pushed return address extra entry to move
        add     eax,3           ; round size up to multiple of 4
        and     eax,not 3
        neg     eax             ; negate size
        add     eax,esp         ; add current stack pointer
        cmp     eax,esp         ; would new ESP wrap around?
        ja      bad2            ; yes - return error

; Get the current thread's stack base.  The RTL stores this in the
; thread local storage variable named _stkindex.

        push    eax             ; save new ESP
	push	ecx		; save pushed stack depth
        call    ___GetStkIndex  ; Get the stack base value (in TLS.C)
        add     eax, 4096*4     ;  add four extra pages since NT will
                                ;  fault upon any access to the guard page
                                ;  and the RTL may use up some more stack.

        mov     edx, eax        ; put stack base in EDX
	pop	ecx		; recover pushed stack depth
        pop     eax             ; recover new ESP
        cmp     edx, eax        ; would new ESP fall below stack base?
        ja      bad2

; The current stack looks like this, from high to low address:
;       pushed entries?
;       pushed entries?
; ESP-> pushed return address
;       ... empty space ...
; EAX -> new stack area

; We must probe the stack in 4K increments to force NT to un-guard the
; stack guard pages.  At this point, EAX contains the future value of ESP.

        mov     edx, esp        ; save current ESP into EDX
probeloop2:
        sub     esp, 4096       ; bump down to the next page
        cmp     esp, eax        ; any more stack left to probe?
        jb      movepushes      ; no - we're done
        add     esp, 4          ; probe next page by pushing a
        push    LARGE 0         ; dummy value
        jmp     probeloop2

; We are going to move the entries already pushed on the stack
; to below the newly allocated stack area.

movepushes:
        mov     esp, eax        ; set up new ESP
	push	ebx		; we need one more register
moveloop:
	mov	ebx, [edx]	; get the pushed entry
	mov	[eax], ebx	; and move it
	add	eax, 4
	add	edx, 4		; move the fences
	dec	ecx
	jnz	moveloop
	pop	ebx		; recover ebx
return2:
	pop	edx		; recover return address
    if PopParms@ eq 0
        sub     esp, 4          ; fake argument for caller to pop
				; alloca is prototyped as taking one parameter
    endif
        jmp     edx             ; return

; Come here if there isn't enough stack space.  Return a null pointer.

bad2:
        xor     eax,eax         ; return NULL pointer
        jmp     return2

EndFunc@ __alloca_helper

Code_EndS@

        end
