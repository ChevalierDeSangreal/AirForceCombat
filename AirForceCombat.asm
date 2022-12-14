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
includelib      msvcrt.lib
includelib      ucrt.lib
includelib      legacy_stdio_definitions.lib

WINDOW_HIDTH    equ     1400
WINDOW_WIDTH    equ     1000
MAP_HIDTH       equ     1400
MAP_WIDTH       equ     800

; 图片大小常数
PLANEBMPHIDTH   equ     128
PLANEBMPWIDTH   equ     128
BULLETBMPHIDTH  equ     128
BULLETBMPWIDTH  equ     128
EXPBMPHIDTH     equ     100
EXPBMPWIDTH     equ     100
BARRIERBMPHIDTH equ     128
BARRIERBMPWIDTH equ     128
UIBMPHIDTH      equ     1400
UIBMPWIDTH      equ     200

ICO_MAIN        equ     100
IDC_MAIN        equ     100
IDC_MOVE        equ     101
IDB_MASK        equ     100
IDB_BACK        equ     101
IDB_PLANE       equ     102
IDB_BULLET      equ     103
IDB_EXP         equ     104
IDB_BRRIER      equ     105
IDB_PLANE2      equ     106
IDB_BULLET2     equ     107
IDB_UI          equ     108
IDB_RK1         equ     109
IDB_RK2         equ     110
IDB_RK3         equ     111
ID_TIMER        equ     1

INITHP          equ     100
INITR           equ     20
INITATK         equ     20
INITATF         equ     10
INITCALIBER     equ     5
INITBULLETSPEED equ     10
INITPLANESPEED  equ     50
BULLETMAXNUM    equ     500   
BARRIERMAXNUM   equ     5; 子弹数量上限，也就是子弹池的规模
BULLETRADIUS    equ     20


INITPACKHP1	    equ     100
INITPACKHP2		equ     125
INITPACKHP3		equ     200
INITPACKEXP1	equ     5
INITPACKEXP2	equ     10
INITPACKEXP3	equ     20
INITPACKR1      equ     10
INITPACKR2      equ     15
INITPACKR3      equ     20
INITBARRIER     equ     40
EXPPACKMAXNUM	equ		20
EXPPACKGANFRE   equ     100
BULLETPACKMAXNUM equ	20
DEFAULTW        equ     200


.data?
hInstance       dd ?
hWinMain        dd ?
hCursorMain     dd ?
hCursorMove     dd ?
dwDebug         dd 0
dwAttackSpeed   dd 0
testsnum        dd 0
dwBulletSpeedlimit dd 0

.data

msg1       byte 'shoot', 0ah, 0
msg2       byte 'pack', 0ah, 0
msg3       byte 'printpack', 0ah, 0
msg4       byte '%d',0
msg5       byte 'LEVEL:%d', 0
msg6       byte 'HP:%d/%d', 0
msg7       byte 'EXP:%d', 0
msg8       byte 'Player %d Wins the Game!!!', 0
msg9       byte 'Game Over!!!', 0
msgtmp     byte 64 dup(0)

POS struct

    fX          real8 ?
    fY          real8 ?

POS ends

EXPPACK struct

    dwID            dd 0
    dwHP		    dd ?
    dwType		    dd ?
    dwRadius        dd ?
    stNowPos        POS <>
    hBmp            dd ?
    hDC			    dd ?

EXPPACK ends

BARRIER struct

    dwRadius        dd ?
    stNowPos        POS <>
    hBmp            dd ?
    hDC			    dd ?
    dwID            dd ?

BARRIER ends

MAIN struct

    dwWeaponStamp   dd ?
    dwExpStamp      dd ?

MAIN ends

BULLETPACK struct

    dwID            dd 0
    dwType		    dd ?
    dwRadius        dd ?
    stNowPos        POS <>
    hBmp            dd ?
    hDC			    dd ?

BULLETPACK ends

INTPOS struct

    dwX         dd ?
    dwY         dd ?

INTPOS ends

SHOWMAKER struct

    hBmpFinal   dd ?
    hFinalDC    dd ?
    hBmpBack    dd ?
    hBulletDC1  dd ?
    hBulletDC2  dd ?
    hExpDC1     dd ?
    hExpDC2     dd ?
    hExpDC3     dd ?
    hBulletBmp1 dd ?
    hBulletBmp2 dd ?
    hExpBmp1    dd ?
    hExpBmp2    dd ?
    hExpBmp3    dd ?
    hBarrierBmp dd ?
    hBarrierDC  dd ?
    hMaskBmp    dd ?
    hMaskDC     dd ?
    hUIBmp      dd ?
    hUIDC       dd ?
    hRK1Bmp     dd ?
    hRK1DC      dd ?
    hRK2Bmp     dd ?
    hRK2DC      dd ?
    hRK3DC      dd ?
    hRK3Bmp     dd ?

SHOWMAKER ends

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
    dwWeaponType dd 0
    dwAmmunition dd ?
    hBmp        dd ?
    hDC         dd ?
    dwNxt       dd ?
    dwVeering   dd ?
    dwSpeed     dd ?
    dwBulletSpeed dd ?
    dwFireStamp dd ?

AEROCRAFT ends

BULLET struct

    dwID        dd 0
    dwAerocraftID dd ?
    dwSpeed     dd ?
    dwForward   dd ?
    dwRadius    dd ?
    stNowPos    POS <>
    dwAtk       dd ?
    hBmp        dd ?
    hDC         dd ?
    dwType      dd 0
BULLET ends



dwRandSeed      dd 0
stMain          MAIN <>
stShowMaker     SHOWMAKER <>
stAerocraft1    AEROCRAFT <>
stAerocraft2    AEROCRAFT <>
stBullets       BULLET BULLETMAXNUM dup(<>)
stExpPack       EXPPACK EXPPACKMAXNUM dup(<>)
stBulletPack    BULLETPACK BULLETPACKMAXNUM dup(<>)
stBarrier       BARRIER     BARRIERMAXNUM dup(<>)

_AerocraftLevelUp proto lpaerocraft:dword
_AerocraftGainExp proto lpaerocraft:dword, GainExp:dword
_AerocraftChangeNowHP proto lpaerocraft:dword, num:dword
_AerocraftChangeBullet proto @lpPlayer:dword, @types:dword
_MainGameOver proto ID:dword
printf		PROTO C : dword, : vararg

.const
szClassName     db      'Clock', 0
EPS             real8   0.000000001
ONEPOINTFIVE	real8	1.5
TWOPOINTFIVE	real8	2.5
.code

; printf	PROTO C : dword, : vararg

;************************************************
; 以下为一些工具函数

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

_BitMove proc uses eax edx ecx, len, dir, lpPos
        local @x:real8, @tmp, @x_step:real8, @y_step:real8
    
    mov   ecx, 10
    xor   edx, edx
    mov   eax, len
    div   ecx
    mov   len, eax

    mov   ecx, 100
    xor   edx, edx
    mov   eax, dir
    div   ecx
    mov   dir, eax

    assume ecx:ptr POS
    finit
    fldpi
    mov   @tmp, 180
    fild  @tmp
    fdiv                               ; 计算pi / 180
    fild  dir
    fmul                               ; 转换为弧度制
    fst   @x
    fsin                               ; 计算y变换
    fstp  @y_step
    fld   @x
    fcos                               ; 计算x变换
    fstp  @x_step

    finit
    mov   ecx, lpPos
    fld   @x_step
    fild  len
    fmul
    fld   [ecx].fX
    fadd                               ; 计算现在位置
    fstp  [ecx].fX

    finit
    fld   @y_step
    fild  len
    fmul
    fstp  @y_step
    fld   [ecx].fY
    fsub  @y_step
    fstp  [ecx].fY                       ;计算现在位置
    assume ecx:nothing

    ret
