.386
.model	flat,stdcall
option	casemap:none

include	common.inc
public levelup_question
public levelup_choice1
public levelup_choice2
public levelup_choice3
public levelup_choice4
extrn	game:Game
extrn	level_cnt:dword
extrn	mainwinp:MainWinp
extrn	hdcBuffer:HDC

PLAYER_IMG	equ	0
MONSTER1_IMG	equ	1
MONSTER2_IMG	equ	2
MONSTER3_IMG	equ	3
DRAGON_IMG	equ	4
FIRE_IMG	equ	5
BLUE_FIRE_IMG	equ	6
BOMB_IMG	equ	7
TOOL_IMG	equ	8
WALL_IMG	equ	9
BOX_IMG	equ	10
LIFE_ICON_IMG	equ	11
SPEED_ICON_IMG	equ	12
CNT_ICON_IMG	equ	13
RANGE_ICON_IMG	equ	14
BG1_IMG	equ	15
BG2_IMG	equ	16
WARNING_IMG	equ	17
LOGO_IMG	equ	18
HOMEPAGE_IMG	equ	19
PAUSEPAGE_IMG	equ	20
STORY1_IMG	equ	21
STORY2_IMG	equ	22
KEYBOARD_IMG	equ	23
GAMEOVER_IMG	equ	24
QUESTION_IMG	equ	25
WINGAME_IMG	equ	26
SEGERR_IMG	equ	27
CORRECT_IMG	equ	28
WRONG_IMG	equ	29
BLACK_IMG	equ	30

DRAW_GAME_X_START	equ	40
DRAW_GAME_Y_START	equ	90
ELEMENT_WIDTH	equ	60
ELEMENT_HEIGHT	equ	60
DRAW_Y_STEP	equ	ELEMENT_HEIGHT-16

LOGO_WIDTH	equ	400
LOGO_HEIGHT	equ	400
LOGO_X_POS	equ	300
LOGO_Y_POS	equ	150

.data?
bmpCnt	dword	?
bmpStructs	BmpStruct	32 dup(<>)
transitionFrames	dword	?
hFont1	HFONT	?
hFont2	HFONT	?
levelup_question	byte	512 dup(?)
levelup_choice1	byte	64 dup(?)
levelup_choice2	byte	64 dup(?)
levelup_choice3	byte	64 dup(?)
levelup_choice4	byte	64 dup(?)

.const
PLAYER_PATH	byte	"./images/player.bmp",0
MONSTER1_PATH	byte	"./images/monster1.bmp",0
MONSTER2_PATH	byte	"./images/monster2.bmp",0
MONSTER3_PATH	byte	"./images/monster3.bmp",0
DRAGON_PATH	byte	"./images/dragon.bmp",0
FIRE_PATH	byte	"./images/fire.bmp",0
BLUE_FIRE_PATH	byte	"./images/blue_fire.bmp",0
BOMB_PATH	byte	"./images/bomb.bmp",0
WALL_PATH	byte	"./images/wall.bmp",0
BOX_PATH	byte	"./images/box.bmp",0
TOOL_PATH	byte	"./images/tool.bmp",0
LIFE_ICON_PATH	byte	"./images/life_icon.bmp",0
SPEED_ICON_PATH	byte	"./images/speed_icon.bmp",0
CNT_ICON_PATH	byte	"./images/cnt_icon.bmp",0
RANGE_ICON_PATH	byte	"./images/range_icon.bmp",0
BG1_PATH	byte	"./images/bg1.bmp",0
BG2_PATH	byte	"./images/bg2.bmp",0
LOGO_PATH	byte	"./images/logo.png",0
HOMEPAGE_PATH	byte	"./images/home_page.png",0
PAUSEPAGE_PATH	byte	"./images/pause_page.png",0
STORY1_PATH	byte	"./images/story1.png",0
STORY2_PATH	byte	"./images/story2.png",0
KEYBOARD_PATH	byte	"./images/keyboard.png",0
GAMEOVER_PATH	byte	"./images/game_over.png",0
WINGAME_PATH	byte	"./images/win_game.png",0
QUESTION_PATH	byte	"./images/question.png",0
SEGERR_PATH	byte	"./images/segerr.png",0
CORRECT_PATH	byte	"./images/correct.png",0
WRONG_PATH	byte	"./images/wrong.png",0

DENGXIAN	byte	"Arial",0
ONE_INT_FMT	byte	"%d",0
TIME_FMT	byte	"%d:%02d",0
CORRECT_ANSWER	byte	"恭喜你答对了，继续前进吧！（点击任意区域继续游戏）",0
WRONG_ANSWER	byte	"这说明你的IA-32之力已经流失，你的属性将重置。（点击任意区域继续游戏）",0
align	4
DRAW_MAP_JMP_TBL	dword	offset drawEmpty_drawMap,offset drawWall_drawMap,offset drawPlayer_drawMap,offset drawBomb_drawMap,offset drawMonster_drawMap,
							offset drawBox_drawMap,offset drawTool_drawMap,offset drawFire_drawMap,offset drawBoss_drawMap,offset drawBlueFire_drawMap,offset drawAttack_drawMap
