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
;定死窗口高度宽度，数值可以以后再调
WINDOW_WIDTH	equ	1000
WINDOW_HEIGHT	equ	750
drawImage	equ	GdipDrawImageRectI

StrFont	struct
	fontName	word	FONT_NAME_LEN dup(?)
	fontSize	real4	?
	color	dword	?
	style	dword	?
StrFont	ends

StrDisp	struct	;前四个字段和RectF结构体相同，传RectF的指针时可以直接偷梁换柱
	x	real4	?
	y	real4	?
	_width	real4	?
	height	real4	?
	hAlign	dword	?
	vAlign	dword	?
StrDisp	ends

initResources	proto
releaseResources	proto
drawUtf16String	proto graphicsPtr:dword,strToShow:ptr word,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawGbString	proto graphicsPtr:dword,strToShow:ptr byte,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawSolidRect	proto graphicsPtr:dword,color:dword,x:dword,y:dword,_width:dword,height:dword

.const
CLASS_NAME	byte	"MainWindow",0	;窗口类名
WINDOW_NAME	byte	"BIT BOMBERMAN",0	;窗口显示名
GP_INPUT	GdiplusStartupInput	<1,0,0,0>
MSGBOX_WINDOW_FAIL_TEXT	byte	"窗口创建失败！",0
MSGBOX_ERROR_TITLE	byte	"错误",0
