.486
.model	flat,stdcall
option	casemap:none

include	common.inc

.code
;����ͼƬ��Դ����ʼ��UTF-16�ַ�����
initResources	proc
	ret
initResources	endp

;����ͼƬ��Դ
releaseResources	proc
	ret
releaseResources	endp

;����ָ����StrFont��StrDisp����Ļ�ϻ���UTF-16�ַ���
drawUtf16String	proc	graphicsPtr:dword,strToShow:ptr word,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
	local	fontFamilyPtr:dword,fontPtr:dword,stringFormatPtr:dword,brushPtr:dword
	push	ebx
	mov	ebx,strFontPtr
	invoke	GdipCreateFontFamilyFromName,ebx,NULL,addr fontFamilyPtr	;����������
	invoke	GdipCreateFont,fontFamilyPtr,[ebx].StrFont.fontSize,[ebx].StrFont.style,UnitPoint,addr fontPtr
	invoke	GdipCreateSolidFill,[ebx].StrFont.color,addr brushPtr
	mov	ebx,strDispPtr
	invoke	GdipStringFormatGetGenericDefault,addr stringFormatPtr
	invoke	GdipSetStringFormatAlign,stringFormatPtr,[ebx].StrDisp.hAlign
	invoke	GdipSetStringFormatLineAlign,stringFormatPtr,[ebx].StrDisp.vAlign
	invoke	GdipDrawString,graphicsPtr,strToShow,-1,fontPtr,ebx,stringFormatPtr,brushPtr	;��ʾ����
	invoke	GdipDeleteStringFormat,stringFormatPtr
	invoke	GdipDeleteBrush,brushPtr
	invoke	GdipDeleteFont,fontPtr
	invoke	GdipDeleteFontFamily,fontFamilyPtr
	pop	ebx
	ret
drawUtf16String	endp

;����ָ����StrFont��StrDisp����Ļ�ϻ���GBϵ�е��ַ���
drawGbString	proc	graphicsPtr:dword,strToShow:ptr byte,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
	local	str1[512]:word
	invoke	MultiByteToWideChar,CP_ACP,NULL,strToShow,-1,addr str1,sizeof str1
	invoke	drawUtf16String,graphicsPtr,addr str1,strFontPtr,strDispPtr
	ret
drawGbString	endp

;����Ļ��������
drawSolidRect	proc	graphicsPtr:dword,color:dword,x:dword,y:dword,_width:dword,height:dword
	local	brushPtr:dword
	invoke	GdipCreateSolidFill,color,addr brushPtr
	invoke	GdipFillRectangleI,graphicsPtr,brushPtr,x,y,_width,height
	invoke	GdipDeleteBrush,brushPtr
	ret
drawSolidRect	endp
end