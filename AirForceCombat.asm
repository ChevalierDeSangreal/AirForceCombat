.386
.model flat, stdcall
option casemap : none

include         windows.inc
include         Gdi32.inc
include         user32.inc
include         kernel32.inc
include         msimg32.inc
includelib      Gdi32.lib
includelib      user32.lib
includelib      kernel32.lib
includelib      msimg32.lib

WINDOW_HIDTH    equ     500
WINDOW_WIDTH    equ     500
MAP_HIDTH       equ     500
MAP_WIDTH       equ     500

ICO_MAIN        equ     100
IDC_MAIN        equ     100
IDC_MOVE        equ     101
IDB_BACK        equ     100
IDB_PLANE       equ     101
ID_TIMER        equ     1

INITHP          equ     1000
INITR           equ     20
INITATK         equ     20
INITATF         equ     10
INITCALIBER     equ     5
BULLETMAXNUM    equ     500            ; 子弹数量上限，也就是子弹池的规模


.data?
hInstance       dd ?
hWinMain        dd ?
hCursorMain     dd ?
hCursorMove     dd ?



.data

INTPOS struct

    dwX         dd ?
    dwY         dd ?

INTPOS ends

POS struct

    fX          real8 ?
    fY          real8 ?

POS ends

ShowMaker struct

    hBmpBack    dd ?
    hDCBack     dd ?

ShowMaker ends

AEROCRAFT struct

    dwID        dd 0
    dwHP        dd ?
    dwMaxHP     dd ?
    dwRadius    dd ?
    dwForward   dd ?
    stNowPos    POS <>
    dwLevel     dd ?
    dwExp       dd ?
    dwAtk       dd ?
    dwAtf       dd ?
    dwCaliber   dd ?
    dwWeaponType dd ?
    dwAmmunition dd ?
    hBmp        dd ?
    hDC         dd ?
    dwNxt       dd ?

AEROCRAFT ends

BULLET struct

    dwID        dd 0
    dwAerocraftID dd ?
    dwSPeed     dd ?
    dwForward   dd ?
    dwRadius    dd ?
    stNowPos    POS <>
    dwAtk       dd ?
    hBmp        dd ?
    hDC         dd ?

BULLET ends


dwRandSeed      dd 0
stShowMaker     ShowMaker <>
stAerocraft1    AEROCRAFT <>
stAerocraft2    AEROCRAFT <>
stBullets       BULLET BULLETMAXNUM dup(<>)


.const
szClassName     db      'Clock', 0
EPS             real8   0.000000001

.code

_mod proc C    @x, @y
    local   @output
    pushad

    mov     eax, @x
    sub     edx, edx
    div     @y
    mov     @output, edx

    popad
    mov     eax, @output
    ret
_mod endp

_RandSetSeed proc C
    local   @input, @tmp
    mov     @input, eax
    pushad

    .if     @input == 0
        invoke  GetTickCount
        mov     dwRandSeed, eax
    .else
		mov		eax, @input
        mov     dwRandSeed, eax
    .endif

	mov		eax, dwRandSeed
	mov		@tmp, 214013
    mul		@tmp
    add     eax, 2531011
    shr     eax, 16
    AND     eax, 7fffH
	mov		dwRandSeed, eax

    popad
    ret
_RandSetSeed endp

_RandGet proc C
    local   @input, @output, @tmp
    mov     @input, eax
    pushad

    ; x = ((x * 214013 + 2531011) >> 16) & 0x7fff 
	mov		eax, dwRandSeed
	mov		@tmp, 214013
    mul		@tmp
    add     eax, 2531011
    shr     eax, 16
    AND     eax, 7fffH
	mov		dwRandSeed, eax

    invoke  _mod, dwRandSeed, @input
    mov     @output, eax

    popad
    mov     eax, @output
    ret
_RandGet endp



_GetDis proc C	@pos1:POS, @pos2:POS
	local	@tmp1:real8, @tmp2:real8
	pushad
	finit

	fld		@pos1.fX
	fld		@pos2.fX
	fsub
	fst		@tmp1
	fld		@tmp1
	fmul
	fst		@tmp1
	fld		@pos1.fY
	fld		@pos2.fY
	fsub
	fst		@tmp2
	fld		@tmp2
	fmul
	fst		@tmp2
	
	fld		@tmp1
	fld		@tmp2
	fadd
	fsqrt

	popad

	ret