_BitMove endp


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
        ; 扫描经验包表
        mov    edx, 1
        lea    esi, stExpPack
        assume esi:ptr EXPPACK
        xor    ecx, ecx
        .while ecx < EXPPACKMAXNUM
            mov    eax, [esi].dwID
            .if eax != 0
                invoke _CheckCircleCross, @pos, @R, [esi].stNowPos, [esi].dwRadius
                .if eax
                    xor    edx, edx
                    .break
                .endif
            .endif
            inc    ecx
            add    esi, sizeof EXPPACK
        .endw
        assume esi:nothing

        .if edx == 0
            .continue
        .endif


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
        ; 障碍物表
        mov    edx, 1
        lea    esi, stBarrier
        assume esi:ptr BARRIER
        xor    ecx, ecx
        .while ecx < BARRIERMAXNUM
            mov    eax, [esi].dwID
            .if eax != 0
                invoke _CheckCircleCross, @pos, @R, [esi].stNowPos, [esi].dwRadius
                .if eax
                    xor    edx, edx
                    .break
                .endif
            .endif
            inc    ecx
            add    esi, sizeof BARRIER
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
; ************************************************
; 以下为障碍物相关函数
_BarrierInit   proc uses edx esi ebx ecx 
local @tmp
assume esi : ptr BARRIER
; 分配内存
mov    edx, 0
lea    esi, stBarrier
xor ecx, ecx
.while ecx < BARRIERMAXNUM
       inc    ecx
       mov    [esi].dwID,ecx
       add    esi, sizeof BARRIER
       ; 获取位置
       invoke _GetaPos, [esi].dwRadius
       mov    @tmp, eax
       fild   @tmp
       fstp[esi].stNowPos.fX
       mov    @tmp, ebx
       fild   @tmp
       fstp[esi].stNowPos.fY
       mov    eax, esi
       mov    [esi].dwRadius, INITBARRIER
       .endw
       ret
_BarrierInit endp

;*********************************************************************************
; 判断子弹是否撞上障碍物,
; 输入：addr BULLET
; 输出：eax
; *********************************************************************************
_BulletHitBarrier proc C @lpBullet
local   @output, @index
local   @Radius, @stPos:POS
local   @BerRadius, @stBerPos:POS
pushad

; 指针各值赋给局部变量值
assume  esi : ptr BULLET
mov     esi, @lpBullet

mov     eax, [esi].dwRadius
mov     @Radius, eax

finit
fld[esi].stNowPos.fX
fld[esi].stNowPos.fY
fstp    @stPos.fY
fstp    @stPos.fX

assume  esi : nothing

assume  esi : ptr BARRIER
lea     esi, stBarrier

mov     @output, 0
mov     @index, 0
.while  @index < BARRIERMAXNUM
    .if[esi].dwID == 0
            jmp @F
            .endif

            mov     eax, [esi].dwRadius
            mov     @BerRadius, eax

            finit
            fld[esi].stNowPos.fX
            fld[esi].stNowPos.fY
            fstp    @stBerPos.fY
            fstp    @stBerPos.fX

            ; 判断相交
            invoke  _CheckCircleCross, @stPos, @Radius, @stBerPos, @BerRadius
            .if     eax == 1
            mov     @output, 1
            .break
            .endif
            @@:
        mov     eax, @index
            inc     eax
            mov     @index, eax
            add     esi, sizeof BARRIER
            .endw

            assume  esi : nothing

            ; _FunReturn:
        popad
            mov     eax, @output
            ret
_BulletHitBarrier endp
;*********************************************************************************
; 判断包是否与障碍物相撞
; 输入：stPos, Radius
; 输出：eax
; *********************************************************************************
_PackHitBarrier proc C @stPos:POS, @Radius
local   @output, @index
local   @BerRadius, @stBerPos:POS
pushad

assume  esi : ptr BARRIER
lea     esi, stBarrier

mov     @output, 0
mov     @index, 0
.while  @index < BARRIERMAXNUM
    .if[esi].dwID == 0
            jmp     @F
            .endif

            mov     eax, [esi].dwRadius
            mov     @BerRadius, eax

            finit
            fld[esi].stNowPos.fX
            fld[esi].stNowPos.fY
            fstp    @stBerPos.fY
            fstp    @stBerPos.fX

            ; 判断相交
            invoke  _CheckCircleCross, @stPos, @Radius, @stBerPos, @BerRadius
            .if     eax == 1
            mov     @output, 1
            .break
            .endif

            @@:
        mov     eax, @index
            inc     eax
            mov     @index, eax
            add     esi, sizeof BARRIER
            .endw

            assume  esi : nothing

            popad
            mov     eax, @output
            ret
_PackHitBarrier endp

;************************************************
; 以下为经验包相关函数

_ExpPackInit proc uses edx esi ebx ecx, types
        local @tmp
    assume esi : ptr EXPPACK
    ; 分配内存
    mov    edx, 0
    lea    esi, stExpPack
    xor    ecx, ecx
    .while ecx < EXPPACKMAXNUM
        inc    ecx
        mov    eax, [esi].dwID
        .if eax == 0
            mov    edx, 1
            .break
        .endif
        add    esi, sizeof EXPPACK
    .endw

    .if edx == 1
        mov    [esi].dwID, ecx
    .else
        ; invoke printf, offset inputmsg1
        jmp    @F
    .endif
        ; 根据等级分配血量
    mov  testsnum, edx
    .if types == 1
        mov    [esi].dwHP, INITPACKHP1
        mov    [esi].dwType, 1
        mov    [esi].dwRadius, INITPACKR1
        mov    ebx, stShowMaker.hExpDC1
        mov    [esi].hDC, ebx

    .elseif types == 2
        mov    [esi].dwHP, INITPACKHP2
        mov    [esi].dwType, 2
        mov    [esi].dwRadius, INITPACKR2
        mov    ebx, stShowMaker.hExpDC2
        mov    [esi].hDC, ebx

    .elseif types == 3
        mov    [esi].dwHP, INITPACKHP3
        mov    [esi].dwType, 3
        mov    [esi].dwRadius, INITPACKR3
        mov    ebx, stShowMaker.hExpDC3
        mov    [esi].hDC, ebx

    .endif
    ; 获取位置
    invoke _GetaPos, [esi].dwRadius
    mov    @tmp, eax
    fild   @tmp
    fstp   [esi].stNowPos.fX
    mov    @tmp, ebx
    fild   @tmp
    fstp   [esi].stNowPos.fY
    mov    eax, esi
@@:
    assume esi : nothing
    ret
_ExpPackInit endp

_ExpPackDestroy  proc uses esi,  lpexppack
    assume esi : ptr EXPPACK
    mov    esi,lpexppack
    mov    [esi].dwID,0
    assume esi : nothing
    ret
_ExpPackDestroy endp

_ExpPackAttacked proc  uses esi, lpexppack,attack
    assume esi : ptr EXPPACK
    mov eax,attack
    mov esi, lpexppack
    sub [esi].dwHP, eax
    mov eax, [esi].dwHP
    assume esi : nothing
    ret
_ExpPackAttacked endp

