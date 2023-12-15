.486
.model	flat,stdcall
option	casemap:none

include	common.inc

drawImage	equ	GdipDrawImageRectI

.data
logoBitmapPtr	dword	?
storyUtf16Str	word	1024 dup(?)

.code
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

;����ͼƬ��Դ����ʼ��UTF-16�ַ�����
initResources	proc
	local	utf16Str[512]:word
	invoke	MultiByteToWideChar,CP_ACP,NULL,offset LOGO_PATH,-1,addr utf16Str,sizeof utf16Str
	invoke	GdipLoadImageFromFile,addr utf16Str,offset logoBitmapPtr
	invoke	MultiByteToWideChar,CP_ACP,NULL,offset STORY_1,-1,offset storyUtf16Str,sizeof storyUtf16Str
	ret
initResources	endp

;����ͼƬ��Դ
releaseResources	proc
	invoke	GdipFree,logoBitmapPtr
	ret
releaseResources	endp

drawMap	proc	graphicsPtr:dword

drawMap	endp

drawLogo	proc	graphicsPtr:dword,frames:dword
	cmp	frames,15
	jle	appear_drawLogo
	cmp	frames,15+25
	jle	hold_drawLogo
	cmp	frames,15+25+15
	jle	disappear_drawLogo
	mov	eax,1
	ret
appear_drawLogo:
	invoke	drawSolidRect,graphicsPtr,0ff000000h,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	drawImage,graphicsPtr,logoBitmapPtr,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	mov	edx,frames
	shl	edx,4
	mov	eax,255
	sub	eax,edx
	shl	eax,24
	invoke	drawSolidRect,graphicsPtr,eax,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	jmp	exit_drawLogo
hold_drawLogo:
	invoke	drawSolidRect,graphicsPtr,0ff000000h,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	drawImage,graphicsPtr,logoBitmapPtr,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	jmp	exit_drawLogo
disappear_drawLogo:
	invoke	drawSolidRect,graphicsPtr,0ff000000h,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	drawImage,graphicsPtr,logoBitmapPtr,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	mov	edx,frames
	sub	edx,15+25
	shl	edx,4+24
	invoke	drawSolidRect,graphicsPtr,edx,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
exit_drawLogo:
	xor	eax,eax
	ret
drawLogo	endp

end