DRAW_FUNC_TBL	dword	drawLogo,drawStartPage,drawStory1,drawStory2,drawTutorial,drawMap,drawPause,drawQuestion,drawAnswer,drawGameOver,drawSegErr,drawGameWin
GP_INPUT	GdiplusStartupInput	<1,0,0,0>
STATUS_RECT	RECT	<0,0,WINDOW_WIDTH,60>
QUESTION_RECT	RECT	<100,120,865,360>
CHOICE1_RECT	RECT	<125,488,425,588>
CHOICE2_RECT	RECT	<607,488,907,588>
CHOICE3_RECT	RECT	<125,575,425,675>
CHOICE4_RECT	RECT	<607,575,907,675>
FEEDBACK_RECT	RECT	<100,375,865,400>
DIRECTION_OFFSET_TBL	dword	180,0,60,120
NORMAL_OFFSET_TBL	dword	0,60,120,180,240
DRAGON_OFFSET_TBL	dword	0,135,270,405

.code
;根据颜色、宽度、高度生成纯色位图
registerColorBmp	proc	color:dword,_width:dword,height:dword
	local	rect:RECT,hBrush:HBRUSH
	push	ebx
	mov	ebx,bmpCnt
	lea	ebx,[ebx+2*ebx]
	invoke	CreateBitmap,_width,height,1,32,NULL
	mov	bmpStructs[ebx*8].hBitmap,eax
	invoke	CreateCompatibleDC,NULL
	mov	bmpStructs[ebx*8].bitmapHdc,eax
	invoke	SelectObject,eax,bmpStructs[ebx*8].hBitmap
	mov	rect.left,0
	mov	rect.top,0
	mov	eax,_width
	mov	rect.right,eax
	mov	bmpStructs[ebx*8]._width,eax
	mov	eax,height
	mov	rect.bottom,eax
	mov	bmpStructs[ebx*8].height,eax
	invoke	CreateSolidBrush,color
	mov	hBrush,eax
	invoke	FillRect,bmpStructs[ebx*8].bitmapHdc,addr rect,eax
	invoke	DeleteObject,hBrush
	inc	bmpCnt
	pop	ebx
	ret
registerColorBmp	endp

;使用GDI+注册位图，支持各种图像格式（bmp/png/jpg），可以直接注册带透明通道的
registerBmpFromGdip	proc	path:ptr byte
	local	utf16Str[512]:word,graPtr:dword,imgPtr:dword
	push	ebx
	invoke	MultiByteToWideChar,CP_ACP,NULL,path,-1,addr utf16Str,sizeof utf16Str
	invoke	GdipLoadImageFromFile,addr utf16Str,addr imgPtr
	mov	ebx,bmpCnt
	lea	ebx,[ebx+2*ebx]
	lea	eax,bmpStructs[ebx*8]._width
	invoke	GdipGetImageWidth,imgPtr,eax
	lea	eax,bmpStructs[ebx*8].height
	invoke	GdipGetImageHeight,imgPtr,eax
	invoke	CreateBitmap,bmpStructs[ebx*8]._width,bmpStructs[ebx*8].height,1,32,NULL
	mov	bmpStructs[ebx*8].hBitmap,eax
	invoke	CreateCompatibleDC,NULL
	mov	bmpStructs[ebx*8].bitmapHdc,eax
	invoke	SelectObject,eax,bmpStructs[ebx*8].hBitmap
	invoke	GdipCreateFromHDC,bmpStructs[ebx*8].bitmapHdc,addr graPtr
	invoke	GdipDrawImageI,graPtr,imgPtr,0,0
	invoke	GdipDisposeImage,imgPtr
	invoke	GdipReleaseDC,graPtr,bmpStructs[ebx*8].bitmapHdc
	invoke	GdipDeleteGraphics,graPtr
	inc	bmpCnt
	pop	ebx
	ret
registerBmpFromGdip	endp

;注册位图，仅支持bmp格式，transparentColor为0时不生成掩码位图
registerBmp	proc	path:ptr byte,transparentColor:dword	;set transparentColor to 0 to cancel transparent
	local	bmpInfo:BITMAP
	push	ebx
	invoke	LoadImage,NULL,path,IMAGE_BITMAP,0,0,LR_LOADFROMFILE
	mov	ebx,bmpCnt
	lea	ebx,[ebx+2*ebx]	;The size of BmpStruct is 24. Here ebx=bmpCnt*3. Later use ebx*8.
	mov	bmpStructs[ebx*8].hBitmap,eax
	lea	edx,bmpInfo
	push	edx
	push	sizeof BITMAP
	push	eax
	call	GetObject	;还是老原因，invoke只会用eax来lea
	mov	eax,bmpInfo.bmWidth
	mov	bmpStructs[ebx*8]._width,eax
	mov	eax,bmpInfo.bmHeight
	mov	bmpStructs[ebx*8].height,eax
	invoke	CreateCompatibleDC,NULL
	mov	bmpStructs[ebx*8].bitmapHdc,eax
	invoke	SelectObject,eax,bmpStructs[ebx*8].hBitmap
	cmp	transparentColor,0
	je	exit_registerBmp
	;if use transparent
	invoke	CreateBitmap,bmpInfo.bmWidth,bmpInfo.bmHeight,1,1,NULL
	mov	bmpStructs[ebx*8].hMaskBitmap,eax
	invoke	CreateCompatibleDC,NULL
	mov	bmpStructs[ebx*8].maskBitmapHdc,eax
	invoke	SelectObject,eax,bmpStructs[ebx*8].hMaskBitmap
	invoke	SetBkColor,bmpStructs[ebx*8].bitmapHdc,transparentColor
	invoke	BitBlt,bmpStructs[ebx*8].maskBitmapHdc,0,0,bmpInfo.bmWidth,bmpInfo.bmHeight,bmpStructs[ebx*8].bitmapHdc,0,0,SRCCOPY
	invoke	SetBkColor,bmpStructs[ebx*8].bitmapHdc,0
	invoke	SetTextColor,bmpStructs[ebx*8].bitmapHdc,0ffffffh
	invoke	BitBlt,bmpStructs[ebx*8].bitmapHdc,0,0,bmpInfo.bmWidth,bmpInfo.bmHeight,bmpStructs[ebx*8].maskBitmapHdc,0,0,SRCAND