;************************************************
;以下为武器包相关函数
_BulletPackInit proc C @types
        local   @tmp
    pushad
    assume esi : ptr BULLETPACK
    ; 分配内存
    mov    edx, 0
    lea    esi, stBulletPack
    xor ecx, ecx
    .while ecx < BULLETPACKMAXNUM
        inc    ecx
            mov    eax, [esi].dwID
            .if eax == 0
                mov    edx, 1
                .break
            .endif
            add    esi, sizeof BULLETPACK
    .endw

    .if edx == 1
        mov[esi].dwID, ecx
    .else; 20个满了哥
            ; invoke printf, offset inputmsg1
        jmp    endpoint
    .endif
        ; 根据等级分配血量
    push eax
    .if @types == 1
        mov[esi].dwType, 1
        mov[esi].dwRadius, INITPACKR3
        mov    eax, stShowMaker.hRK1DC
        mov[esi].hDC, eax

    .elseif @types == 2
        mov[esi].dwType, 2
        mov[esi].dwRadius, INITPACKR3
        mov    eax, stShowMaker.hRK2DC
        mov[esi].hDC, eax
    .else
        mov[esi].dwType, 3
        mov[esi].dwRadius, INITPACKR3
        mov    eax, stShowMaker.hRK3DC
        mov[esi].hDC, eax
    .endif
    pop eax
        ; 获取位置
    invoke _GetaPos, [esi].dwRadius
    finit
    mov    @tmp, eax
    fild   @tmp
    fstp[esi].stNowPos.fX
    mov    @tmp, ebx
    fild   @tmp
    fstp[esi].stNowPos.fY
    mov    eax, esi
endpoint :
    assume esi : nothing

    popad
    ret
_BulletPackInit endp


_BulletPackDestroy  proc C   @lppack
    pushad
    assume esi : ptr BULLETPACK
    mov    esi, @lppack
    mov    [esi].dwID, 0
    assume esi : nothing
    popad
    ret
_BulletPackDestroy endp

;*********************************************************************************
; 判断飞机是否与武器包相撞，输出撞eax = 1, eax = 0
; 输入：ptr 玩家@lpPlayer
; 输出：eax
; *********************************************************************************
_PlayerHitBulletPack proc C @lpPlayer
        local   @output, @index
        local   @Radius, @stPos:POS
        local   @BupRadius, @stBupPos:POS, @BupType
    pushad


    ; 指针各值赋给局部变量值
    assume  esi : ptr AEROCRAFT
    mov     esi, @lpPlayer

    mov     eax, [esi].dwRadius
    mov     @Radius, eax

    finit
    fld[esi].stNowPos.fX
    fld[esi].stNowPos.fY
    fstp    @stPos.fY
    fstp    @stPos.fX

    assume  esi : nothing

    assume  esi : ptr BULLETPACK
    lea     esi, stBulletPack

    mov     @output, 0
    mov     @index, 0
    .while  @index < BULLETPACKMAXNUM
        .if[esi].dwID == 0
            jmp     @F
        .endif

        mov     eax, [esi].dwRadius
        mov     @BupRadius, eax

        mov     eax, [esi].dwType
        mov     @BupType, eax

        finit
        fld[esi].stNowPos.fX
        fld[esi].stNowPos.fY
        fstp    @stBupPos.fY
        fstp    @stBupPos.fX

            ; 判断相交
        invoke  _CheckCircleCross, @stPos, @Radius, @stBupPos, @BupRadius
        .if     eax == 1
            mov     @output, 1

            invoke  _AerocraftChangeBullet, @lpPlayer, @BupType
            ; 析构
            invoke  _BulletPackDestroy, esi
            .break
        .endif

@@:
        mov     eax, @index
        inc     eax
        mov     @index, eax
        add     esi, sizeof EXPPACK
    .endw
    assume  esi : nothing

    popad
    mov     eax, @output
    ret
_PlayerHitBulletPack endp
;*********************************************************************************
; 判断飞机是否撞上边界
; 输入：ptr AEROCRAFT
; 输出：eax = 1撞上，eax = 0未撞上
; *********************************************************************************
_AerocraftHitWall proc C  @lpPlayer
    local   @output
    local   @Radius, @stPos:POS
    pushad
    assume  esi : ptr AEROCRAFT
    mov     esi, @lpPlayer

    mov     eax, [esi].dwRadius
    mov     @Radius, eax

    finit
    fld     [esi].stNowPos.fX
    fld     [esi].stNowPos.fY
    fstp    @stPos.fY
    fstp    @stPos.fX

    assume  esi : nothing

    invoke  _CheckCircleEdge, @stPos, @Radius
    xor eax, 1
    mov     @output, eax
    ; _FunReturn:
    popad
            mov     eax, @output
            ret
_AerocraftHitWall endp
_AerocraftChangeBullet proc  @lpPlayer, @types
    pushad

    assume  esi : ptr AEROCRAFT
    mov     esi, @lpPlayer

    mov     eax, @types
    mov[esi].dwAmmunition, eax

    assume  esi : nothing

    popad
    ret
_AerocraftChangeBullet endp
;*********************************************************************************
; 判断飞机是否与障碍物相撞，输出撞eax = 1, eax = 0
; 输入：ptr 玩家@lpPlayer
; 输出：eax
; *********************************************************************************
_PlayerHitBarrier proc C @lpPlayer
local   @output, @index
local   @Radius, @stPos:POS
local   @BerRadius, @stBerPos:POS
pushad


; 指针各值赋给局部变量值
assume  esi : ptr AEROCRAFT
mov     esi, @lpPlayer

mov     eax, [esi].dwRadius
mov     @Radius, eax

finit
fld[esi].stNowPos.fX
fld[esi].stNowPos.fY
fstp    @stPos.fY
fstp    @stPos.fX

assume  esi : nothing

assume  esi : ptr BARRIER
lea     esi, stBarrier

mov     @output, 0
mov     @index, 0
.while  @index < BARRIERMAXNUM
    .if[esi].dwID == 0
        jmp     @F
        .endif

        mov     eax, [esi].dwRadius
        mov     @BerRadius, eax

        finit
        fld[esi].stNowPos.fX
        fld[esi].stNowPos.fY
        fstp    @stBerPos.fY
        fstp    @stBerPos.fX

        ; 判断相交
        invoke  _CheckCircleCross, @stPos, @Radius, @stBerPos, @BerRadius
        .if     eax == 1
        mov     @output, 1
        .break
        .endif

        @@:
    mov     eax, @index
        inc     eax
        mov     @index, eax
        add     esi, sizeof BARRIER
        .endw

        assume  esi : nothing

        popad
        mov     eax, @output
        ret
_PlayerHitBarrier endp
;************************************************
;以下为子弹类相关函数


; *********************************************************************************
; 首先判断是否命中。若未命中返回0，命中返回1。命中的话，返回
; 输入：addr BULLET
; 输出：eax
; *********************************************************************************
_BulletHitWall proc uses esi, @lpBullet
    local   @output, @AerocraftID
    local   @Radius, @stPos:POS
    ; assume  esi: ptr STRUCT

    
    ; 指针各值赋给局部变量值
    assume  esi: ptr BULLET
    mov     esi, @lpBullet

    mov     eax, [esi].dwAerocraftID
    mov     @AerocraftID, eax

    mov     eax, [esi].dwRadius
    mov     @Radius, eax

    finit
    fld     [esi].stNowPos.fX
    fld     [esi].stNowPos.fY
    fstp    @stPos.fY
    fstp    @stPos.fX

    assume  esi: nothing
    
    invoke  _CheckCircleEdge, @stPos, @Radius
    xor     eax     ,1
    mov     @output, eax

    ; assume  esi: nothing
; _FunReturn:
    mov     eax, @output
    ret
_BulletHitWall endp

_BulletHitPlayer proc C @lpBullet
local   @output
local   @tmp
local   @Type, @atk, @AerocraftID, @Radius, @stPos:POS
local   @lpEnemy, @EnemyHP, @EnemyRadius, @stEnemyPos:POS
pushad

; 指针各值赋给局部变量值
assume  esi : ptr BULLET
mov     esi, @lpBullet

mov     eax, [esi].dwType
mov     @Type, eax

