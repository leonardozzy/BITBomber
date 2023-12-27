;注意：引用该文件后调用C库函数不需要再声明原型了，只需在对应库函数名前加“crt_”
;该文件中有我们定义的所有常量和结构体
ifndef	COMMON_INC
COMMON_INC	equ	<1>
include	windows.inc
include	user32.inc
include	kernel32.inc
include	gdi32.inc
include	gdiplus.inc
include	msimg32.inc
include	imm32.inc
include winmm.inc
include	msvcrt.inc
includelib	user32.lib
includelib	kernel32.lib
includelib	gdi32.lib
includelib	gdiplus.lib
includelib	msimg32.lib
includelib	imm32.lib
includelib	winmm.lib
includelib	msvcrt.lib

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
	;question-A
BUTT_CHOICEA_X equ 85
BUTT_CHOICEA_Y equ 480
BUTT_CHOICEA_W equ 300
BUTT_CHOICEA_H equ 45
	;question-B
BUTT_CHOICEB_X equ 560
BUTT_CHOICEB_Y equ 480
BUTT_CHOICEB_W equ 300
BUTT_CHOICEB_H equ 45
	;question-C
BUTT_CHOICEC_X equ 85
BUTT_CHOICEC_Y equ 565
BUTT_CHOICEC_W equ 300
BUTT_CHOICEC_H equ 45
	;question-D
BUTT_CHOICED_X equ 560
BUTT_CHOICED_Y equ 565
BUTT_CHOICED_W equ 300
BUTT_CHOICED_H equ 45

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

;define fps (待定30，实测大约33？)
FRAMES_PER_SEC	equ	30

MONSTER_1	equ	41
MONSTER_2	equ	42
MONSTER_3	equ	43

;define speed
PLAYER_1_SPEED	equ	12
MONSTER_1_SPEED	equ	8
MONSTER_2_SPEED	equ	12
MONSTER_3_SPEED	equ	16

;define map_size
ROW	equ	13
COL	equ	15
DEPTH	equ	5

;define max objects
MAX_MONSTER	equ	10
MAX_BOMB	equ	5
MAX_TOOL	equ	5
MAX_ATTACK	equ	10	;原先18

;define frac
FRAC_RANGE	equ	100

UP	equ	0
DOWN	equ	1
LEFT	equ	2
RIGHT	equ	3
SETBOMB	equ	4
GAMEPAUSE	equ 5

;define time
INVISIBLE_TIMER	equ	90
BOMB_TIMER	equ	75
FIRE_TIMER	equ	12
TOOL_TIMER	equ 180

;龙型状态机
NOT_EXIST	equ	0
IN_MAP_STATE	equ	1
TAKEOFF_STATE	equ	2
IN_SKY_STATE	equ	3
LANDING_STATE	equ	4
IN_SKY_SUMMON_STATE	equ	5
;boss属性
BOSS_LIFE	equ	5
COOL_TIME	equ	180
TAKEOFF_TIME	equ	60
MIN_SKY_TIME	equ	240
MAX_SKY_TIME	equ	630
LANDING_TIME	equ	60
PRE_ATTACK_TIME	equ	40
ATTACK_TIME	equ	240
ATTACK_FREQ	equ	50

JUST_FIRE	equ	0
SUMMON_MONSTER	equ	1

TOOL_CHANCE_RATE	equ	8	;1/TOOL_CHANCE_RATE
LIFE_TOOL	equ	0
RANGE_TOOL	equ	1
CNT_TOOL	equ	2
SPEED_TOOL	equ	3
TIME_TOOL	equ	4

;玩家上限
MAX_LIFE	equ	5
MAX_BOMB_RANGE	equ	5
MAX_BOMB_CNT	equ	5
MAX_SPEED	equ	16
TIME_INCREMENT	equ	20

STILL	equ	0
MOVE	equ	1

MAX_QUESTION	equ	1000
MAX_LEVEL	equ	100

;define game state
LOGO_STATE	equ	0
START_STATE	equ	1
STORY1_STATE	equ	2
STORY2_STATE	equ	3
TUTORIAL_STATE	equ	4
GAME_STATE	equ	5
PAUSE_STATE	equ	6
QUESTION_STATE	equ	7
ANSWER_STATE	equ	8
GAME_OVER_STATE	equ	9
KILL_BOSS_STATE	equ	10
GAME_WIN_STATE	equ	11

;struct definition
;这样一个Object的大小就是4，便于比例变址寻址
Object	struct
	_type	word	?
	id	word	?
Object	ends

Player	struct
	x	dword	?
	y	dword	?
	frac_x	sdword	?
	frac_y	sdword	?
	bomb_range	dword	?
	bomb_cnt	dword	?
	life	dword	?
	speed	dword	?
	timer	dword	?	;无敌时间
	direction	dword	?
	isMove	dword	?
Player	ends

Monster	struct
	x	dword	?
	y	dword	?
	valid	dword	?
	frac_x	sdword	?
	frac_y	sdword	?
	has_turned	dword	?
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
	state	dword	?
	timer	dword	?
	next_attack_type	dword	?
Boss	ends

Attack	struct
	x	dword	?
	y	dword	?
	timer	dword	?
	_type	dword	?
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
Game	ends

BmpStruct	struct			;size: 24=8*3
	hBitmap	HBITMAP	?		;原位图句柄
	bitmapHdc	HDC	?		;原位图设备上下文句柄
	_width	dword	?		;位图宽度
	height	dword	?		;位图高度
	hMaskBitmap	HBITMAP	?	;掩码位图句柄
    maskBitmapHdc	HDC	?	;掩码位图设备上下文句柄
BmpStruct	ends

MainWinp	struct				;游戏外层主窗口逻辑部分全局变量
	currentState	dword	?	;当前状态，永远不要直接动，否则不会画新的图
	intentState	dword	?		;意向状态
	timer	dword	?			;计时器
	shouldFade	dword	?		;是否需要淡入淡出
	transitionFunc	dword	?	;切换状态时要调用的函数
	correctAnswer	dword	?	;答题的正确答案
	playerAnswer	dword	?	;玩家实际选项
MainWinp	ends

;public function definition
;renderer.asm
;警告：GdipDrawImageRectI有*严重*的性能问题，绝对禁止在每帧的重绘中使用
;实时绘制图像请使用GDI的BitBlt/StretchBlt/AlphaBlend等
initResources	proto
releaseResources	proto
drawWindow	proto
;gamelogic.asm
initLevel	proto
initGame	proto
gameLoop	proto  input:dword
;util.asm
calcMapOffset	proto	x:dword,y:dword,z:dword
isMouseInButton proto mousex:word, mousey:word, x:word,y:word,w:word,h:word
readKeyInGame	proto
InitDanceMode	proto
StartDanceMode proto
jobResetTimer	proto
jobGameToQuestion	proto
jobToStart	proto
jobToStory	proto
jobHomeToGame	proto
jobTutorialToGame	proto
jobQuestionToAnswer	proto
jobAnswerToGame	proto
checkTimerAndFade	proto	maxTime:dword,nextState:dword,transitionFunc:dword
archive	proto
load	proto
readInfo    proto    errorInfo:ptr byte
readQuestion proto	question:ptr byte,choice1:ptr byte,choice2:ptr byte,choice3:ptr byte,choice4:ptr byte
endif


