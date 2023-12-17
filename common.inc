;注意：引用该文件后调用C库函数不需要再声明原型了，只需在对应库函数名前加“crt_”
;该文件中有我们定义的所有常量和结构体
ifndef	COMMON_INC
COMMON_INC	equ	<1>

include	windows.inc
include	user32.inc
include	kernel32.inc
include	gdi32.inc
include	gdiplus.inc
include	msvcrt.inc
include	imm32.inc
include winmm.inc
includelib	user32.lib
includelib	kernel32.lib
includelib	gdi32.lib
includelib	gdiplus.lib
includelib	msvcrt.lib
includelib	imm32.lib
includelib winmm.lib

FONT_NAME_LEN	equ	16


;定死窗口高度宽度，数值可以以后再调
WINDOW_WIDTH	equ	1000
WINDOW_HEIGHT	equ	750
;各按键的坐标（左上xy、宽高）用于画图和鼠标判断
	;开始新游戏
BUTT_STARTNEW_X equ 670
BUTT_STARTNEW_Y equ 510
BUTT_STARTNEW_W equ 200
BUTT_STARTNEW_H equ 60
	;继续游戏
BUTT_CONTINUE_X equ 670
BUTT_CONTINUE_Y equ 600
BUTT_CONTINUE_W equ 200
BUTT_CONTINUE_H equ 60

EMPTY	equ	0
WALL	equ	1
PLAYER	equ	2
BOMB	equ	3
MONSTER	equ	4
BOX	equ	5
TOOL	equ	6
FIRE	equ	7
BOSS	equ	8
BLUEFIRE	equ	9
ATTACK	equ	10

MONSTER_1	equ	41
MONSTER_2	equ	42
MONSTER_3	equ	43

;define fps (待定30，实测大约33？)
FRAMES_PER_SEC	equ	30

;define speed
PLAYER_1_SPEED	equ	12
MONSTER_1_SPEED	equ	9
MONSTER_2_SPEED	equ	13
MONSTER_3_SPEED	equ	16
;新帧数下的速度
;PLAYER_1_SPEED	equ	12
;MONSTER_1_SPEED	equ	9
;MONSTER_2_SPEED	equ	13
;MONSTER_3_SPEED	equ	16

;define map_size
ROW	equ	13
COL	equ	15
DEPTH	equ	3

;define max objects
MAX_MONSTER	equ	10
MAX_BOMB	equ	5
MAX_TOOL	equ	5
MAX_ATTACK	equ	10
BOSS_LIFE	equ	5

;define frac
FRAC	equ	5

UP	equ	0
DOWN	equ	1
LEFT	equ	2
RIGHT	equ	3
SETBOMB	equ	4
GAMEPAUSE	equ 5
GAMESTART	equ 6

;define time
INVISIBLE_TIMER	equ	5
BOMB_TIMER	equ	30
FIRE_TIMER	equ	1
TOOL_TIMER	equ 50
;COOL_TIME	equ	30
;SKY_TIME	equ	30
;PRE_DROP_TIME	equ	10
;PRE_ATTACK_TIME	equ	10
;ATTACK_TIME	equ	5
;ATTACK_FREQ	equ	10

;INVISIBLE_TIMER	equ	90
;BOMB_TIMER	equ	90
;FIRE_TIMER	equ	12
;TOOL_TIMER	equ 150
;boss时间再调
COOL_TIME	equ	30
SKY_TIME	equ	30
PRE_DROP_TIME	equ	10
PRE_ATTACK_TIME	equ	10
ATTACK_TIME	equ	5
ATTACK_FREQ	equ	10

FRAC_RANGE	equ	100

NORMAL	equ	0
INVISIBLE	equ	1
STILL	equ	0
MOVE	equ	1

LIFE_TOOL	equ	0
RANGE_TOOL	equ	1
CNT_TOOL	equ	2
SPEED_TOOL	equ	3
TIME_TOOL	equ	4

;define max upgrades
MAX_LIFE	equ	5
MAX_RANGE	equ	4
MAX_BOMB_CNT	equ	3
MAX_SPEED	equ	5

