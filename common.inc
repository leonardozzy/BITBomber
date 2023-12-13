include	windows.inc
include	user32.inc
include	kernel32.inc
include	gdi32.inc
include	gdiplus.inc
include	msvcrt.inc
includelib	user32.lib
includelib	kernel32.lib
includelib	gdi32.lib
includelib	gdiplus.lib
includelib	msvcrt.lib

FONT_NAME_LEN	equ	16
drawImage	equ	GdipDrawImageRectI

StrFont	struct
	fontName	word	FONT_NAME_LEN dup(?)
	fontSize	real4	?
	color	dword	?
	style	dword	?
StrFont	ends

StrDisp	struct	;ǰ�ĸ��ֶκ�RectF�ṹ����ͬ����RectF��ָ��ʱ����ֱ��͵������
	x	real4	?
	y	real4	?
	_width	real4	?
	height	real4	?
	hAlign	dword	?
	vAlign	dword	?
StrDisp	ends

drawUtf16String	proto graphicsPtr:dword,strToShow:ptr word,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawGbString	proto graphicsPtr:dword,strToShow:ptr byte,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawSolidRect	proto graphicsPtr:dword,color:dword,x:dword,y:dword,_width:dword,height:dword