_GetDis endp


_fequ proc C @x:real8, @y:real8
    local   @tmp:dword
    pushad
    finit

    fld     @x
    fld     @y
    fsub
    fabs
    fld     EPS
    fcom
    fnstsw  ax
    AND     ah, 01000101b
    .if     ah == 00000000b
        mov @tmp, 1
    .elseif ah == 01000101b
        mov @tmp, -1
    .else
        mov @tmp, 0
    .endif

    popad
    mov     eax, @tmp
    ret
_fequ   endp

_BitMove proc dir, lpPos

    ret

_BitMove endp

_fcmp proc C @x:real8, @y:real8
	local	@tmp:dword
	finit
	pushad
	fld		@x
	fld		@y
	fcom	
	fnstsw	ax
	AND		ah, 01000101b
	.if		ah == 00000000b	;st(0)>st(1), 即y>x
		mov	@tmp, -1
	.elseif	ah == 00000001b
		mov	@tmp, 1
	.elseif	ah == 01000000b
		mov	@tmp, 0
	.else
		mov	@tmp, -2
	.endif

	popad
		mov	eax, @tmp
	ret
_fcmp endp


_CheckCircleEdge proc C @p:POS, @R:dword
    local   @output
    local   @r:real8, @x1:real8, @y1:real8, @x2:real8, @y2:real8, @z:real8
    local   @t1, @t2, @x:real8, @y:real8
    local   @tmp1, @tmp2, @tmp3, @tmp4
    local   @tmp5, @tmp6, @tmp7, @tmp8
    pushad
    ; a,b,c,d 下左上右

    finit
    mov     @t1, MAP_WIDTH
    mov     @t2, MAP_HIDTH
    fild    @t1
    fstp    @x
    fild    @t2
    fstp    @y

    finit
    fild    @R
    fstp    @r

    fld     @p.fX
    fld     @r
    fsub    
    fstp    @y1

    fld     @p.fX
    fld     @r
    fadd
    fstp    @y2

    fld     @p.fY
    fld     @r
    fsub    
    fstp    @x1

    fld     @p.fY
    fld     @r
    fadd
    fstp    @x2

	fldz
	fstp	@z
    ; 0 <= x1 x2 <= x 0 <= y1 y2<= y
    finit
    invoke  _fcmp, @z, @x1
    mov     @tmp1, eax
    invoke  _fequ, @z, @x1
    mov     @tmp2, eax
    invoke  _fcmp, @x2, @x
    mov     @tmp3, eax
    invoke  _fequ, @x2, @x
    mov     @tmp4, eax
    invoke  _fcmp, @z, @y1
    mov     @tmp5, eax
    invoke  _fequ, @z, @y1
    mov     @tmp6, eax
    invoke  _fcmp, @y2, @y
    mov     @tmp7, eax
    invoke  _fequ, @y2, @y
    mov     @tmp8, eax
    .if     (@tmp1 == -1 || @tmp2 == 1)&&(@tmp3 == -1 || @tmp4 == 1)&&\
			(@tmp5 == -1 || @tmp6 == 1)&&(@tmp7 == -1 || @tmp8 == 1)
        mov @output, 1
    .else
        mov @output, 0
    .endif

    popad
    mov eax, @output
    ret
_CheckCircleEdge endp


_CheckCircleCross proc C	@pos1:POS, @R1:dword, @pos2:POS, @R2:dword
	local	@pd
	local	@tmp1, @tmp2, @tmp3, @tmp4
	local	@r1:real8, @r2:real8 
	local	@dis:real8, @d1:real8, @d2:real8
	local	@t1, @t2
	pushad
	
	finit
	fild	@R1
	fstp	@r1
	fild	@R2
	fstp	@r2

	;使@r1 >= @r2
	invoke	_fcmp, @r1, @r2
	mov		@t1, eax
	invoke	_fequ, @r1, @r2
	mov		@t2, eax
	.if		@t1 == -1 && @t2 == 0
		fld		@pos1.fX
		fld		@pos2.fX
		fstp	@pos1.fX
		fstp	@pos2.fX

		fld		@pos1.fY
		fld		@pos2.fY
		fstp	@pos1.fY
		fstp	@pos2.fY

		fld		@r1
		fld		@r2
		fstp	@r1
		fstp	@r2
	.endif

	; @d1 = @r1 - @r2, @d2 = @r1 + @r2
	finit
	fld		@r1
	fld		@r2
	fsub
	fst		@d1
	fld		@r1
	fld		@r2
	fadd
	fst		@d2

	; @dis = dis(@pos1,@pos2)
	invoke	_GetDis, @pos1, @pos2
	fst		@dis

	; dis<d2
	invoke	_fcmp, @dis, @d2
	mov		@tmp3, eax
	.if		(@tmp3 == -1)
		mov		@pd, 1
	.else
		mov		@pd, 0
	.endif

	popad
	mov		eax, @pd
	ret