mov     eax, [esi].dwAtk
.if      @Type == 2
finit
mov     @tmp, eax
fild    @tmp
fld    ONEPOINTFIVE
fmul
fist    @tmp
mov     eax, @tmp
.endif
mov     @atk, eax

mov     eax, [esi].dwAerocraftID
mov     @AerocraftID, eax
.if     @AerocraftID == 1
lea     eax, stAerocraft2
mov     @lpEnemy, eax
.else
lea     eax, stAerocraft1
mov     @lpEnemy, eax
.endif

mov     eax, [esi].dwRadius
.if      @Type == 3
finit
mov     @tmp, eax
fild    @tmp
fld    TWOPOINTFIVE
fmul
fist    @tmp
mov     eax, @tmp
.endif
mov     @Radius, eax

finit
fld[esi].stNowPos.fX
fld[esi].stNowPos.fY
fstp    @stPos.fY
fstp    @stPos.fX

assume  esi : nothing

assume  esi : ptr AEROCRAFT
mov     esi, @lpEnemy

mov     eax, [esi].dwHP
mov     @EnemyHP, eax

mov     eax, [esi].dwRadius
mov     @EnemyRadius, eax

finit
fld[esi].stNowPos.fX
fld[esi].stNowPos.fY
fstp    @stEnemyPos.fY
fstp    @stEnemyPos.fX

assume  esi : nothing

; 判断相交
invoke  _CheckCircleCross, @stPos, @Radius, @stEnemyPos, @EnemyRadius
.if     eax == 1; 相交即命中
    mov     @output, 1
    mov     eax, @EnemyHP
    sub     eax, @atk
    .if     eax == 0||eax>80000000h
        invoke  _MainGameOver ,@AerocraftID
    .else
        mov eax,0
        sub eax,@atk
        mov @atk,eax
        mov  @AerocraftID,eax
       invoke  _AerocraftChangeNowHP,@lpEnemy,@atk;, 谁扣血, 扣多少血@atk
    .endif
.else
     mov     @output, 0
.endif

popad
mov     eax, @output
ret
_BulletHitPlayer endp


_BulletHitExp proc uses esi, @lpBullet
    local   @output, @index 
    local   @atk, @AerocraftID, @Radius, @stPos:POS
    local   @ExpHP, @ExpRadius, @stExpPos:POS
    local   @Exp,@tmp

    ; 指针各值赋给局部变量值
    assume  esi: ptr BULLET
    mov     esi, @lpBullet

    mov     eax, [esi].dwAtk
    mov     @atk, eax

    mov     eax, [esi].dwAerocraftID
    mov     @AerocraftID, eax

    mov     eax, [esi].dwRadius
    mov     @Radius, eax

    finit
    fld     [esi].stNowPos.fX
    fld     [esi].stNowPos.fY
    fstp    @stPos.fY
    fstp    @stPos.fX

    assume  esi: nothing
    
    assume  esi: ptr EXPPACK
    lea     esi, stExpPack

    mov     @output, 0
    mov     @index, 0
    .while  @index < EXPPACKMAXNUM
        .if     [esi].dwID == 0
            jmp @F 
        .endif
        mov     eax, [esi].dwHP
        mov     @ExpHP, eax

        mov     eax, [esi].dwRadius
        mov     @ExpRadius, eax

        finit
        fld     [esi].stNowPos.fX
        fld     [esi].stNowPos.fY
        fstp    @stExpPos.fY
        fstp    @stExpPos.fX

        ; 判断相交
        invoke  _CheckCircleCross, @stPos, @Radius, @stExpPos, @ExpRadius
        .if     eax == 1
            mov     @output, 1
            
            mov     eax, @ExpHP
            sub     eax, @atk
            sub     eax,1
            AND     eax,80000000h
            .if   eax == 80000000h
                mov @tmp, eax
                invoke printf, addr msg4, @tmp
                mov eax, @tmp
                ; 爆经验力
                .if     [esi].dwType == 1
                    mov     @Exp, INITPACKEXP1
                .elseif     [esi].dwType == 2
                    mov     @Exp, INITPACKEXP2
                .else
                    mov     @Exp, INITPACKEXP3
                .endif
                push esi
                push eax
                .if @AerocraftID==1
                    lea eax, stAerocraft1
                .else
                    lea eax, stAerocraft2
                .endif
                invoke  _AerocraftGainExp, eax, @Exp
                ; 析构
                pop eax
                pop esi
                invoke  _ExpPackDestroy, esi
            .else
                invoke  _ExpPackAttacked, esi, @atk
            .endif
            .break
        .endif
@@:
        mov     eax, @index
        inc     eax
        mov     @index, eax
        add     esi, sizeof EXPPACK
    .endw
    assume  esi: nothing

; _FunReturn:
    mov     eax, @output
    ret
_BulletHitExp endp

_BulletDestroy  proc uses esi, lpbullet
    assume esi : ptr BULLET
    mov    esi, lpbullet
    mov    [esi].dwID,0
    assume esi : nothing
    ret
_BulletDestroy endp

_BulletInit proc uses edx esi ebx ecx edi, lpAerocraft
        local @hDC
    
    assume esi : ptr BULLET
    ; 分配内存
    mov    edx, 0
    lea    esi, stBullets
    xor    ecx, ecx
    .while ecx < BULLETMAXNUM
        inc    ecx
        mov    eax, [esi].dwID
        .if eax == 0
            mov    edx, 1
            .break
        .endif
        add    esi, sizeof BULLET
    .endw

    .if edx == 1
        mov    [esi].dwID, ecx
    .else
        jmp    endpoint
    .endif

    ; 设置各样属性
    assume edi:ptr AEROCRAFT
    mov    edi, lpAerocraft

    mov    eax, [edi].dwID
    mov    [esi].dwAerocraftID, eax
    mov    eax, [edi].dwBulletSpeed
    mov    [esi].dwSpeed, eax
    mov    eax, [edi].dwForward
    mov    [esi].dwForward, eax
    mov    eax, [edi].dwAtk
    mov    [esi].dwAtk, eax 
    mov    eax, [edi].dwCaliber
    mov    [esi].dwRadius, eax

    finit
    fld    [edi].stNowPos.fX
    fstp   [esi].stNowPos.fX
    fld    [edi].stNowPos.fY
    fstp   [esi].stNowPos.fY

    assume edi:nothing


    mov    eax,esi
endpoint:
    assume esi : nothing

    ret
_BulletInit endp



_BulletHitCheck proc C @lpBullet
local  @output
pushad
; assume  esi : ptr BULLET
; mov     esi, @lpBullet
; assume  esi : nothing

mov     @output, 0

invoke  _BulletHitPlayer, @lpBullet
mov      @output, eax
.if     @output == 1
invoke  _BulletDestroy, @lpBullet; 注意格式
jmp     _BulletHitCheckReturn
.endif

invoke  _BulletHitExp, @lpBullet
mov      @output, eax
.if     @output == 1
invoke  _BulletDestroy, @lpBullet
jmp     _BulletHitCheckReturn
.endif

invoke  _BulletHitWall, @lpBullet
mov      @output, eax
.if     @output == 1
invoke  _BulletDestroy, @lpBullet
jmp     _BulletHitCheckReturn
.endif

invoke  _BulletHitBarrier, @lpBullet
mov      @output, eax
.if     @output == 1
invoke  _BulletDestroy, @lpBullet
jmp     _BulletHitCheckReturn
.endif

_BulletHitCheckReturn :

    popad
        mov     eax, @output

        ret
        _BulletHitCheck endp


