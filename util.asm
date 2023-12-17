.486
.model	flat,stdcall
option	casemap:none

include common.inc

.code
;这个函数用于计算访问地图数组时的等效一维下标。
;真实偏移量还需乘上sizeof Object（目前是4，使用时可以直接比例变址寻址哦）。
;尽量少调用。
calcMapOffset	proc x:dword,y:dword,z:dword
	mov	eax,x
	mov	edx,COL*DEPTH
	mul	edx
	mov	ecx,eax
	mov	eax,y
	mov	edx,DEPTH
	mul	edx
	add	eax,ecx
	add	eax,z
	ret
calcMapOffset	endp

;判断mousexy是否在xy，x+w y+h范围内，鼠标点击按键检测
isMouseInButton proc mousex:word, mousey:word, x:word,y:word,w:word,h:word
	mov dx,mousex
	cmp dx,x
	jb notIn_isMouseInButton
	sub dx,x
	cmp dx,w
	ja notIn_isMouseInButton
	mov dx,mousey
	cmp dx,y
	jb notIn_isMouseInButton
	sub dx,y
	cmp dx,h
	ja notIn_isMouseInButton
	mov eax,1
	ret
notIn_isMouseInButton:
	mov eax,0
	ret
isMouseInButton endp

end