_CheckCircleCross endp


_GetaPos proc uses ecx edx esi, @R
        local @pos:POS, @x, @y
    
    finit

    .while 1
        ; 用rand取得(0, map_hidth - 2 * r)的随机数，再加上r，最终取得(r, map_hidth - r)的随机数
        mov    eax, MAP_HIDTH
        sub    eax, @R
        sub    eax, @R 
        invoke _RandGet
        add    eax, @R
        mov    @x, eax
        fild   @x
        fstp   @pos.fX

        mov    eax, MAP_WIDTH
        sub    eax, @R
        sub    eax, @R 
        invoke _RandGet
        add    eax, @R
        mov    @y, eax
        fild   @y
        fstp   @pos.fY

        
        ; 扫描所有实体，判断该坐标是否可用，用edx为1表示该坐标可用
        ; 扫描子弹表
        mov    edx, 1
        lea    esi, stBullets
        assume esi:ptr BULLET
        xor    ecx, ecx
        .while ecx < BULLETMAXNUM
            mov    eax, [esi].dwID
            .if eax != 0
                invoke _CheckCircleCross, @pos, @R, [esi].stNowPos, [esi].dwRadius
                .if eax
                    xor    edx, edx
                    .break
                .endif
            .endif
            inc    ecx
            add    esi, sizeof BULLET
        .endw
        assume esi:nothing

        .if edx == 0
            .continue
        .endif

        ; 若一号机位置已被确定
        .if stAerocraft1.dwID != 0
            invoke _CheckCircleCross, @pos, @R, stAerocraft1.stNowPos, stAerocraft1.dwRadius
            .if eax
                .continue
            .endif
        .endif

        .if stAerocraft2.dwID != 0
            invoke _CheckCircleCross, @pos, @R, stAerocraft1.stNowPos, stAerocraft1.dwRadius
            .if eax
                .continue
            .endif
        .endif


        mov    eax, @x
        mov    ebx, @y
        ret

    .endw
    ret

_GetaPos endp

_AerocraftMov proc uses esi, lpAerocraft

    assume esi:ptr AEROCRAFT
    mov    esi, lpAerocraft
    invoke _BitMove, [esi].dwForward, addr [esi].stNowPos
    assume esi:nothing
    ret

_AerocraftMov endp

_AerocraftInit proc
        local @tmp

    mov    stAerocraft1.dwMaxHP, INITHP
    mov    stAerocraft2.dwMaxHP, INITHP
    mov    stAerocraft1.dwHP, INITHP
    mov    stAerocraft2.dwHP, INITHP
    mov    stAerocraft1.dwRadius, INITR
    mov    stAerocraft2.dwRadius, INITR
    mov    stAerocraft1.dwForward, 0
    mov    stAerocraft2.dwForward, 0
    mov    stAerocraft1.dwLevel, 0
    mov    stAerocraft2.dwLevel, 0
    mov    stAerocraft1.dwExp, 0
    mov    stAerocraft2.dwExp, 0
    mov    stAerocraft1.dwAtk, INITATK
    mov    stAerocraft2.dwAtk, INITATK
    mov    stAerocraft1.dwAtf, INITATF
    mov    stAerocraft2.dwAtf, INITATF
    mov    stAerocraft1.dwWeaponType, 0
    mov    stAerocraft2.dwWeaponType, 0
    mov    stAerocraft1.dwAmmunition, 0
    mov    stAerocraft2.dwAmmunition, 0
    mov    stAerocraft1.dwCaliber, INITCALIBER
    mov    stAerocraft2.dwCaliber, INITCALIBER
    mov    stAerocraft1.dwNxt, 0
    mov    stAerocraft2.dwNxt, 0

    ; 分别初始化位置
    invoke _GetaPos, stAerocraft1.dwRadius
    mov    @tmp, eax
    fild   @tmp
    fstp   stAerocraft1.stNowPos.fX
    mov    @tmp, ebx
    fild   @tmp
    fstp   stAerocraft1.stNowPos.fY
    mov    stAerocraft1.dwID, 1

    ; invoke _GetaPos, stAerocraft2.dwRadius
    ; fild   eax
    ; fstp   stAerocraft2.stNowPos.fX
    ; fild   ebx
    ; fstp   stAerocraft2.stNowPos.fY
    ; mov    stAerocraft2.dwID, 2
    
    ret