_BulletMove proc uses  esi ecx ebx , lpbullet
    inc dwBulletSpeedlimit
    mov eax, dwBulletSpeedlimit
    .if eax>=30
        mov dwBulletSpeedlimit,0
        ret
    .endif
    assume esi : ptr BULLET
    mov    esi, lpbullet
    mov    ecx, [esi].dwSpeed
    mov    ebx, 10
    xor    eax, eax
    .while ecx!=0
        dec    ecx
        invoke _BitMove , ebx, [esi].dwForward, addr [esi].stNowPos
        invoke _BulletHitCheck ,esi
        .if eax == 1
            .break
        .endif
    .endw
    ret

_BulletMove endp

;************************************************
; 以下为飞机类相关函数

_AerocraftChangeNowHP proc uses eax esi, lpaerocraft,num
	assume	esi : ptr AEROCRAFT
	mov		esi	, lpaerocraft
	mov     eax	, num
	add		eax	, [esi].dwHP
	.if     eax	> [esi].dwMaxHP
		mov    eax	, [esi].dwMaxHP
	.endif
	mov		[esi].dwHP	,eax
	assume	esi : nothing
	ret
_AerocraftChangeNowHP  endp

_AerocraftChangeMAXNowHP proc uses eax esi, lpaerocraft, num
    assume	esi : ptr AEROCRAFT
    mov		esi, lpaerocraft
    mov     eax, num
    add		[esi].dwMaxHP, eax
    assume	esi : nothing
    ret
_AerocraftChangeMAXNowHP  endp

_AerocraftChangeAtk proc uses eax esi, lpaerocraft, num
    assume	esi : ptr AEROCRAFT
    mov		esi, lpaerocraft
    mov     eax, num
    add		[esi].dwAtk, eax
    assume	esi : nothing
    ret
_AerocraftChangeAtk  endp

_AerocraftGainExp proc uses esi ecx  ebx, lpaerocraft,GainExp
    assume	esi : ptr AEROCRAFT
    mov		esi			, lpaerocraft
    mov		ecx			, GainExp
    add		[esi].dwExp	,ecx
    mov     ecx			, [esi].dwLevel
    mov		ebx         , [esi].dwExp
    xor		eax         , eax
    .if		ecx==0
        .if ebx>=50
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,50
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==1
        .if ebx>=75
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,75
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==2
        .if ebx>=100
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,100
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==3
        .if ebx>=100
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,100
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==4
        .if ebx>=100
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,100
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==5
        .if ebx>=100
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,100
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==6
        .if ebx>=125
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,125
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==7
        .if ebx>=125
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,125
            mov		[esi].dwExp	,ebx
        .endif
    .elseif ecx==8
        .if ebx>=125
            mov		eax			,1
            invoke	_AerocraftLevelUp   ,esi
            sub		ebx			,125
            mov		[esi].dwExp	,ebx
        .endif
    .endif
    assume	esi : nothing
    ret
_AerocraftGainExp	endp

_AerocraftLevelUp proc uses esi eax ,lpaerocraft
    assume	esi : ptr AEROCRAFT
    mov		esi, lpaerocraft
    inc     [esi].dwLevel
    mov     eax, 100
    add     [esi].dwMaxHP,eax
    add     [esi].dwHP, eax
    add[esi].dwAtk, eax
    assume	esi : nothing
    ret
_AerocraftLevelUp    endp

_AerocraftVeer proc
    local forward

    mov    eax, stAerocraft1.dwForward
    mov    forward, eax
    .if stAerocraft1.dwVeering == 1
        add    forward , 36000
        sub    forward, DEFAULTW
        invoke _mod, forward, 36000
        mov    stAerocraft1.dwForward, eax
    .elseif stAerocraft1.dwVeering == 2
        add    forward, DEFAULTW
        invoke _mod, forward, 36000
        mov    stAerocraft1.dwForward, eax
    .endif
    mov    stAerocraft1.dwVeering, 0



    mov    eax, stAerocraft2.dwForward
    mov    forward, eax
    .if stAerocraft2.dwVeering == 1
        add    forward, 36000
        sub    forward, DEFAULTW
        invoke _mod, forward, 36000
        mov    stAerocraft2.dwForward, eax
    .elseif stAerocraft2.dwVeering == 2
        add    forward, DEFAULTW
        invoke _mod, forward, 36000
        mov    stAerocraft2.dwForward, eax
    .endif
        mov    stAerocraft2.dwVeering, 0

ret
_AerocraftVeer  endp

_AerocraftMove proc uses esi eax, lpAerocraft
        local forward

    assume esi:ptr AEROCRAFT

    mov    esi, lpAerocraft
    .if [esi].dwNxt == 0
        ret
    .endif
    
    
    mov    eax, [esi].dwForward
    mov    forward, eax
    .if [esi].dwNxt == 3
        mov    forward, 18000
    .elseif [esi].dwNxt == 4
        mov    forward, 0
     .elseif[esi].dwNxt == 2
            mov    forward, 9000
    .elseif [esi].dwNxt == 1
        mov    forward, 27000
    .endif
    invoke _BitMove, [esi].dwSpeed, forward, addr [esi].stNowPos
    mov    [esi].dwNxt, 0
    invoke	_AerocraftHitWall, esi
    ; 撤回此次移动
    .if eax == 1
        add     forward, 18000
        invoke  _mod, forward, 36000
        mov     forward, eax
        invoke _BitMove, [esi].dwSpeed, forward, addr[esi].stNowPos
        .endif
    invoke _PlayerHitBarrier ,esi
        .if eax == 1
            add     forward, 18000
            invoke  _mod, forward, 36000
            mov     forward, eax
            invoke _BitMove, [esi].dwSpeed, forward, addr[esi].stNowPos
        .endif
    assume esi:nothing
    ret

_AerocraftMove endp

_AerocraftInit proc
        local @tmp

    mov    stAerocraft1.dwMaxHP, INITHP
    mov    stAerocraft2.dwMaxHP, INITHP
    mov    stAerocraft1.dwHP, INITHP
    mov    stAerocraft2.dwHP, INITHP
    mov    stAerocraft1.dwRadius, INITR
    mov    stAerocraft2.dwRadius, INITR
    mov    stAerocraft1.dwForward, 9000
    mov    stAerocraft2.dwForward, 9000
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
    mov    stAerocraft1.dwSpeed, INITPLANESPEED
    mov    stAerocraft2.dwSpeed, INITPLANESPEED
    mov    stAerocraft1.dwBulletSpeed, INITBULLETSPEED
    mov    stAerocraft2.dwBulletSpeed, INITBULLETSPEED
    mov    stAerocraft1.dwFireStamp, 0
    mov    stAerocraft2.dwFireStamp, 0
    mov    stAerocraft1.dwVeering, 0
    mov    stAerocraft2.dwVeering, 0

    ; 分别初始化位置
    invoke _GetaPos, stAerocraft1.dwRadius
    mov    @tmp, eax
    fild   @tmp
    fstp   stAerocraft1.stNowPos.fX
    mov    @tmp, ebx
    fild   @tmp
    fstp   stAerocraft1.stNowPos.fY
    mov    stAerocraft1.dwID, 1

    invoke _GetaPos, stAerocraft2.dwRadius
    mov    @tmp, eax
    fild   @tmp
    fstp   stAerocraft2.stNowPos.fX
    mov    @tmp, ebx
    fild   @tmp
    fstp   stAerocraft2.stNowPos.fY
    mov    stAerocraft2.dwID, 2

    ret
_AerocraftInit endp