exit_registerBmp:
	inc	bmpCnt
	pop	ebx
	ret
registerBmp	endp

;加载图片资源
initResources	proc
	local	gdiToken:dword
	invoke	GdiplusStartup,addr gdiToken,offset GP_INPUT,NULL	;GDI+，启动！
	invoke	registerBmp,offset PLAYER_PATH,0ffffffh
	invoke	registerBmp,offset MONSTER1_PATH,0ffffffh
	invoke	registerBmp,offset MONSTER2_PATH,0ffffffh
	invoke	registerBmp,offset MONSTER3_PATH,0ffffffh
	invoke	registerBmp,offset DRAGON_PATH,0ffffffh
	invoke	registerBmp,offset FIRE_PATH,0ffffffh
	invoke	registerBmp,offset BLUE_FIRE_PATH,0ff00h
	invoke	registerBmp,offset BOMB_PATH,0ffffffh
	invoke	registerBmp,offset TOOL_PATH,0ffffffh
	invoke	registerBmp,offset WALL_PATH,0
	invoke	registerBmp,offset BOX_PATH,0
	invoke	registerBmp,offset LIFE_ICON_PATH,0
	invoke	registerBmp,offset SPEED_ICON_PATH,0
	invoke	registerBmp,offset CNT_ICON_PATH,0
	invoke	registerBmp,offset RANGE_ICON_PATH,0
	invoke	registerBmp,offset BG1_PATH,0
	invoke	registerBmp,offset BG2_PATH,0
	invoke	registerColorBmp,0ffh,ELEMENT_WIDTH,DRAW_Y_STEP	;attack red
	invoke	registerBmpFromGdip,offset LOGO_PATH
	invoke	registerBmpFromGdip,offset HOMEPAGE_PATH
	invoke	registerBmpFromGdip,offset PAUSEPAGE_PATH
	invoke	registerBmpFromGdip,offset STORY1_PATH
	invoke	registerBmpFromGdip,offset STORY2_PATH
	invoke	registerBmpFromGdip,offset KEYBOARD_PATH
	invoke	registerBmpFromGdip,offset GAMEOVER_PATH
	invoke	registerBmpFromGdip,offset QUESTION_PATH
	invoke	registerBmpFromGdip,offset WINGAME_PATH
	invoke	registerBmpFromGdip,offset SEGERR_PATH
	invoke	registerBmpFromGdip,offset CORRECT_PATH
	invoke	registerBmpFromGdip,offset WRONG_PATH
	invoke	registerColorBmp,0,WINDOW_WIDTH,WINDOW_HEIGHT	;fade effect black
	invoke	GdiplusShutdown,gdiToken	;关闭GDI+，你可以爬了
	invoke	CreateFont,30,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,offset DENGXIAN
	mov	hFont1,eax
	invoke	CreateFont,24,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,offset DENGXIAN
	mov	hFont2,eax
	ret
initResources	endp

releaseResources	proc
	local	maxSize:dword
	push	ebx
	xor	ebx,ebx
	mov	eax,bmpCnt
	imul	eax,sizeof BmpStruct
	mov	maxSize,eax
loop1_releaseResources:
	cmp	ebx,maxSize
	je	exitLoop1_releaseResources
	invoke	DeleteDC,bmpStructs[ebx].bitmapHdc
	invoke	DeleteDC,bmpStructs[ebx].maskBitmapHdc
	invoke	DeleteObject,bmpStructs[ebx].hBitmap
	invoke	DeleteObject,bmpStructs[ebx].hMaskBitmap
	add	ebx,sizeof BmpStruct
	jmp	loop1_releaseResources
exitLoop1_releaseResources:
	invoke	DeleteObject,hFont1
	invoke	DeleteObject,hFont2
	pop	ebx
	ret
releaseResources	endp

calcDrawPos	proc	xPos:dword,yPos:dword,frac_x:dword,frac_y:dword,drawXPos:ptr dword,drawYPos:ptr dword
	;每一个格子t个像素，每个格子小坐标范围是-k到k，当前小坐标是n，有符号运算，n*t/(2*k)是最终偏移量
	mov	edx,ELEMENT_WIDTH
	mov	eax,frac_x
	imul	edx
	mov	ecx,FRAC_RANGE*2
	idiv	ecx
	mov	edx,xPos
	add	edx,eax
	mov	eax,drawXPos
	mov	[eax],edx
	mov	edx,DRAW_Y_STEP
	mov	eax,frac_y
	imul	edx
	mov	ecx,FRAC_RANGE*2
	idiv	ecx
	mov	edx,yPos
	add	edx,eax
	mov	eax,drawYPos
	mov	[eax],edx
	ret