_AerocraftInit endp

_MainInit proc

    invoke _AerocraftInit

    ret
_MainInit endp

_ShowMakerDestroy proc

    invoke KillTimer, hWinMain, ID_TIMER
    invoke DestroyWindow, hWinMain
    invoke PostQuitMessage, NULL

    ; 删除背景>>>>>
    invoke DeleteDC, stShowMaker.hDCBack
    invoke DeleteObject, stShowMaker.hBmpBack
    ; <<<<<删除完成

    ret
_ShowMakerDestroy endp

_ShowMakerPaint proc uses eax
        local @hDC
        local @hBmpBack
        local @x, @y, @Plane1D

    mov    eax, stAerocraft1.dwRadius
    mov    @Plane1D, eax
    add    @Plane1D, eax
    
    invoke GetDC, hWinMain
    mov    @hDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hDCBack, eax
    invoke CreateCompatibleDC, @hDC
    mov    stAerocraft1.hDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stAerocraft2.hDC, eax
    invoke CreateCompatibleBitmap, @hDC, MAP_HIDTH, MAP_WIDTH
    mov    stShowMaker.hBmpBack, eax
    invoke ReleaseDC, hWinMain, @hDC

    invoke LoadBitmap, hInstance, IDB_BACK
    mov    @hBmpBack, eax
    invoke LoadBitmap, hInstance, IDB_PLANE
    mov    stAerocraft1.hBmp, eax
    invoke LoadBitmap, hInstance, IDB_PLANE
    mov    stAerocraft2.hBmp, eax

    invoke SelectObject, stAerocraft1.hDC, stAerocraft1.hBmp
    invoke SelectObject, stAerocraft2.hDC, stAerocraft2.hBmp
    invoke SelectObject, stShowMaker.hDCBack, stShowMaker.hBmpBack

    ; 绘制背景
    invoke CreatePatternBrush, @hBmpBack
    push   eax
    invoke SelectObject, stShowMaker.hDCBack, eax
    invoke PatBlt, stShowMaker.hDCBack, 0, 0, MAP_HIDTH, MAP_WIDTH, PATCOPY
    invoke DeleteObject, eax

    ; 放缩图片
    ; invoke StretchBlt, @htmp1DC, 0, 0, @Plane1D, @Plane1D, stAerocraft1.hDC, 0, 0, 150, 150, SRCAND

    ; invoke TransparentBlt, hDCBack, 0, 0, CLOCK_SIZE, CLOCK_SIZE, @hDCCircle, 0, 0, CLOCK_SIZE, CLOCK_SIZE, 0
    fld    stAerocraft1.stNowPos.fX
    fist   @x
    fld    stAerocraft1.stNowPos.fY
    fist   @y 
    mov    eax, stAerocraft1.dwRadius
    sub    @x, eax
    sub    @y, eax
    invoke StretchBlt, stShowMaker.hDCBack, @x, @y, @Plane1D, @Plane1D, stAerocraft1.hDC, 0, 0, 150, 150, SRCAND
    ; invoke BitBlt, @x, @y, @Plane1D, @Plane1D, 0, 0, @Plane1D, @Plane1D, SRCAND
    ; invoke TransparentBlt, stShowMaker.hDCBack, @x, @y, MAP_HIDTH, MAP_WIDTH, @htmp1DC, 0, 0, @Plane1D, @Plane1D, 0

    invoke DeleteDC, stAerocraft1.hDC
    invoke DeleteDC, stAerocraft2.hDC
    invoke DeleteObject, @hBmpBack
    invoke DeleteObject, stAerocraft1.hBmp
    invoke DeleteObject, stAerocraft2.hBmp


    ret
_ShowMakerPaint endp

