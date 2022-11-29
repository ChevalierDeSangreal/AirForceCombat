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

WINDOW_HIDTH    equ     150
WINDOW_WIDTH    equ     150

ICO_MAIN        equ     100
IDC_MAIN        equ     100
IDC_MOVE        equ     101
IDB_BACK1       equ     100
ID_TIMER        equ     1
IDM_BACK1       equ     100
IDM_EXIT        equ     104

.data?
hInstance       dd ?
hWinMain        dd ?
hCursorMain     dd ?
hCursorMove     dd ?



.data
ShowMaker struct

    hBmpBack dd ?
    hDCBack  dd ?

ShowMaker ends

stShowMaker     ShowMaker <>

.const
szClassName     db      'Clock', 0

.code

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

_ShowMakerInit proc
        local @hDC
        local @hBmpBack


    invoke SetWindowRgn, hWinMain, eax, TRUE
    invoke SetWindowPos, hWinMain, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOSIZE

    ; 绘制背景>>>>>
    invoke GetDC, hWinMain
    mov    @hDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hDCBack, eax
    invoke CreateCompatibleBitmap, @hDC, WINDOW_HIDTH, WINDOW_WIDTH
    mov    stShowMaker.hBmpBack, eax

    invoke ReleaseDC, hWinMain, @hDC

    invoke LoadBitmap, hInstance, IDB_BACK1
    mov    @hBmpBack, eax
    
    invoke SelectObject, stShowMaker.hDCBack, stShowMaker.hBmpBack
    invoke CreatePatternBrush, @hBmpBack
    push   eax
    invoke SelectObject, stShowMaker.hDCBack, eax
    invoke PatBlt, stShowMaker.hDCBack, 0, 0, WINDOW_HIDTH, WINDOW_WIDTH, PATCOPY
    invoke DeleteObject, eax

    ; invoke TransparentBlt, hDCBack, 0, 0, CLOCK_SIZE, CLOCK_SIZE, @hDCCircle, 0, 0, CLOCK_SIZE, CLOCK_SIZE, 0

    invoke DeleteObject, @hBmpBack
    ; <<<<<绘制完成

    invoke SetTimer, hWinMain, ID_TIMER, 1000, NULL
    ret

_ShowMakerInit endp

_ProcWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
        local @stPs: PAINTSTRUCT
        local @hDC
        
    mov    eax, uMsg
    .if eax == WM_TIMER
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