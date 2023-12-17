.486
.model	flat,stdcall
option	casemap:none

include common.inc

.code
;����������ڼ�����ʵ�ͼ����ʱ�ĵ�Чһά�±ꡣ
;��ʵƫ�����������sizeof Object��Ŀǰ��4��ʹ��ʱ����ֱ�ӱ�����ַѰַŶ����
;�����ٵ��á�
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

;�ж�mousexy�Ƿ���xy��x+w y+h��Χ�ڣ�������������
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
