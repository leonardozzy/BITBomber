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

EMPTY	equ	0
WALL	equ	1
PLAYER	equ	2
BOMB	equ	3
MONSTER	equ	4
BOX	equ	5
TOOL	equ	6
FIRE	equ	7
BLUEFIRE	equ	8
ATTACK	equ	9

MONSTER_1	equ	41
MONSTER_2	equ	42
MONSTER_3	equ	43

;define map_size
ROW	equ	13
COL	equ	15
DEPTH	equ	3

;define max objects
MAX_MONSTER	equ	10
MAX_BOMB	equ	5
MAX_TOOL	equ	5
MAX_ATTACK	equ	5

;define frac
FRAC	equ	5

UP	equ	0
DOWN	equ	1
LEFT	equ	2
RIGHT	equ	3

;define time
BOMB_TIMER	equ	4
FIRE_TIMER	equ	1
TOOL_TIMER	equ 10
COOL_TIME	equ	5
SKY_TIME	equ	10
PRE_DROP_TIME	equ	3
PRE_ATTACK_TIME	equ	2

;define max upgrades (待定)
MAX_LIFE	equ	5
MAX_RANGE	equ	4
MAX_BOMB_CNT	equ	3
MAX_SPEED	equ	5

drawImage	equ	GdipDrawImageRectI

;这样一个Object的大小就是4，便于比例变址寻址
Object	struct
	_type	word	?
	id	word	?
Object	ends

Player	struct
	x	dword	?
	y	dword	?
	bomb_range	dword	?
	bomb_cnt	dword	?
	life	dword	?
	speed	dword	?
Player	ends

Monster	struct
	valid	dword	?
	x	dword	?
	y	dword	?
	direction	dword	?
	speed	dword	?
Monster	ends

Bomb	struct
	x	dword	?
	y	dword	?
	timer	dword	?
	range	dword	?
Bomb	ends

Tool	struct
	x	dword	?
	y	dword	?
	timer	dword	?
	_type	dword	?
Tool	ends

;Boss和Attack暂定
Boss	struct
	x	dword	?
	y	dword	?
	life	dword	?
	cool_time	dword	?
	sky_time	dword	?
	pre_drop_time	dword	?
	in_map	dword	?
Boss	ends

Attack	struct
	x	dword	?
	y	dword	?
	time	dword	?
Attack	ends

Game	struct
	map	Object	ROW*COL*DEPTH dup(<>)
	monsters	Monster	MAX_MONSTER dup(<>)
	bombs	Bomb	MAX_BOMB dup(<>)
	tools	Tool	MAX_TOOL dup(<>)
	attacks	Attack	MAX_ATTACK dup(<>)
	player	Player	<>
	boss	Boss	<>
	level	dword	?
	timer	dword	?
	level_timer	dword	?	;待定
	monster_num	dword	?
	bomb_num	dword	?
	tool_num	dword	?
Game	ends

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
calcMapOffset	proto x:dword,y:dword,z:dword

.const
CLASS_NAME	byte	"MainWindow",0	;窗口类名
WINDOW_NAME	byte	"BIT BOMBERMAN",0	;窗口显示名
GP_INPUT	GdiplusStartupInput	<1,0,0,0>
MSGBOX_WINDOW_FAIL_TEXT	byte	"窗口创建失败！",0
MSGBOX_ERROR_TITLE	byte	"错误",0