;define game stage
LOGO	equ	0
MAIN_MENU	equ	1
STORY	equ	2
IN_GAME	equ	3

;enum mainWinp.state
winState_logoPage	equ 1
winState_startPage	equ 2
winState_onStory	equ 3
winState_onGame		equ 4
winState_pauseGame	equ 5

;struct definition
;这样一个Object的大小就是4，便于比例变址寻址
Object	struct
	_type	word	?
	id	word	?
Object	ends

Player	struct
	x	dword	?
	y	dword	?
	frac_x	dword	?
	frac_y	dword	?
	bomb_range	dword	?
	bomb_cnt	dword	?
	life	dword	?
	speed	dword	?
	;status	dword	?
	timer	dword	?	;无敌时间
	direction	dword	?
	isMove	dword	?
Player	ends

Monster	struct
	valid	dword	?
	x	dword	?
	y	dword	?
	frac_x	dword	?
	frac_y	dword	?
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
	level_timer	dword	?
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

MainWinp	struct	;游戏外层主窗口逻辑部分全局变量
	winState	dword	?
	frames	dword	?	;启动时画logo等状态的帧数，用于淡入淡出等
	
MainWinp	ends

;function definition
drawImage	equ	GdipDrawImageRectI
drawUtf16String	proto	graphicsPtr:dword,strToShow:ptr word,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawGbString	proto	graphicsPtr:dword,strToShow:ptr byte,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawSolidRect	proto	graphicsPtr:dword,color:dword,x:dword,y:dword,_width:dword,height:dword
initResources	proto
releaseResources	proto
drawWindow	proto	graphicsPtr:dword

calcMapOffset	proto	x:dword,y:dword,z:dword
initMonster	proto    index:dword,x:dword,y:dword,speed:dword
initBoss    proto    x:dword,y:dword
initLevel	proto
initGame	proto
placeBomb	proto
pollingPlayer	proto	input:dword
isMoveable	proto	x:dword,y:dword
isMoveableMonster	proto	x:dword,y:dword
moveOneStep	proto	x:dword,y:dword,direction:dword,new_x:ptr dword,new_y:ptr dword,frac_x:ptr dword,frac_y:ptr dword,speed:dword
changeDirection	proto	index:dword
calculateNextMove	proto	x:dword,y:dword,direction:dword,new_x:ptr dword,new_y:ptr dword
pollingMonster	proto
movMonsterToNextCell proto index:dword
getFromDriection proto direction:dword
die	proto
;setInvisiable	proto
pollingTool	proto
pollingSuccess	proto
pollingBomb	proto
placeTool	proto	x:dword,y:dword
dealBomb	proto	x:dword,y:dword,range:dword,_job:dword
isDestroyable	proto	x:dword,y:dword
explode	proto	x:dword,y:dword,id:dword
setFire	proto	x:dword,y:dword,id:dword
clearFire	proto	x:dword,y:dword,id:dword
clear	proto	x:dword,y:dword
preAttack	proto	x:dword,y:dword
makeAttack	proto	x:dword,y:dword
makeDrop	proto	x:dword,y:dword
dealAttack	proto	x:dword,y:dword,_job:dword
pollingAttack	proto
bossAttack	proto
pollingBoss	proto
bossDrop	proto
archive	proto
load	proto
readKey	proto
draw	proto
mainLoop proto
gameLoop proto  input:dword
isMouseInButton proto mousex:word, mousey:word, x:word,y:word,w:word,h:word
PlayMp3File proto hWin:dword, NameOfFile:dword

;这个地方要重新改，不要在inc文件里定义段了
.const
CLASS_NAME	byte	"MainWindow",0	;窗口类名
WINDOW_NAME	byte	"BIT BOMBERMAN",0	;窗口显示名
GP_INPUT	GdiplusStartupInput	<1,0,0,0>
MSGBOX_WINDOW_FAIL_TEXT	byte	"窗口创建失败！",0
MSGBOX_ERROR_TITLE	byte	"错误",0

endif


