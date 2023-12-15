;注意：引用该文件后调用C库函数不需要再声明原型了，只需在对应库函数名前加“crt_”
;该文件中有我们定义的所有常量和结构体
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

;const number definition
FONT_NAME_LEN	equ	16
;定死窗口高度宽度，数值可以以后再调
WINDOW_WIDTH	equ	1000
WINDOW_HEIGHT	equ	750
LOGO_WIDTH	equ	400
LOGO_HEIGHT	equ	400
LOGO_X_POS	equ	300
LOGO_Y_POS	equ	150

EMPTY	equ	0
WALL	equ	1
PLAYER	equ	2
BOMB	equ	3
MONSTER	equ	4
BOX	equ	5
TOOL	equ	6
BOSS	equ	8
FIRE	equ	7
BLUEFIRE	equ	8
ATTACK	equ	9

MONSTER_1	equ	41
MONSTER_2	equ	42
MONSTER_3	equ	43

;define speed
PLAYER_1_SPEED	equ	80
MONSTER_1_SPEED	equ	60
MONSTER_2_SPEED	equ	80
MONSTER_3_SPEED	equ	90

;define map_size
ROW	equ	13
COL	equ	15
DEPTH	equ	3

;define max objects
MAX_MONSTER	equ	10
MAX_BOMB	equ	5
MAX_TOOL	equ	5
MAX_ATTACK	equ	5
BOSS_LIFE	equ	5

;define frac
FRAC	equ	5

UP	equ	0
DOWN	equ	1
LEFT	equ	2
RIGHT	equ	3
SETBOMB	equ	4

;define time
BOMB_TIMER	equ	30
FIRE_TIMER	equ	1
TOOL_TIMER	equ 50
COOL_TIME	equ	30
INVISIBLE_TIMER	equ	5
SKY_TIME	equ	30
PRE_DROP_TIME	equ	10
PRE_ATTACK_TIME	equ	10
ATTACK_TIME	equ	5
ATTACK_FREQ	equ	10

FRAC_RANGE	equ	100

NORMAL	equ	0
INVISIBLE	equ	1

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
	status	dword	?
	timer	dword	?
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

;function definition
initResources	proto
releaseResources	proto
drawLogo	proto	graphicsPtr:dword,frames:dword

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
die	proto
setInvisiable	proto
pollingTool	proto
pollingSuccess	proto
pollingBomb	proto
placeTool	proto	x:dword,y:dword
dealBomb	proto	x:dword,y:dword,range:dword,_job:dword
isDestroyable	proto	x:dword,y:dword
explode	proto	x:dword,y:dword
setFire	proto	x:dword,y:dword
clearFire	proto	x:dword,y:dword
clear	proto	x:dword,y:dword
preAttack	proto	x:dword,y:dword
makeAttack	proto	x:dword,y:dword
makeDrop	proto	x:dword,y:dword
dealAttack	proto	x:dword,y:dword,_job:dword
pollingAttack	proto
bossAttack	proto
pollingBoss	proto
bossDrop	proto
archive	proto	path1:ptr byte
load	proto	path1:ptr byte
readKey	proto

;const string definition
.const
CLASS_NAME	byte	"MainWindow",0	;窗口类名
WINDOW_NAME	byte	"BIT BOMBERMAN",0	;窗口显示名
GP_INPUT	GdiplusStartupInput	<1,0,0,0>
MSGBOX_WINDOW_FAIL_TEXT	byte	"窗口创建失败！",0
MSGBOX_ERROR_TITLE	byte	"错误",0
FILENAME1	byte	"./level/1.level",0
FILENAME2	byte	"./level/2.level",0
FILENAME3	byte	"./level/3.level",0
FILENAME4	byte	"./level/4.level",0
LOGO_PATH	byte	"./image/logo.png",0
STORY_1	byte	"据说",0ah,0ah,"在文G126教室下方的地底深处",0ah,0ah,"沉睡着一只强大的恶龙",0ah,0ah,"它曾是这片土地上的主宰",0ah,0ah,"但在数百年前被一位传奇的勇士所封印",0ah,0ah,"然而",0ah,0ah,"由于一系列神秘的事件",0ah,0ah,"这条恶龙再次苏醒",0ah,0ah,"并对北理工校园发动了猛烈的进攻",0ah,0ah
STORY_2	byte	"恶龙的出现引起了巨大的恐慌",0ah,0ah,"整个校园都笼罩在恶龙的阴影之下",0ah,0ah,"学生们惊恐地发现",0ah,0ah,"恶龙的力量无法用普通的手段抵挡",0ah,0ah,"校园里弥漫着绝望的氛围",0ah,0ah
STORY_3	byte	"直到一天",0ah,0ah,"张华平老师",0ah,0ah,"一位在《汇编语言与接口技术》课程中崭露头角的教授",0ah,0ah,"意识到解救校园的唯一方法是利用古老的汇编技术",0ah,0ah,"唤醒这一代学生的力量",0ah,0ah
STORY_4	byte	"于是",0ah,0ah,"张老师向他的学生们发出了紧急招募令",0ah,0ah,"在《汇编语言与接口技术》班级中",0ah,0ah,"一群年轻而充满激情的学生被选中",0ah,0ah,"他们将被授予MASM",0ah,0ah,"接受特殊的培训",0ah,0ah,"导引IA-32之力",0ah,0ah
STORY_5	byte	"同学们在张老师的指导下",0ah,0ah,"深入学习汇编语言",0ah,0ah,"研究如何运用这些编程技术来制造强大的炸弹",0ah,0ah,"以对抗恶龙和它的爪牙",0ah,0ah,"在激烈的训练中",0ah,0ah,"同学们逐渐领悟到编程艺术的深奥之处",0ah,0ah,"他们的智慧和技能在不断地升华",0ah,0ah
STORY_6	byte	"随着时间的推移",0ah,0ah,"同学们集结成一个强大的汇编战队",0ah,0ah,"他们肩负着解救北理工校园的责任",0ah,0ah,"他们穿梭在校园的教学楼中",0ah,0ah,"挑战各种由恶龙创造的机关陷阱",0ah,0ah,"解开一个个谜题",0ah,0ah,"最终进入到G126教室的最深处",0ah,0ah,"准备面对恶龙的最终一战……",0

LEVEL_FILE_NAMES	dword	offset FILENAME1,offset FILENAME2,offset FILENAME3,offset FILENAME4
OPEN_FILE_READ_ONLY	byte	"r",0
OPEN_BFILE_READ_ONLY	byte	"rb",0
OPEN_BFILE_WRITE_ONLY	byte	"wb",0
ONE_INT_FORMAT	byte	"%d",0
WIN_STR	byte	"You Win!",0

;跨文件零初始化全局变量声明，其实可以不memset
.data?
game	Game	<>	;common game object