_AerocraftFire proc uses esi ebx,lpAerocraft
    local @forward:dword
    assume  esi : ptr AEROCRAFT
    mov     esi, lpAerocraft
    .if [esi].dwWeaponType==0
        invoke  _BulletInit, esi
    .elseif [esi].dwWeaponType == 1
        invoke  _BulletInit, esi
        mov ebx, [esi].dwForward
        mov @forward,ebx
        add @forward,18000
        invoke _mod, @forward, 36000
        mov [esi].dwForward,eax
        invoke  _BulletInit, esi
        mov[esi].dwForward, ebx
    .elseif[esi].dwWeaponType == 2
        invoke  _BulletInit, esi
        mov ebx, [esi].dwForward
        mov @forward, ebx
        add @forward, 9000
        invoke _mod, @forward, 36000
        mov[esi].dwForward, eax
        invoke  _BulletInit, esi
        mov @forward, ebx
        add @forward, 18000
        invoke _mod, @forward, 36000
        mov[esi].dwForward, eax
        invoke  _BulletInit, esi
        mov @forward, ebx
        add @forward, 27000
        invoke _mod, @forward, 36000
        mov[esi].dwForward, eax
        invoke  _BulletInit, esi
        mov[esi].dwForward, ebx
    .endif
    assume  esi : nothing
    ret
_AerocraftFire  endp

_MainInit proc

    mov    stMain.dwExpStamp, 0
    mov    stMain.dwWeaponStamp, 0

    invoke _RandSetSeed
    invoke _BarrierInit
    invoke _AerocraftInit


    ret
_MainInit endp

_ShowMakerDestroy proc

    invoke KillTimer, hWinMain, ID_TIMER
    invoke DestroyWindow, hWinMain
    invoke PostQuitMessage, NULL

    ; 删除>>>>>
    invoke DeleteDC, stAerocraft1.hDC
    invoke DeleteDC, stAerocraft2.hDC
    invoke DeleteDC, stShowMaker.hFinalDC
    invoke DeleteDC, stShowMaker.hBulletDC1
    invoke DeleteDC, stShowMaker.hBulletDC2
    invoke DeleteDC, stShowMaker.hExpDC1
    invoke DeleteDC, stShowMaker.hExpDC2
    invoke DeleteDC, stShowMaker.hExpDC3
    invoke DeleteDC, stShowMaker.hBarrierDC
    invoke DeleteDC, stShowMaker.hMaskDC
    invoke DeleteDC, stShowMaker.hUIDC
    invoke DeleteDC, stShowMaker.hRK1DC
    invoke DeleteDC, stShowMaker.hRK2DC
    invoke DeleteDC, stShowMaker.hRK3DC
    invoke DeleteObject, stShowMaker.hBmpFinal
    invoke DeleteObject, stAerocraft1.hBmp
    invoke DeleteObject, stAerocraft2.hBmp
    invoke DeleteObject, stShowMaker.hBulletBmp1
    invoke DeleteObject, stShowMaker.hBulletBmp2
    invoke DeleteObject, stShowMaker.hExpBmp1
    invoke DeleteObject, stShowMaker.hExpBmp2
    invoke DeleteObject, stShowMaker.hExpBmp3
    invoke DeleteObject, stShowMaker.hBarrierBmp
    invoke DeleteObject, stShowMaker.hMaskBmp
    invoke DeleteObject, stShowMaker.hUIBmp
    invoke DeleteObject, stShowMaker.hRK1Bmp
    invoke DeleteObject, stShowMaker.hRK2Bmp
    invoke DeleteObject, stShowMaker.hRK3Bmp
    ; <<<<<删除完成

    ret
_ShowMakerDestroy endp

_ShowMakerShowBarrier proc uses eax ecx esi
        local @x, @y, @D

    assume esi:ptr BARRIER
    xor    ecx, ecx
    lea    esi, stBarrier
    .while ecx < BARRIER
        inc    ecx
        push   ecx
        .if [esi].dwID == 0
            jmp @F
        .endif
        finit
        mov    eax, [esi].dwRadius
        mov    @D, eax
        add    @D, eax
        fld    [esi].stNowPos.fX
        fist   @x
        fld    [esi].stNowPos.fY
        fist   @y
        mov    eax, [esi].dwRadius
        sub    @x, eax
        sub    @y, eax
        invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, stShowMaker.hBarrierDC, 0, 0, BARRIERBMPHIDTH, BARRIERBMPWIDTH, SRCAND
@@:
        add    esi, sizeof BARRIER
        pop    ecx

    .endw
    assume esi:nothing
    ret

_ShowMakerShowBarrier endp

_ShowMakerFirstPaint proc uses eax
        local @hDC
        local @x, @y, @D
    
    invoke GetDC, hWinMain
    mov    @hDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hFinalDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stAerocraft1.hDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stAerocraft2.hDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hBulletDC1, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hBulletDC2, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hExpDC1, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hExpDC2, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hExpDC3, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hMaskDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hBarrierDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hUIDC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hRK1DC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hRK2DC, eax
    invoke CreateCompatibleDC, @hDC
    mov    stShowMaker.hRK3DC, eax
    invoke CreateCompatibleBitmap, @hDC, WINDOW_HIDTH, WINDOW_WIDTH
    mov    stShowMaker.hBmpFinal, eax
    invoke ReleaseDC, hWinMain, @hDC

    invoke LoadBitmap, hInstance, IDB_BACK
    mov    stShowMaker.hBmpBack, eax
    invoke LoadBitmap, hInstance, IDB_PLANE
    mov    stAerocraft1.hBmp, eax
    invoke LoadBitmap, hInstance, IDB_PLANE2
    mov    stAerocraft2.hBmp, eax
    invoke LoadBitmap, hInstance, IDB_BULLET
    mov    stShowMaker.hBulletBmp1, eax
    invoke LoadBitmap, hInstance, IDB_BULLET2
    mov    stShowMaker.hBulletBmp2, eax
    invoke LoadBitmap, hInstance, IDB_EXP
    mov    stShowMaker.hExpBmp1, eax
    invoke LoadBitmap, hInstance, IDB_EXP
    mov    stShowMaker.hExpBmp2, eax
    invoke LoadBitmap, hInstance, IDB_EXP
    mov    stShowMaker.hExpBmp3, eax
    invoke LoadBitmap, hInstance, IDB_BRRIER
    mov    stShowMaker.hBarrierBmp, eax
    invoke LoadBitmap, hInstance, IDB_UI
    mov    stShowMaker.hUIBmp, eax
    invoke LoadBitmap, hInstance, IDB_MASK
    mov    stShowMaker.hMaskBmp, eax
    invoke LoadBitmap, hInstance, IDB_RK1
    mov    stShowMaker.hRK1Bmp, eax
    invoke LoadBitmap, hInstance, IDB_RK2
    mov    stShowMaker.hRK2Bmp, eax
    invoke LoadBitmap, hInstance, IDB_RK3
    mov    stShowMaker.hRK3Bmp, eax

    invoke SelectObject, stAerocraft1.hDC, stAerocraft1.hBmp
    invoke SelectObject, stAerocraft2.hDC, stAerocraft2.hBmp
    invoke SelectObject, stShowMaker.hFinalDC, stShowMaker.hBmpFinal
    invoke SelectObject, stShowMaker.hBulletDC1, stShowMaker.hBulletBmp1
    invoke SelectObject, stShowMaker.hBulletDC2, stShowMaker.hBulletBmp2
    invoke SelectObject, stShowMaker.hExpDC1, stShowMaker.hExpBmp1
    invoke SelectObject, stShowMaker.hExpDC2, stShowMaker.hExpBmp2
    invoke SelectObject, stShowMaker.hExpDC3, stShowMaker.hExpBmp3
    invoke SelectObject, stShowMaker.hBarrierDC, stShowMaker.hBarrierBmp
    invoke SelectObject, stShowMaker.hMaskDC, stShowMaker.hMaskBmp
    invoke SelectObject, stShowMaker.hUIDC, stShowMaker.hUIBmp
    invoke SelectObject, stShowMaker.hRK1DC, stShowMaker.hRK1Bmp
    invoke SelectObject, stShowMaker.hRK2DC, stShowMaker.hRK2Bmp
    invoke SelectObject, stShowMaker.hRK3DC, stShowMaker.hRK3Bmp


    ; 绘制背景
    invoke CreatePatternBrush, stShowMaker.hBmpBack
    invoke SelectObject, stShowMaker.hFinalDC, eax
    invoke PatBlt, stShowMaker.hFinalDC, 0, 0, WINDOW_HIDTH, WINDOW_WIDTH, PATCOPY
    invoke DeleteObject, eax

    ; 绘制UI
    invoke BitBlt, stShowMaker.hFinalDC, 0, MAP_WIDTH, UIBMPHIDTH, MAP_WIDTH + UIBMPWIDTH, stShowMaker.hUIDC, 0, 0, SRCAND


    ; 放缩图片
    ; invoke StretchBlt, @htmp1DC, 0, 0, @D, @D, stAerocraft1.hDC, 0, 0, 150, 150, SRCAND

    ; invoke TransparentBlt, hFinalDC, 0, 0, CLOCK_SIZE, CLOCK_SIZE, @hDCCircle, 0, 0, CLOCK_SIZE, CLOCK_SIZE, 0
    
    ; 绘制障碍物
    invoke _ShowMakerShowBarrier

    finit
    ; 绘制飞机1
    mov    eax, stAerocraft1.dwRadius
    mov    @D, eax
    add    @D, eax
    fld    stAerocraft1.stNowPos.fX
    fist   @x
    fld    stAerocraft1.stNowPos.fY
    fist   @y 
    mov    eax, stAerocraft1.dwRadius
    sub    @x, eax
    sub    @y, eax
    invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, stAerocraft1.hDC, 0, 0, PLANEBMPHIDTH, PLANEBMPWIDTH, SRCAND
    ; invoke BitBlt, @x, @y, @D, @D, 0, 0, @D, @D, SRCAND
    ; invoke TransparentBlt, stShowMaker.hFinalDC, @x, @y, MAP_HIDTH, MAP_WIDTH, @htmp1DC, 0, 0, @D, @D, 0

    ; 绘制飞机2
    mov    eax, stAerocraft2.dwRadius
    mov    @D, eax
    add    @D, eax
    fld    stAerocraft2.stNowPos.fX
    fist   @x
    fld    stAerocraft2.stNowPos.fY
    fist   @y 
    mov    eax, stAerocraft2.dwRadius
    sub    @x, eax
    sub    @y, eax
    invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, stAerocraft2.hDC, 0, 0, PLANEBMPHIDTH, PLANEBMPWIDTH, SRCAND


    ret
