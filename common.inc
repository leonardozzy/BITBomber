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
includelib	winmm.lib

FONT_NAME_LEN	equ	16


;定死窗口高度宽度，数值可以以后再调
WINDOW_WIDTH	equ	1000
WINDOW_HEIGHT	equ	750
;各按键的坐标（左上xy、宽高）用于画图和鼠标判断
	;home-开始新游戏
BUTT_STARTNEW_X equ 300
BUTT_STARTNEW_Y equ 653
BUTT_STARTNEW_W equ 200
BUTT_STARTNEW_H equ 60
	;home-继续游戏
BUTT_CONTINUESAVE_X equ 540
BUTT_CONTINUESAVE_Y equ 653
BUTT_CONTINUESAVE_W equ 200
BUTT_CONTINUESAVE_H equ 60
	;home-关于
BUTT_ABOUTME_X equ 780
BUTT_ABOUTME_Y equ 653
BUTT_ABOUTME_W equ 200
BUTT_ABOUTME_H equ 60
	;ongame-暂停游戏
BUTT_PAUSE_X equ 0
BUTT_PAUSE_Y equ 0
BUTT_PAUSE_W equ 100
BUTT_PAUSE_H equ 100
	;pause-存档
BUTT_SAVE_X equ 365
BUTT_SAVE_Y equ 187
BUTT_SAVE_W equ 240
BUTT_SAVE_H equ 53
	;pause-继续
BUTT_CONTINUE_X equ 365
BUTT_CONTINUE_Y equ 275
BUTT_CONTINUE_W equ 240
BUTT_CONTINUE_H equ 53
	;pause-体感模式
BUTT_DANCEMODE_X equ 365
BUTT_DANCEMODE_Y equ 371
BUTT_DANCEMODE_W equ 200
BUTT_DANCEMODE_H equ 53
	;pause-返回home
BUTT_RETHOME_X equ 365
BUTT_RETHOME_Y equ 467
BUTT_RETHOME_W equ 240
BUTT_RETHOME_H equ 53

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
BOSS_FLY	equ	11

MONSTER_1	equ	41
MONSTER_2	equ	42
MONSTER_3	equ	43

;define fps (待定30，实测大约33？)
FRAMES_PER_SEC	equ	30

;define speed
PLAYER_1_SPEED	equ	12
MONSTER_1_SPEED	equ	8
MONSTER_2_SPEED	equ	12
MONSTER_3_SPEED	equ	16
;新帧数下的速度

;define map_size
ROW	equ	13
COL	equ	15
DEPTH	equ	3

;define max objects
MAX_MONSTER	equ	10
MAX_BOMB	equ	5
MAX_TOOL	equ	5
MAX_ATTACK	equ	18
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
SPACEJO		equ 7
KEY_B		equ 8
KEY_C		equ 9

;define time
INVISIBLE_TIMER	equ	100
BOMB_TIMER	equ	75
FIRE_TIMER	equ	12
TOOL_TIMER	equ 180
;boss时间再调
COOL_TIME	equ	200
TAKE_OFF_TIME equ 440
SKY_TIME	equ	500
PRE_DROP_TIME	equ	60
PRE_ATTACK_TIME	equ	45
ATTACK_TIME	equ	200
ATTACK_FREQ	equ	50

FRAC_RANGE	equ	100

NORMAL	equ	0
INVISIBLE	equ	1
STILL	equ	0
MOVE	equ	1

TOOL_CHANCE_RATE	equ	8	;1/TOOL_CHANCE_RATE
LIFE_TOOL	equ	0
RANGE_TOOL	equ	1
CNT_TOOL	equ	2
SPEED_TOOL	equ	3
TIME_TOOL	equ	4

;define max upgrades
MAX_LIFE	equ	5
MAX_BOMB_RANGE	equ	5
MAX_BOMB_CNT	equ	5
MAX_SPEED	equ	17
TIME_INCREMENT	equ	20

;define game stage
LOGO	equ	0
MAIN_MENU	equ	1
STORY	equ	2
IN_GAME	equ	3

MAX_QUESTION	equ	1000
MAX_LEVEL	equ	100

;enum mainWinp.state
winState_logoPage	equ 0
winState_startPage	equ 1
winState_onStory	equ 2
winState_onGame		equ 3
winState_pauseGame	equ 4
winState_levelup	equ 5
winState_gameover	equ 6
winState_gamewin	equ 7


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
	timer	dword	?
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

BitmapInfo	struct
	hBitmap	HBITMAP	?
	hdcMem	HDC	?
	_width	dword	?
	height	dword	?
BitmapInfo	ends

MainWinp	struct	;游戏外层主窗口逻辑部分全局变量
	winState	dword	?
	frames	dword	?	;启动时画logo等状态的帧数，用于淡入淡出等
	nowStoryNum	dword	?
	levelup_answer	dword	?

MainWinp	ends

;function definition
drawImage	equ	GdipDrawImageRectI
drawUtf16String	proto	graphicsPtr:dword,strToShow:ptr word,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawGbString	proto	graphicsPtr:dword,strToShow:ptr byte,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
drawSolidRect	proto	graphicsPtr:dword,color:dword,x:dword,y:dword,_width:dword,height:dword
initResources	proto
releaseResources	proto
drawWindow	proto	graphicsPtr:dword,hdcBuffer:HDC
drawMap	proto	graphicsPtr:dword,hdcBuffer:HDC

calcMapOffset	proto	x:dword,y:dword,z:dword
readInfo    proto    errorInfo:ptr byte
readQuestion proto	question:ptr byte,choice1:ptr byte,choice2:ptr byte,choice3:ptr byte,choice4:ptr byte
initMonster	proto    index:dword,x:dword,y:dword,speed:dword
initBoss    proto    x:dword,y:dword
initLevel	proto
initGame	proto
placeBomb	proto
pollingPlayer	proto	input:dword
isMoveable	proto	x:dword,y:dword
isMoveableMonster	proto	x:dword,y:dword
moveOneStep	proto	x:dword,y:dword,direction:dword,pnew_x:ptr dword,pnew_y:ptr dword,pfrac_x:ptr dword,pfrac_y:ptr dword,speed:dword,_type:word
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
dealBomb	proto	x:dword,y:dword,id:dword,range:dword,_job:dword
isDestroyable	proto	x:dword,y:dword
explode	proto	x:dword,y:dword,id:dword
setFire	proto	x:dword,y:dword,id:dword
clearFire	proto	x:dword,y:dword,id:dword
clear	proto	x:dword,y:dword
preAttack	proto	x:dword,y:dword,id:dword
makeAttack	proto	x:dword,y:dword,id:dword
makeDrop	proto	x:dword,y:dword
dealAttack	proto	x:dword,y:dword,id:dword,_job:dword
pollingAttack	proto
bossAttack	proto
pollingBoss	proto
bossDrop	proto
archive	proto
load	proto
readKey	proto
draw	proto
mainLoop proto	hwnd:HWND
gameLoop proto  input:dword
isMouseInButton proto mousex:word, mousey:word, x:word,y:word,w:word,h:word
PlayMp3File proto hWin:dword,NameOfFile:dword
StartBackSound proto NameOfFile:dword
StartDanceMode proto
readQuestion proto	question:ptr byte,choice1:ptr byte,choice2:ptr byte,choice3:ptr byte,choice4:ptr byte

checkAllImages	proto	errorInfo:ptr byte
endif


