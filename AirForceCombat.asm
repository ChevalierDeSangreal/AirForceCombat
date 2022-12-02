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
INITR           equ     75
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



stShowMaker     ShowMaker <>
stAerocraft1    AEROCRAFT <>
stAerocraft2    AEROCRAFT <>
stBullets       BULLET BULLETMAXNUM dup(<>)


.const
szClassName     db      'Clock', 0

.code

_BitMove proc dir, lpPos

    ret

_BitMove endp

_RandGet proc

    mov    eax, 50
    ret

_RandGet endp

_CheckCircleCross proc lpPos1, dwRadius1, lpPos2, dwRadius2
    
    mov    eax, 1
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
                invoke _CheckCircleCross, addr @pos, addr @R, addr [esi].stNowPos, addr [esi].dwRadius
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
        local @hDC, @htmp1DC
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
    invoke CreateCompatibleBitmap, @hDC, @Plane1D, @Plane1D
    mov    @htmp1DC, eax
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

    invoke BitBlt, stShowMaker.hDCBack, 0, 0, 97, 95, stAerocraft1.hDC, 0, 0, SRCAND
    ; 放缩图片
    ; invoke StretchBlt, stShowMaker.hDCBack, 10, 10, 210, 210, stAerocraft1.hDC, 0, 0, 200, 200, SRCPAINT

    ; invoke TransparentBlt, hDCBack, 0, 0, CLOCK_SIZE, CLOCK_SIZE, @hDCCircle, 0, 0, CLOCK_SIZE, CLOCK_SIZE, 0
    ; fld    stAerocraft1.stNowPos.fX
    ; fist   @x
    ; fld    stAerocraft1.stNowPos.fY
    ; fist   @y 
    ; mov    eax, stAerocraft1.dwRadius
    ; sub    @x, eax
    ; sub    @y, eax
    ; invoke TransparentBlt, stShowMaker.hDCBack, 0, 0, MAP_HIDTH, MAP_WIDTH, @htmp1DC, 0, 0, @Plane1D, @Plane1D, 0

    invoke DeleteDC, stAerocraft1.hDC
    invoke DeleteDC, stAerocraft2.hDC
    invoke DeleteDC, @htmp1DC
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

_ProcWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
        local @stPs: PAINTSTRUCT
        local @hDC
        
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