_ShowMakerFirstPaint endp

_ShowMakerPaint proc uses eax ecx esi
        local @hDC
        local @x, @y, @D


    ; 绘制背景
    invoke CreatePatternBrush, stShowMaker.hBmpBack
    invoke SelectObject, stShowMaker.hFinalDC, eax
    invoke PatBlt, stShowMaker.hFinalDC, 0, 0, WINDOW_HIDTH, WINDOW_WIDTH, PATCOPY
    ; invoke PatBlt, stShowMaker.hFinalDC,  0, MAP_WIDTH, UIBMPHIDTH, MAP_WIDTH + UIBMPWIDTH, PATCOPY
    invoke DeleteObject, eax

    ; 绘制UI
    invoke BitBlt, stShowMaker.hFinalDC, 0, MAP_WIDTH, WINDOW_HIDTH, WINDOW_WIDTH, stShowMaker.hUIDC, 0, 0, SRCAND
    invoke wsprintf, addr msgtmp, addr msg5, stAerocraft1.dwLevel
    invoke TextOut, stShowMaker.hFinalDC, 40, MAP_WIDTH + 40, addr msgtmp, 7
    invoke wsprintf, addr msgtmp, addr msg6, stAerocraft1.dwHP, stAerocraft1.dwMaxHP
    invoke TextOut, stShowMaker.hFinalDC, 40, MAP_WIDTH + 85, addr msgtmp, eax
    invoke wsprintf, addr msgtmp, addr msg7, stAerocraft1.dwExp
    invoke TextOut, stShowMaker.hFinalDC, 40, MAP_WIDTH + 130, addr msgtmp, eax
    invoke wsprintf, addr msgtmp, addr msg5, stAerocraft2.dwLevel
    invoke TextOut, stShowMaker.hFinalDC, 740, MAP_WIDTH + 40, addr msgtmp, 7
    invoke wsprintf, addr msgtmp, addr msg6, stAerocraft2.dwHP, stAerocraft2.dwMaxHP
    invoke TextOut, stShowMaker.hFinalDC, 740, MAP_WIDTH + 85, addr msgtmp, eax
    invoke wsprintf, addr msgtmp, addr msg7, stAerocraft2.dwExp
    invoke TextOut, stShowMaker.hFinalDC, 740, MAP_WIDTH + 130, addr msgtmp, eax


    ; 绘制障碍物
    invoke _ShowMakerShowBarrier

    ; 绘制子弹
    assume esi:ptr BULLET
    xor    ecx, ecx
    lea    esi, stBullets
    .while ecx < BULLETMAXNUM
        inc    ecx
        push   ecx
        .if [esi].dwID == 0
            jmp @F
        .endif

        finit
        mov    eax, [esi].dwRadius
        mov    @D, eax
        add    @D, eax
        fld    [esi].stNowPos.fX
        fist   @x
        fld    [esi].stNowPos.fY
        fist   @y
        mov    eax, [esi].dwRadius
        sub    @x, eax
        sub    @y, eax
        .if [esi].dwAerocraftID == 1
            invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, stShowMaker.hBulletDC1, 0, 0, BULLETBMPHIDTH, BULLETBMPWIDTH, SRCAND
        .endif
        .if [esi].dwAerocraftID == 2
            invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, stShowMaker.hBulletDC2, 0, 0, BULLETBMPHIDTH, BULLETBMPWIDTH, SRCAND
        .endif
@@:
        add    esi, sizeof BULLET
        pop    ecx

    .endw
    assume esi:nothing

    ; 绘制经验包
    assume esi:ptr EXPPACK
    lea    esi, stExpPack
    xor    ecx, ecx
    .while ecx < EXPPACKMAXNUM
        mov    eax, [esi].dwID; 调试用
        inc    ecx
        push   ecx
        .if [esi].dwID == 0
            jmp @F
        .endif
        ;测试用
        push eax
        xor eax,eax
        .if testsnum!=eax
            invoke printf,addr msg3
        .endif
        pop eax
        finit
        mov    eax, [esi].dwRadius
        mov    @D, eax
        add    @D, eax
        fld    [esi].stNowPos.fX
        fist   @x
        fld    [esi].stNowPos.fY
        fist   @y
        mov    eax, [esi].dwRadius
        sub    @x, eax
        sub    @y, eax
        push   ecx
        invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, [esi].hDC, 0, 0, EXPBMPHIDTH, EXPBMPWIDTH, SRCAND
        pop    ecx
    @@:
        add    esi, sizeof EXPPACK
        pop    ecx
    .endw