calcDrawPos	endp

drawMap	proc
	;ebx：地图偏移量，esi:xPos，edi:yPos
	local	layer:dword,id:dword,drawXPos:dword,drawYPos:dword,monsterSpeed:dword
	local	bossFlyWidth:dword,bossFlyHeight:dword
	local	tempStr[13]:byte
	push	ebx
	push	esi
	push	edi
	invoke	SetBkColor,hdcBuffer,0ffffffh
	invoke	SetTextColor,hdcBuffer,0
	mov	eax,game.level
	inc	eax
	cmp	eax,level_cnt
	je	drawBossBG_drawMap
	invoke	BitBlt,hdcBuffer,0,60,WINDOW_WIDTH,WINDOW_HEIGHT,bmpStructs[BG1_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	jmp	endDrawBG_drawMap
drawBossBG_drawMap:
	invoke	BitBlt,hdcBuffer,0,60,WINDOW_WIDTH,WINDOW_HEIGHT,bmpStructs[BG2_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
endDrawBG_drawMap:
	xor	ebx,ebx
	mov	esi,DRAW_GAME_X_START
	mov	edi,DRAW_GAME_Y_START
	mov	layer,0
mainLoop_drawMap:
	movzx	eax,game.map[ebx*4]._type
	movzx	edx,game.map[ebx*4].id
	mov	id,edx
	jmp	[DRAW_MAP_JMP_TBL+eax*4]
drawWall_drawMap	label	dword
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[WALL_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	jmp	exitSwitch_drawMap
drawPlayer_drawMap	label	dword
	mov	eax,game.player.timer
	shr	eax,3	;分频待定
	and	eax,1
	jnz	exitSwitch_drawMap	;无敌状态玩家闪烁
	invoke	calcDrawPos,esi,edi,game.player.frac_y,game.player.frac_x,addr drawXPos,addr drawYPos
	mov	eax,game.player.direction
	mov	eax,[DIRECTION_OFFSET_TBL+eax*4]
	xor	edx,edx
	cmp	game.player.isMove,STILL
	je	playerNotMove_drawMap
	mov	edx,game.timer
	shr	edx,3	;分频待定
	and	edx,3
	mov	edx,[NORMAL_OFFSET_TBL+edx*4]
playerNotMove_drawMap:
	push	eax
	push	edx
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[PLAYER_IMG*sizeof BmpStruct].maskBitmapHdc,edx,eax,SRCAND
	pop	edx
	pop	eax
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[PLAYER_IMG*sizeof BmpStruct].bitmapHdc,edx,eax,SRCPAINT
	jmp	exitSwitch_drawMap
drawBomb_drawMap	label	dword
	mov	eax,id
	imul	eax,sizeof Bomb
	mov	eax,game.bombs[eax].timer
	shr	eax,4	;分频待定
	and	eax,1
	mov	eax,[NORMAL_OFFSET_TBL+eax*4]
	push	eax
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[BOMB_IMG*sizeof BmpStruct].maskBitmapHdc,eax,0,SRCAND
	pop	eax
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[BOMB_IMG*sizeof BmpStruct].bitmapHdc,eax,0,SRCPAINT
	jmp	exitSwitch_drawMap
drawMonster_drawMap	label	dword
	mov	eax,id
	imul	eax,sizeof Monster
	mov	edx,game.monsters[eax].speed
	mov	monsterSpeed,edx
	mov	edx,game.monsters[eax].direction
	mov	edx,[DIRECTION_OFFSET_TBL+4*edx]
	push	edx
	lea	edx,drawYPos
	push	edx
	lea	edx,drawXPos
	push	edx
	push	game.monsters[eax].frac_x
	push	game.monsters[eax].frac_y
	push	edi
	push	esi
	call	calcDrawPos	;为什么要手动call呢？因为这个傻逼masm的addr运算符默认用eax来lea，把eax的值给干没了
	pop	edx
	mov	eax,game.timer
	shr	eax,3
	and	eax,3
	mov	eax,[NORMAL_OFFSET_TBL+4*eax]
	push	eax
	push	edx
	cmp	monsterSpeed,MONSTER_1_SPEED
	jle	drawMonster1_drawMap
	cmp	monsterSpeed,MONSTER_2_SPEED
	jle	drawMonster2_drawMap
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[MONSTER3_IMG*sizeof BmpStruct].maskBitmapHdc,eax,edx,SRCAND
	pop	edx
	pop	eax
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[MONSTER3_IMG*sizeof BmpStruct].bitmapHdc,eax,edx,SRCPAINT
	jmp	exitSwitch_drawMap
drawMonster1_drawMap:
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[MONSTER1_IMG*sizeof BmpStruct].maskBitmapHdc,eax,edx,SRCAND
	pop	edx
	pop	eax
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[MONSTER1_IMG*sizeof BmpStruct].bitmapHdc,eax,edx,SRCPAINT
	jmp	exitSwitch_drawMap
drawMonster2_drawMap:
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[MONSTER2_IMG*sizeof BmpStruct].maskBitmapHdc,eax,edx,SRCAND
	pop	edx
	pop	eax
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[MONSTER2_IMG*sizeof BmpStruct].bitmapHdc,eax,edx,SRCPAINT
	jmp	exitSwitch_drawMap
drawBox_drawMap	label	dword
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[BOX_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	jmp	exitSwitch_drawMap
drawTool_drawMap	label	dword
	mov	eax,id
	imul	eax,sizeof Tool
	mov	eax,game.tools[eax]._type
	mov	eax,[NORMAL_OFFSET_TBL+eax*4]
	push	eax
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[TOOL_IMG*sizeof BmpStruct].maskBitmapHdc,eax,0,SRCAND
	pop	eax
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[TOOL_IMG*sizeof BmpStruct].bitmapHdc,eax,0,SRCPAINT
	jmp	exitSwitch_drawMap
drawFire_drawMap	label	dword
	;第0张图是火焰消失，第3张图是火焰刚出来
	mov	eax,id
	imul	eax,sizeof Bomb
	mov	eax,game.bombs[eax].timer
	shr	eax,2	;分频待定
	and	eax,3
	mov	eax,[NORMAL_OFFSET_TBL+eax*4]
	push	eax
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[FIRE_IMG*sizeof BmpStruct].maskBitmapHdc,eax,0,SRCAND
	pop	eax
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,bmpStructs[FIRE_IMG*sizeof BmpStruct].bitmapHdc,eax,0,SRCPAINT
	jmp	exitSwitch_drawMap
drawBoss_drawMap	label	dword
	mov	eax,game.timer
	shr	eax,3
	and	eax,3
	mov	eax,[DRAGON_OFFSET_TBL+eax*4]
	mov	drawXPos,esi
	sub	drawXPos,37
	mov	drawYPos,edi
	sub	drawYPos,60
	push	eax
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,135,3*ELEMENT_HEIGHT,bmpStructs[DRAGON_IMG*sizeof BmpStruct].maskBitmapHdc,eax,0,SRCAND
	pop	eax
	invoke	BitBlt,hdcBuffer,drawXPos,drawYPos,135,3*ELEMENT_HEIGHT,bmpStructs[DRAGON_IMG*sizeof BmpStruct].bitmapHdc,eax,0,SRCPAINT
	jmp	exitSwitch_drawMap
drawBlueFire_drawMap	label	dword
	mov	eax,id
	imul	eax,sizeof Attack
	mov	eax,game.attacks[eax].timer
	shr	eax,2	;分频待定
	and	eax,3
	mov	eax,[NORMAL_OFFSET_TBL+eax*4]
	mov	drawYPos,edi
	sub	drawYPos,ELEMENT_HEIGHT
	push	eax
	invoke	BitBlt,hdcBuffer,esi,drawYPos,ELEMENT_WIDTH,2*ELEMENT_HEIGHT,bmpStructs[BLUE_FIRE_IMG*sizeof BmpStruct].maskBitmapHdc,eax,0,SRCAND
	pop	eax
	invoke	BitBlt,hdcBuffer,esi,drawYPos,ELEMENT_WIDTH,2*ELEMENT_HEIGHT,bmpStructs[BLUE_FIRE_IMG*sizeof BmpStruct].bitmapHdc,eax,0,SRCPAINT
	jmp	exitSwitch_drawMap
drawAttack_drawMap	label	dword
	invoke	AlphaBlend,hdcBuffer,esi,edi,ELEMENT_WIDTH,DRAW_Y_STEP,bmpStructs[WARNING_IMG*sizeof BmpStruct].bitmapHdc,0,0,ELEMENT_WIDTH,DRAW_Y_STEP,00800000h	;alpha=128
	jmp	exitSwitch_drawMap
drawEmpty_drawMap	label	dword
exitSwitch_drawMap:
	inc	ebx
	inc	layer
	cmp	layer,DEPTH
	jne	mainLoop_drawMap
	mov	layer,0
	add	esi,ELEMENT_WIDTH
	cmp	esi,DRAW_GAME_X_START+ELEMENT_WIDTH*COL
	jne	mainLoop_drawMap
	mov	esi,DRAW_GAME_X_START
	add	edi,DRAW_Y_STEP
	cmp	edi,DRAW_GAME_Y_START+DRAW_Y_STEP*ROW
	jne	mainLoop_drawMap
exitMainLoop_drawMap:
	cmp	game.boss.state,TAKEOFF_STATE
	je	startDrawBossFly_drawMap
	cmp	game.boss.state,LANDING_STATE
	je	startDrawBossFly_drawMap
	jmp	skipDrawBossFly_drawMap
startDrawBossFly_drawMap:
	mov	esi,game.boss.y
	imul	esi,ELEMENT_WIDTH
	add	esi,DRAW_GAME_X_START
	mov	edi,game.boss.x
	imul	edi,DRAW_Y_STEP
	add	edi,DRAW_GAME_Y_START
	cmp	game.boss.state,LANDING_STATE
	je	testBossLanding_drawMap
	mov	eax,TAKEOFF_TIME
	sub	eax,game.boss.timer
	cmp	eax,15
	jl	drawBossFlyCommon_drawMap
	;draw boss leave
	shl	eax,4
	lea	edx,[edi+eax-420]
	mov	drawYPos,edx
	mov	drawXPos,esi
	sub	drawXPos,60
	mov	bossFlyWidth,180
	mov	bossFlyHeight,240
	jmp	finalDrawBossFly_drawMap
testBossLanding_drawMap:
	mov	eax,game.boss.timer
	cmp	eax,15
	jl	drawBossFlyCommon_drawMap
	;draw boss come
	shl	eax,4
	neg	eax
	lea	edx,[edi+eax+60]
	mov	drawYPos,edx
	mov	drawXPos,esi
	sub	drawXPos,60
	mov	bossFlyWidth,180
	mov	bossFlyHeight,240
	jmp	finalDrawBossFly_drawMap
drawBossFlyCommon_drawMap:
	lea	edx,[eax+eax*2+135]	;edx=3*eax+135
	mov	bossFlyWidth,edx
	lea	edx,[eax*4+180]	;edx=4*eax+180
	mov	bossFlyHeight,edx
	lea	edx,[eax*8]	
	neg	edx
	lea	edx,[edi+edx-60]	;edx=y-8*eax-60
	mov	drawYPos,edx
	lea	edx,[eax+eax*2+75]
	sar	edx,1
	neg	edx
	lea	edx,[esi+edx]	;edx=x-(3*eax+75)/2
	mov	drawXPos,edx
finalDrawBossFly_drawMap:
	mov	eax,game.timer
	shr	eax,3
	and	eax,3
	mov	eax,[DRAGON_OFFSET_TBL+eax*4]
	push	eax
	invoke	StretchBlt,hdcBuffer,drawXPos,drawYPos,bossFlyWidth,bossFlyHeight,bmpStructs[DRAGON_IMG*sizeof BmpStruct].maskBitmapHdc,eax,0,135,180,SRCAND
	pop	eax
	invoke	StretchBlt,hdcBuffer,drawXPos,drawYPos,bossFlyWidth,bossFlyHeight,bmpStructs[DRAGON_IMG*sizeof BmpStruct].bitmapHdc,eax,0,135,180,SRCPAINT
skipDrawBossFly_drawMap:
	invoke	FillRect,hdcBuffer,offset STATUS_RECT,COLOR_WINDOW+1
	invoke	BitBlt,hdcBuffer,100,10,40,40,bmpStructs[LIFE_ICON_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	invoke	BitBlt,hdcBuffer,300,10,40,40,bmpStructs[SPEED_ICON_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	invoke	BitBlt,hdcBuffer,600,10,40,40,bmpStructs[CNT_ICON_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	invoke	BitBlt,hdcBuffer,800,10,40,40,bmpStructs[RANGE_ICON_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	invoke	SelectObject,hdcBuffer,hFont1
	invoke	crt_sprintf,addr tempStr,offset ONE_INT_FMT,game.player.life
	invoke	crt_strlen,addr tempStr
	invoke	TextOut,hdcBuffer,150,20,addr tempStr,eax
	mov	eax,game.player.speed
	sub	eax,11
	invoke	crt_sprintf,addr tempStr,offset ONE_INT_FMT,eax
	invoke	crt_strlen,addr tempStr
	invoke	TextOut,hdcBuffer,350,20,addr tempStr,eax
	invoke	crt_sprintf,addr tempStr,offset ONE_INT_FMT,game.player.bomb_cnt
	invoke	crt_strlen,addr tempStr
	invoke	TextOut,hdcBuffer,650,20,addr tempStr,eax
	invoke	crt_sprintf,addr tempStr,offset ONE_INT_FMT,game.player.bomb_range
	invoke	crt_strlen,addr tempStr
	invoke	TextOut,hdcBuffer,850,20,addr tempStr,eax
	mov	eax,game.timer
	xor	edx,edx
	mov	ecx,FRAMES_PER_SEC
	div	ecx	;eax是秒数
	cmp	eax,30
	jg	notSetRed_drawMap
	push	eax
	invoke	SetTextColor,hdcBuffer,00000ffh
	pop	eax
notSetRed_drawMap:
	xor	edx,edx
	mov	ecx,60	;1min=60s
	div	ecx	;eax是分，edx是秒
	invoke	crt_sprintf,addr tempStr,offset TIME_FMT,eax,edx
	invoke	crt_strlen,addr tempStr
	invoke	TextOut,hdcBuffer,465,20,addr tempStr,eax
	pop	edi
	pop	esi
	pop	ebx
	ret
drawMap	endp

drawLogo	proc
	invoke	StretchBlt,hdcBuffer,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT,bmpStructs[LOGO_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[LOGO_IMG*sizeof BmpStruct]._width,bmpStructs[LOGO_IMG*sizeof BmpStruct].height,SRCCOPY
	mov	eax,mainwinp.timer
	cmp	eax,15
	jge	dontDrawFadeIn_drawLogo
	imul	eax,17	;15*17=255
	shl	eax,16
	mov	edx,0ff0000h
	sub	edx,eax
	invoke	AlphaBlend,hdcBuffer,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,bmpStructs[BLACK_IMG*sizeof BmpStruct].bitmapHdc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,edx
dontDrawFadeIn_drawLogo:
	ret
drawLogo	endp

drawStartPage	proc
	invoke	StretchBlt,hdcBuffer,0,0,984,711,bmpStructs[HOMEPAGE_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[HOMEPAGE_IMG*sizeof BmpStruct]._width,bmpStructs[HOMEPAGE_IMG*sizeof BmpStruct].height,SRCCOPY
	ret
drawStartPage	endp

drawStory1	proc
	invoke	StretchBlt,hdcBuffer,0,0,984,711,bmpStructs[STORY1_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[STORY1_IMG*sizeof BmpStruct]._width,bmpStructs[STORY1_IMG*sizeof BmpStruct].height,SRCCOPY
	ret
drawStory1	endp

drawStory2	proc
	invoke	StretchBlt,hdcBuffer,246,0,492,711,bmpStructs[STORY2_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[STORY2_IMG*sizeof BmpStruct]._width,bmpStructs[STORY2_IMG*sizeof BmpStruct].height,SRCCOPY
	ret
drawStory2	endp

drawTutorial	proc
	invoke	StretchBlt,hdcBuffer,0,0,984,711,bmpStructs[KEYBOARD_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[KEYBOARD_IMG*sizeof BmpStruct]._width,bmpStructs[KEYBOARD_IMG*sizeof BmpStruct].height,SRCCOPY
	ret
drawTutorial	endp

drawPause	proc
	invoke	drawMap
	invoke	StretchBlt,hdcBuffer,150,112,689,498,bmpStructs[PAUSEPAGE_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[PAUSEPAGE_IMG*sizeof BmpStruct]._width,bmpStructs[PAUSEPAGE_IMG*sizeof BmpStruct].height,SRCCOPY
	ret
drawPause	endp

drawGameOver	proc
	invoke	StretchBlt,hdcBuffer,0,0,984,711,bmpStructs[GAMEOVER_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[GAMEOVER_IMG*sizeof BmpStruct]._width,bmpStructs[GAMEOVER_IMG*sizeof BmpStruct].height,SRCCOPY
	ret
drawGameOver	endp

drawSegErr	proc
	invoke	drawMap
	mov	eax,game.boss.x
	imul	eax,DRAW_Y_STEP
	add	eax,20
	mov	ecx,eax
	mov	eax,game.boss.y
	imul	eax,ELEMENT_WIDTH
	sub	eax,120
	invoke	BitBlt,hdcBuffer,eax,ecx,bmpStructs[SEGERR_IMG*sizeof BmpStruct]._width,bmpStructs[SEGERR_IMG*sizeof BmpStruct].height,bmpStructs[SEGERR_IMG*sizeof BmpStruct].bitmapHdc,0,0,SRCCOPY
	ret
drawSegErr	endp

drawGameWin	proc
	invoke	StretchBlt,hdcBuffer,0,0,984,711,bmpStructs[WINGAME_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[WINGAME_IMG*sizeof BmpStruct]._width,bmpStructs[WINGAME_IMG*sizeof BmpStruct].height,SRCCOPY
	ret
drawGameWin	endp

drawQuestion	proc
	local	prevMode:dword
	invoke	StretchBlt,hdcBuffer,0,0,984,711,bmpStructs[QUESTION_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[QUESTION_IMG*sizeof BmpStruct]._width,bmpStructs[QUESTION_IMG*sizeof BmpStruct].height,SRCCOPY
	invoke	SelectObject,hdcBuffer,hFont2
	invoke	SetTextColor,hdcBuffer,0
	invoke	SetBkMode,hdcBuffer,TRANSPARENT
	mov	prevMode,eax
	invoke	DrawText,hdcBuffer,offset levelup_question,-1,offset QUESTION_RECT,DT_LEFT OR DT_TOP OR DT_WORDBREAK
	invoke	DrawText,hdcBuffer,offset levelup_choice1,-1,offset CHOICE1_RECT,DT_LEFT OR DT_TOP
	invoke	DrawText,hdcBuffer,offset levelup_choice2,-1,offset CHOICE2_RECT,DT_LEFT OR DT_TOP
	invoke	DrawText,hdcBuffer,offset levelup_choice3,-1,offset CHOICE3_RECT,DT_LEFT OR DT_TOP
	invoke	DrawText,hdcBuffer,offset levelup_choice4,-1,offset CHOICE4_RECT,DT_LEFT OR DT_TOP
	invoke	SetBkMode,hdcBuffer,prevMode
	ret
drawQuestion	endp

drawAnswer	proc
	local	prevMode:dword
	invoke	drawQuestion	;已经设置过字体了，接着用
	invoke	SetBkMode,hdcBuffer,TRANSPARENT
	mov	prevMode,eax
	cmp	mainwinp.correctAnswer,0
	je	correctA_drawAnswer
	cmp	mainwinp.correctAnswer,1
	je	correctB_drawAnswer
	cmp	mainwinp.correctAnswer,2
	je	correctC_drawAnswer
	;AlphaBlend函数可以画带透明通道的32位位图
	invoke	AlphaBlend,hdcBuffer,807,560,50,50,bmpStructs[CORRECT_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[CORRECT_IMG*sizeof BmpStruct]._width,bmpStructs[CORRECT_IMG*sizeof BmpStruct].height,1ff0000h
	jmp	exitSwitch1_drawAnswer
correctA_drawAnswer:
	invoke	AlphaBlend,hdcBuffer,325,477,50,50,bmpStructs[CORRECT_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[CORRECT_IMG*sizeof BmpStruct]._width,bmpStructs[CORRECT_IMG*sizeof BmpStruct].height,1ff0000h
	jmp	exitSwitch1_drawAnswer
correctB_drawAnswer:
	invoke	AlphaBlend,hdcBuffer,807,477,50,50,bmpStructs[CORRECT_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[CORRECT_IMG*sizeof BmpStruct]._width,bmpStructs[CORRECT_IMG*sizeof BmpStruct].height,1ff0000h
	jmp	exitSwitch1_drawAnswer
correctC_drawAnswer:
	invoke	AlphaBlend,hdcBuffer,325,560,50,50,bmpStructs[CORRECT_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[CORRECT_IMG*sizeof BmpStruct]._width,bmpStructs[CORRECT_IMG*sizeof BmpStruct].height,1ff0000h
exitSwitch1_drawAnswer:
	mov	eax,mainwinp.correctAnswer
	cmp	eax,mainwinp.playerAnswer
	jne	wa_drawAnswer
	invoke	DrawText,hdcBuffer,offset CORRECT_ANSWER,-1,offset FEEDBACK_RECT,DT_CENTER
	jmp	exit_drawAnswer
wa_drawAnswer:
	cmp	mainwinp.playerAnswer,0
	je	wrongA_drawAnswer
	cmp	mainwinp.playerAnswer,1
	je	wrongB_drawAnswer
	cmp	mainwinp.playerAnswer,2
	je	wrongC_drawAnswer
	invoke	AlphaBlend,hdcBuffer,807,560,50,50,bmpStructs[WRONG_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[WRONG_IMG*sizeof BmpStruct]._width,bmpStructs[WRONG_IMG*sizeof BmpStruct].height,1ff0000h
	jmp	exitSwitch2_drawAnswer
wrongA_drawAnswer:
	invoke	AlphaBlend,hdcBuffer,325,477,50,50,bmpStructs[WRONG_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[WRONG_IMG*sizeof BmpStruct]._width,bmpStructs[WRONG_IMG*sizeof BmpStruct].height,1ff0000h
	jmp	exitSwitch2_drawAnswer
wrongB_drawAnswer:
	invoke	AlphaBlend,hdcBuffer,807,477,50,50,bmpStructs[WRONG_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[WRONG_IMG*sizeof BmpStruct]._width,bmpStructs[WRONG_IMG*sizeof BmpStruct].height,1ff0000h
	jmp	exitSwitch2_drawAnswer
wrongC_drawAnswer:
	invoke	AlphaBlend,hdcBuffer,325,560,50,50,bmpStructs[WRONG_IMG*sizeof BmpStruct].bitmapHdc,0,0,bmpStructs[WRONG_IMG*sizeof BmpStruct]._width,bmpStructs[WRONG_IMG*sizeof BmpStruct].height,1ff0000h
exitSwitch2_drawAnswer:
	invoke	DrawText,hdcBuffer,offset WRONG_ANSWER,-1,offset FEEDBACK_RECT,DT_CENTER
exit_drawAnswer:
	invoke	SetBkMode,hdcBuffer,prevMode
	ret
drawAnswer	endp

;这个东西还负责状态间的切换和延迟过程调用哦，分为淡入淡出和立即两种
;这样某些状态就只用更新的时候绘制一次，不用一直重绘，节省CPU
drawWindow	proc
	mov	eax,mainwinp.currentState
	cmp	eax,mainwinp.intentState
	jne	drawTransition_drawWindow
	call	DRAW_FUNC_TBL[eax*4]
	ret
drawTransition_drawWindow:
	cmp	mainwinp.shouldFade,0
	jne	fade_drawWindow
	cmp	mainwinp.transitionFunc,NULL
	je	skipFunc_drawWindow
	call	mainwinp.transitionFunc
skipFunc_drawWindow:
	mov	eax,mainwinp.intentState
	mov	mainwinp.currentState,eax
	call	DRAW_FUNC_TBL[eax*4]
	ret
fade_drawWindow:
	cmp	transitionFrames,15
	jl	drawPrev_drawWindow
	jne	drawIntent_drawWindow
	cmp	mainwinp.transitionFunc,NULL
	je	drawIntent_drawWindow
	call	mainwinp.transitionFunc
drawIntent_drawWindow:
	mov	eax,mainwinp.intentState
	call	DRAW_FUNC_TBL[eax*4]
	mov	edx,0ff0000h
	mov	eax,transitionFrames
	sub	eax,14
	imul	eax,17
	shl	eax,16
	sub	edx,eax
	jmp	exitDrawTransition
drawPrev_drawWindow:
	call	DRAW_FUNC_TBL[eax*4]
	mov	edx,transitionFrames
	inc	edx
	imul	edx,17
	shl	edx,16
exitDrawTransition:
	invoke	AlphaBlend,hdcBuffer,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,bmpStructs[BLACK_IMG*sizeof BmpStruct].bitmapHdc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,edx
	inc	transitionFrames
	cmp	transitionFrames,30
	jne	exit_drawWindow
	mov	transitionFrames,0
	mov	eax,mainwinp.intentState
	mov	mainwinp.currentState,eax
exit_drawWindow:
	ret
drawWindow	endp
end