_ShowMakerInit proc

    ; 创建窗口
    invoke SetWindowRgn, hWinMain, eax, TRUE
    invoke SetWindowPos, hWinMain, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOSIZE

    invoke _ShowMakerPaint

    invoke SetTimer, hWinMain, ID_TIMER, 10000, NULL

    ret
_ShowMakerInit endp

_MainKeyboard proc char

    .if char == 'w'
        mov stAerocraft1.dwNxt, 1
    .elseif char == 's'
        mov stAerocraft1.dwNxt, 2
    .elseif char == 'a'
        mov stAerocraft1.dwNxt, 3
    .elseif char == 'd'
        mov stAerocraft1.dwNxt, 4
    .elseif char == 'i'
        mov stAerocraft1.dwNxt, 1
    .elseif char == 'k'
        mov stAerocraft1.dwNxt, 2
    .elseif char == 'j'
        mov stAerocraft1.dwNxt, 3
    .elseif char == 'l'
        mov stAerocraft1.dwNxt, 4
    .endif

    ret
_MainKeyboard endp

_ProcWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
        local @stPs: PAINTSTRUCT
        local @hDC, @char:WPARAM
        
    mov    eax, uMsg
    .if eax == WM_TIMER
        invoke _ShowMakerPaint
        invoke InvalidateRect, hWnd, NULL, FALSE
    .elseif eax == WM_PAINT
        invoke BeginPaint, hWnd, addr @stPs
        mov    @hDC, eax
        mov    eax, @stPs.rcPaint.right
        sub    eax, @stPs.rcPaint.left
        mov    ecx, @stPs.rcPaint.bottom
        sub    ecx, @stPs.rcPaint.top
        invoke BitBlt, @hDC, @stPs.rcPaint.left, @stPs.rcPaint.top, eax, ecx, stShowMaker.hDCBack, @stPs.rcPaint.left, @stPs.rcPaint.top, SRCCOPY
        invoke EndPaint, hWnd, addr @stPs
    .elseif eax == WM_CHAR
        invoke _MainKeyboard, wParam
    .elseif eax == WM_CREATE
        mov   eax, hWnd
        mov   hWinMain, eax
        invoke _MainInit
        invoke _ShowMakerInit
    .elseif eax == WM_CLOSE
        invoke _ShowMakerDestroy
    .else
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    xor    eax, eax
    ret

_ProcWinMain endp

_WinMain proc
        local @stWndClass: WNDCLASSEX
        local @stMsg : MSG

    invoke  GetModuleHandle, NULL
    mov     hInstance, eax
    invoke  LoadCursor, hInstance, IDC_MOVE
    mov     hCursorMove, eax
    invoke  LoadCursor, hInstance, IDC_MAIN
    mov     hCursorMain, eax
    invoke  RtlZeroMemory, addr @stWndClass, sizeof @stWndClass; 变量清零
    invoke  LoadIcon, hInstance, ICO_MAIN
    mov     @stWndClass.hIcon, eax
    mov     @stWndClass.hIconSm, eax
    invoke  LoadCursor, 0, IDC_ARROW
    mov     @stWndClass.hCursor, eax
    mov     eax, hInstance
    mov     @stWndClass.hInstance, eax
    mov     @stWndClass.cbSize, sizeof WNDCLASSEX
    mov     @stWndClass.style, CS_HREDRAW or CS_VREDRAW
    mov     @stWndClass.lpfnWndProc, offset _ProcWinMain
    mov     @stWndClass.hbrBackground, COLOR_WINDOW + 1
    mov     @stWndClass.lpszClassName, offset szClassName
    invoke  RegisterClassEx, addr @stWndClass
    invoke  CreateWindowEx, NULL, offset szClassName, offset szClassName, WS_POPUP or WS_SYSMENU, 100, 100, WINDOW_HIDTH, WINDOW_WIDTH, NULL, NULL, hInstance, NULL
    mov     hWinMain, eax
    invoke  ShowWindow, hWinMain, SW_SHOWNORMAL
    invoke  UpdateWindow, hWinMain
    .while  TRUE
    invoke  GetMessage, addr @stMsg, NULL, 0, 0
    .break  .if     eax == 0
    invoke  TranslateMessage, addr @stMsg
    invoke  DispatchMessage, addr @stMsg
    .endw
    ret

_WinMain endp



start:
    call   _WinMain
    invoke ExitProcess, NULL
end    start