;测试用
    push eax
    mov eax ,0
    mov testsnum,eax
    pop eax
    assume esi:nothing

    ; 绘制弹药包
    assume esi:ptr BULLETPACK
    lea    esi, stBulletPack
    xor    ecx, ecx
    .while ecx < BULLETPACKMAXNUM
        mov    eax, [esi].dwID
        inc    ecx
        push   ecx
        .if [esi].dwID == 0
            jmp @F
        .endif

        finit
        mov    eax, [esi].dwRadius
        mov    @D, eax
        add    @D, eax
        fld    [esi].stNowPos.fX
        fist   @x
        fld    [esi].stNowPos.fY
        fist   @y
        mov    eax, [esi].dwRadius
        sub    @x, eax
        sub    @y, eax
        push   ecx
        invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, [esi].hDC, 0, 0, 100, 100, SRCAND
        pop    ecx
    @@:
        add    esi, sizeof BULLETPACK
        pop    ecx
    .endw

    assume esi:nothing

    
    ; 绘制飞机1
    finit
    mov    eax, stAerocraft1.dwRadius
    mov    @D, eax
    add    @D, eax
    fld    stAerocraft1.stNowPos.fX
    fist   @x
    fld    stAerocraft1.stNowPos.fY
    fist   @y
    mov    eax, stAerocraft1.dwRadius
    sub    @x, eax
    sub    @y, eax
    invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, stAerocraft1.hDC, 0, 0, PLANEBMPHIDTH, PLANEBMPWIDTH, SRCAND


    ; 绘制飞机2
    mov    eax, stAerocraft2.dwRadius
    mov    @D, eax
    add    @D, eax
    fld    stAerocraft2.stNowPos.fX
    fist   @x
    fld    stAerocraft2.stNowPos.fY
    fist   @y
    mov    eax, stAerocraft2.dwRadius
    sub    @x, eax
    sub    @y, eax
    invoke StretchBlt, stShowMaker.hFinalDC, @x, @y, @D, @D, stAerocraft2.hDC, 0, 0, PLANEBMPHIDTH, PLANEBMPWIDTH, SRCAND


    ret
_ShowMakerPaint endp

_ShowMakerInit proc

    ; 创建窗口
    invoke SetWindowRgn, hWinMain, eax, TRUE
    invoke SetWindowPos, hWinMain, HWND_TOP, 40, 40, 0, 0, SWP_NOMOVE OR SWP_NOSIZE


    invoke _ShowMakerFirstPaint

    invoke SetTimer, hWinMain, ID_TIMER, 20, NULL

    ret
_ShowMakerInit endp

_MainGameOver proc ID

    invoke wsprintf, addr msgtmp, addr msg8, ID
    invoke MessageBox, hWinMain, addr msgtmp, addr msg9, MB_OK
    invoke ExitProcess, NULL
    
_MainGameOver endp

_MainKeyboard proc
        local @outs:dword
    invoke GetKeyState, 'W'
    .if ah
    mov    stAerocraft1.dwNxt, 2
    .endif

    invoke GetKeyState, 'S'
    .if ah
    mov    stAerocraft1.dwNxt, 1
    .endif

    invoke GetKeyState, 'A'
    .if ah
    mov    stAerocraft1.dwNxt, 3
    .endif

    invoke GetKeyState, 'D'
    .if ah
    mov    stAerocraft1.dwNxt, 4
    .endif

    invoke GetKeyState, 'I'
    .if ah
    mov    stAerocraft2.dwNxt, 2
    .endif

    invoke GetKeyState, 'K'
    .if ah
    mov    stAerocraft2.dwNxt, 1
    .endif

    invoke GetKeyState, 'J'
    .if ah
    mov    stAerocraft2.dwNxt, 3
    .endif

    invoke GetKeyState, 'L'
    .if ah
    mov    stAerocraft2.dwNxt, 4
    .endif

    invoke GetKeyState, 'Q'
    .if ah
    mov    stAerocraft1.dwVeering, 2
    .endif

    invoke GetKeyState, 'E'
    .if ah
    mov    stAerocraft1.dwVeering, 1
    .endif

    invoke GetKeyState, 'U'
    .if ah
    mov    stAerocraft2.dwVeering, 2
    .endif

    invoke GetKeyState, 'O'
    .if ah
    mov    stAerocraft2.dwVeering, 1
    .endif

    ret
_MainKeyboard endp

_MainFrame proc uses eax esi ecx
    local @tmp
    ;发射子弹
     ;inc    dwAttackSpeed
     ;mov    eax, 10
     ;.if    eax < dwAttackSpeed
     ;   invoke _AerocraftFire, addr stAerocraft1
     ;    invoke _AerocraftFire, addr stAerocraft2
     ;    invoke printf, addr msg1
     ;   mov    eax, 0
     ;   mov    dwAttackSpeed, eax
     ;.endif
    inc    stAerocraft1.dwFireStamp
    mov    eax, stAerocraft1.dwAtf
    .if stAerocraft1.dwFireStamp >= eax
        mov    stAerocraft1.dwFireStamp, 0
        invoke _AerocraftFire, addr stAerocraft1
    .endif

    inc    stAerocraft2.dwFireStamp
    mov    eax, stAerocraft2.dwAtf
    .if stAerocraft2.dwFireStamp >= eax
        mov    stAerocraft2.dwFireStamp, 0
        invoke _AerocraftFire, addr stAerocraft2
    .endif

    ;移动子弹
    assume esi:ptr BULLET
    lea    esi, stBullets
    xor    ecx, ecx
    .while ecx < BULLETMAXNUM
        inc    ecx
        mov    eax, [esi].dwID
        .if eax != 0
            invoke _BulletMove ,esi
        .endif
        add    esi, sizeof BULLET
    .endw
    assume esi :nothing

    ;生成经验包
    ; inc    stMain.dwExpStamp
    ; .if stMain.dwExpStamp >= EXPPACKGANFRE
        mov    stMain.dwExpStamp, 0
        
        mov    eax, 500
        invoke  _RandGet
        .if  eax<2
            mov eax,0
            invoke _RandSetSeed
            mov    eax, 100
            invoke  _RandGet
            .if eax<10
                mov    eax, 3
            .elseif eax<40
                mov    eax, 2
            .else
                mov    eax, 1
            .endif
            push   eax
            invoke printf, addr msg2
            pop    eax
            invoke _ExpPackInit, eax
        .endif
    ; .endif
     ; 武器包生成
        mov    eax, 1000
        invoke  _RandGet
        .if  eax < 2
            mov eax, 0
            invoke _RandSetSeed
            mov    eax, 100
            invoke  _RandGet
            .if eax < 20
                mov    eax, 5
            .elseif eax < 40
                mov    eax, 4
            .elseif eax < 60
                mov    eax, 3
            .elseif eax < 80
                mov    eax, 2
            .else
                mov    eax, 1
            .endif
            push   eax
            invoke printf, addr msg2
            pop    eax
            invoke _BulletPackInit, eax
        .endif
    invoke _MainKeyboard
    invoke _AerocraftVeer
    invoke _AerocraftMove, addr stAerocraft1
    invoke _AerocraftMove, addr stAerocraft2


    ret
_MainFrame endp

_ProcWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
        local @stPs: PAINTSTRUCT
        local @hDC, @char:WPARAM
        
    mov    eax, uMsg
    .if eax == WM_TIMER
        invoke _MainFrame
        invoke _ShowMakerPaint
        invoke InvalidateRect, hWnd, NULL, FALSE
    .elseif eax == WM_PAINT
        invoke BeginPaint, hWnd, addr @stPs
        mov    @hDC, eax
        mov    eax, @stPs.rcPaint.right
        sub    eax, @stPs.rcPaint.left
        mov    ecx, @stPs.rcPaint.bottom
        sub    ecx, @stPs.rcPaint.top
        invoke BitBlt, @hDC, @stPs.rcPaint.left, @stPs.rcPaint.top, eax, ecx, stShowMaker.hFinalDC, @stPs.rcPaint.left, @stPs.rcPaint.top, SRCCOPY
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
    invoke  CreateWindowEx, NULL, offset szClassName, offset szClassName, WS_POPUP, 40, 40, WINDOW_HIDTH, WINDOW_WIDTH, NULL, NULL, hInstance, NULL
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