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

end
