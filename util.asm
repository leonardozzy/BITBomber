.486
.model	flat,stdcall
option	casemap:none

include common.inc

.code
;����������ڼ�����ʵ�ͼ����ʱ�ĵ�Чһά�±ꡣ
;��ʵƫ�����������sizeof Object��Ŀǰ��4��ʹ��ʱ����ֱ�ӱ�����ַѰַŶ����
;�����ٵ��á�
calcMapOffset	proc x:dword,y:dword,z:dword
	mov	eax,z
	mov	edx,ROW*COL
	mul	edx
	mov	ecx,eax
	mov	eax,y
	mov	edx,ROW
	mul	edx
	add	eax,ecx
	add	eax,x
	ret
calcMapOffset	endp

end
