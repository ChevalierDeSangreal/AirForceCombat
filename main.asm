.386
.model flat, stdcall
option casemap : none

.DATA
location STRUCT
	x DD 0
	y DD 0
location ENDS

accurate_location STRUCT
	x REAL8 0
	y REAL8 0
accurate_location ENDS

vel STRUCT
	v DD 0
	theta DD 0
vel ENDS

control STRUCT
	x DD 0
	theta DD 0
control ENDS

.CODE
start:
end start