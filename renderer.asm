.486
.model	flat,stdcall
option	casemap:none

include	common.inc
extrn	game:Game
extrn	mainwinp:MainWinp

drawImage	equ	GdipDrawImageRectI

PLY1_UP_IMG	equ	0
PLY1_DOWN_IMG	equ	4
PLY1_LEFT_IMG	equ	8
PLY1_RIGHT_IMG	equ	12
MON1_UP_IMG	equ	16
MON1_DOWN_IMG	equ	20
MON1_LEFT_IMG	equ	24
MON1_RIGHT_IMG	equ	28
MON2_UP_IMG	equ	32
MON2_DOWN_IMG	equ	36
MON2_LEFT_IMG	equ	40
MON2_RIGHT_IMG	equ	44
MON3_UP_IMG	equ	48
MON3_DOWN_IMG	equ	52
MON3_LEFT_IMG	equ	56
MON3_RIGHT_IMG	equ	60
DRA_IMG	equ	64
FIRE_IMG	equ	68
BFIRE_IMG	equ	72
BOMB_IMG	equ	76
TOOL_IMG	equ	78
LIFE_TOOL_IMG	equ	78
RANGE_TOOL_IMG	equ	79
CNT_TOOL_IMG	equ	80
SPEED_TOOL_IMG	equ	81
TIME_TOOL_IMG	equ	82
LOGO_IMG	equ	83
HOMEPAGE_IMG	equ	84
PAUSEPAGE_IMG	equ	85
IMG_CNT	equ	86

DRAW_GAME_X_START	equ	40
DRAW_GAME_Y_START	equ	90
ELEMENT_WIDTH	equ	60
ELEMENT_HEIGHT	equ	60
DRAW_Y_STEP	equ	ELEMENT_HEIGHT-16

LOGO_WIDTH	equ	400
LOGO_HEIGHT	equ	400
LOGO_X_POS	equ	300
LOGO_Y_POS	equ	150
.data
DENGXIAN_FONT	StrFont	<FONT_NAME_LEN dup(?),12.0,0ffffffffh,FontStyleRegular>

.data?
bitmapPtrs	dword	100 dup(?)
logoBitmapPtr	dword	?
startPageBitmapPtr	dword	?
storyUtf16Str	word	1024 dup(?)
bg1Info	BitmapInfo	<>
bg2Info	BitmapInfo	<>
wallInfo	BitmapInfo	<>
boxInfo	BitmapInfo	<>
lifeIconInfo	BitmapInfo	<>
speedIconInfo	BitmapInfo	<>
cntIconInfo	BitmapInfo	<>
rangeIconInfo	BitmapInfo	<>
hFont1	HFONT	?

.const
PLAYER1_UP1_PATH	byte	"./images/player1_up1.png",0
PLAYER1_UP2_PATH	byte	"./images/player1_up2.png",0
PLAYER1_UP3_PATH	byte	"./images/player1_up3.png",0
PLAYER1_UP4_PATH	byte	"./images/player1_up4.png",0
PLAYER1_DOWN1_PATH	byte	"./images/player1_down1.png",0
PLAYER1_DOWN2_PATH	byte	"./images/player1_down2.png",0
PLAYER1_DOWN3_PATH	byte	"./images/player1_down3.png",0
PLAYER1_DOWN4_PATH	byte	"./images/player1_down4.png",0
PLAYER1_LEFT1_PATH	byte	"./images/player1_left1.png",0
PLAYER1_LEFT2_PATH	byte	"./images/player1_left2.png",0
PLAYER1_LEFT3_PATH	byte	"./images/player1_left3.png",0
PLAYER1_LEFT4_PATH	byte	"./images/player1_left4.png",0
PLAYER1_RIGHT1_PATH	byte	"./images/player1_right1.png",0
PLAYER1_RIGHT2_PATH	byte	"./images/player1_right2.png",0
PLAYER1_RIGHT3_PATH	byte	"./images/player1_right3.png",0
PLAYER1_RIGHT4_PATH	byte	"./images/player1_right4.png",0
MONSTER1_UP1_PATH	byte	"./images/monster1_up1.png",0
MONSTER1_UP2_PATH	byte	"./images/monster1_up2.png",0
MONSTER1_UP3_PATH	byte	"./images/monster1_up3.png",0
MONSTER1_UP4_PATH	byte	"./images/monster1_up4.png",0
MONSTER1_DOWN1_PATH	byte	"./images/monster1_down1.png",0
MONSTER1_DOWN2_PATH	byte	"./images/monster1_down2.png",0
MONSTER1_DOWN3_PATH	byte	"./images/monster1_down3.png",0
MONSTER1_DOWN4_PATH	byte	"./images/monster1_down4.png",0
MONSTER1_LEFT1_PATH	byte	"./images/monster1_left1.png",0
MONSTER1_LEFT2_PATH	byte	"./images/monster1_left2.png",0
MONSTER1_LEFT3_PATH	byte	"./images/monster1_left3.png",0
MONSTER1_LEFT4_PATH	byte	"./images/monster1_left4.png",0
MONSTER1_RIGHT1_PATH	byte	"./images/monster1_right1.png",0
MONSTER1_RIGHT2_PATH	byte	"./images/monster1_right2.png",0
MONSTER1_RIGHT3_PATH	byte	"./images/monster1_right3.png",0
MONSTER1_RIGHT4_PATH	byte	"./images/monster1_right4.png",0
MONSTER2_UP1_PATH	byte	"./images/monster2_up1.png",0
MONSTER2_UP2_PATH	byte	"./images/monster2_up2.png",0
MONSTER2_UP3_PATH	byte	"./images/monster2_up3.png",0
MONSTER2_UP4_PATH	byte	"./images/monster2_up4.png",0
MONSTER2_DOWN1_PATH	byte	"./images/monster2_down1.png",0
MONSTER2_DOWN2_PATH	byte	"./images/monster2_down2.png",0
MONSTER2_DOWN3_PATH	byte	"./images/monster2_down3.png",0
MONSTER2_DOWN4_PATH	byte	"./images/monster2_down4.png",0
MONSTER2_LEFT1_PATH	byte	"./images/monster2_left1.png",0
MONSTER2_LEFT2_PATH	byte	"./images/monster2_left2.png",0
MONSTER2_LEFT3_PATH	byte	"./images/monster2_left3.png",0
MONSTER2_LEFT4_PATH	byte	"./images/monster2_left4.png",0
MONSTER2_RIGHT1_PATH	byte	"./images/monster2_right1.png",0
MONSTER2_RIGHT2_PATH	byte	"./images/monster2_right2.png",0
MONSTER2_RIGHT3_PATH	byte	"./images/monster2_right3.png",0
MONSTER2_RIGHT4_PATH	byte	"./images/monster2_right4.png",0
MONSTER3_UP1_PATH	byte	"./images/monster3_up1.png",0
MONSTER3_UP2_PATH	byte	"./images/monster3_up2.png",0
MONSTER3_UP3_PATH	byte	"./images/monster3_up3.png",0
MONSTER3_UP4_PATH	byte	"./images/monster3_up4.png",0
MONSTER3_DOWN1_PATH	byte	"./images/monster3_down1.png",0
MONSTER3_DOWN2_PATH	byte	"./images/monster3_down2.png",0
MONSTER3_DOWN3_PATH	byte	"./images/monster3_down3.png",0
MONSTER3_DOWN4_PATH	byte	"./images/monster3_down4.png",0
MONSTER3_LEFT1_PATH	byte	"./images/monster3_left1.png",0
MONSTER3_LEFT2_PATH	byte	"./images/monster3_left2.png",0
MONSTER3_LEFT3_PATH	byte	"./images/monster3_left3.png",0
MONSTER3_LEFT4_PATH	byte	"./images/monster3_left4.png",0
MONSTER3_RIGHT1_PATH	byte	"./images/monster3_right1.png",0
MONSTER3_RIGHT2_PATH	byte	"./images/monster3_right2.png",0
MONSTER3_RIGHT3_PATH	byte	"./images/monster3_right3.png",0
MONSTER3_RIGHT4_PATH	byte	"./images/monster3_right4.png",0
DRAGON1_PATH	byte	"./images/dragon1.png",0
DRAGON2_PATH	byte	"./images/dragon2.png",0
DRAGON3_PATH	byte	"./images/dragon3.png",0
DRAGON4_PATH	byte	"./images/dragon4.png",0
FIRE1_PATH	byte	"./images/fire1.png",0
FIRE2_PATH	byte	"./images/fire2.png",0
FIRE3_PATH	byte	"./images/fire3.png",0
FIRE4_PATH	byte	"./images/fire4.png",0
BLUE_FIRE1_PATH	byte	"./images/blue_fire1.png",0
BLUE_FIRE2_PATH	byte	"./images/blue_fire2.png",0
BLUE_FIRE3_PATH	byte	"./images/blue_fire3.png",0
BLUE_FIRE4_PATH	byte	"./images/blue_fire4.png",0
BOMB1_PATH	byte	"./images/bomb1.png",0
BOMB2_PATH	byte	"./images/bomb2.png",0
WALL_PATH	byte	"./images/wall.bmp",0
BOX_PATH	byte	"./images/box.bmp",0
LIFE_TOOL_PATH	byte	"./images/life_tool.png",0
BOMB_RANGE_TOOL_PATH	byte	"./images/bomb_range_tool.png",0
BOMB_CNT_TOOL_PATH	byte	"./images/bomb_cnt_tool.png",0
TIME_TOOL_PATH	byte	"./images/time_tool.png",0
SPEED_TOOL_PATH	byte	"./images/speed_tool.png",0
BG1_PATH	byte	"./images/bg1.bmp",0
BG2_PATH	byte	"./images/bg2.bmp",0
LOGO_PATH	byte	"./images/logo.png",0
HOMEPAGE_PATH	byte	"./images/start.png",0
PAUSEPAGE_PATH	byte	"./images/start.png",0
LIFE_ICON_PATH	byte	"./images/life_icon.bmp",0
SPEED_ICON_PATH	byte	"./images/speed_icon.bmp",0
CNT_ICON_PATH	byte	"./images/cnt_icon.bmp",0
RANGE_ICON_PATH	byte	"./images/range_icon.bmp",0
DENGXIAN	byte	"����",0
ARIAL_NAME	byte	"Arial",0
ONE_INT_FMT	byte	"%d",0
TIME_FMT	byte	"%d:%02d",0
align	4
IMG_PATHS	dword	offset PLAYER1_UP1_PATH,offset PLAYER1_UP2_PATH,offset PLAYER1_UP3_PATH,offset PLAYER1_UP4_PATH,
					offset PLAYER1_DOWN1_PATH,offset PLAYER1_DOWN2_PATH,offset PLAYER1_DOWN3_PATH,offset PLAYER1_DOWN4_PATH
IMG_PATHS2	dword	offset PLAYER1_LEFT1_PATH,offset PLAYER1_LEFT2_PATH,offset PLAYER1_LEFT3_PATH,offset PLAYER1_LEFT4_PATH,
					offset PLAYER1_RIGHT1_PATH,offset PLAYER1_RIGHT2_PATH,offset PLAYER1_RIGHT3_PATH,offset PLAYER1_RIGHT4_PATH
IMG_PATHS3	dword	offset MONSTER1_UP1_PATH,offset MONSTER1_UP2_PATH,offset MONSTER1_UP3_PATH,offset MONSTER1_UP4_PATH,
					offset MONSTER1_DOWN1_PATH,offset MONSTER1_DOWN2_PATH,offset MONSTER1_DOWN3_PATH,offset MONSTER1_DOWN4_PATH
IMG_PATHS4	dword	offset MONSTER1_LEFT1_PATH,offset MONSTER1_LEFT2_PATH,offset MONSTER1_LEFT3_PATH,offset MONSTER1_LEFT4_PATH,
					offset MONSTER1_RIGHT1_PATH,offset MONSTER1_RIGHT2_PATH,offset MONSTER1_RIGHT3_PATH,offset MONSTER1_RIGHT4_PATH
IMG_PATHS5	dword	offset MONSTER2_UP1_PATH,offset MONSTER2_UP2_PATH,offset MONSTER2_UP3_PATH,offset MONSTER2_UP4_PATH,
					offset MONSTER2_DOWN1_PATH,offset MONSTER2_DOWN2_PATH,offset MONSTER2_DOWN3_PATH,offset MONSTER2_DOWN4_PATH
IMG_PATHS6	dword	offset MONSTER2_LEFT1_PATH,offset MONSTER2_LEFT2_PATH,offset MONSTER2_LEFT3_PATH,offset MONSTER2_LEFT4_PATH,
					offset MONSTER2_RIGHT1_PATH,offset MONSTER2_RIGHT2_PATH,offset MONSTER2_RIGHT3_PATH,offset MONSTER2_RIGHT4_PATH
IMG_PATHS7	dword	offset MONSTER3_UP1_PATH,offset MONSTER3_UP2_PATH,offset MONSTER3_UP3_PATH,offset MONSTER3_UP4_PATH,
					offset MONSTER3_DOWN1_PATH,offset MONSTER3_DOWN2_PATH,offset MONSTER3_DOWN3_PATH,offset MONSTER3_DOWN4_PATH
IMG_PATHS8	dword	offset MONSTER3_LEFT1_PATH,offset MONSTER3_LEFT2_PATH,offset MONSTER3_LEFT3_PATH,offset MONSTER3_LEFT4_PATH,
					offset MONSTER3_RIGHT1_PATH,offset MONSTER3_RIGHT2_PATH,offset MONSTER3_RIGHT3_PATH,offset MONSTER3_RIGHT4_PATH
IMG_PATHS9	dword	offset DRAGON1_PATH,offset DRAGON2_PATH,offset DRAGON3_PATH,offset DRAGON4_PATH,
					offset FIRE1_PATH,offset FIRE2_PATH,offset FIRE3_PATH,offset FIRE4_PATH
IMG_PATHS10	dword	offset BLUE_FIRE1_PATH,offset BLUE_FIRE2_PATH,offset BLUE_FIRE3_PATH,offset BLUE_FIRE4_PATH,
					offset BOMB1_PATH,offset BOMB2_PATH
IMG_PATHS11	dword	offset LIFE_TOOL_PATH,offset BOMB_RANGE_TOOL_PATH,offset BOMB_CNT_TOOL_PATH,offset SPEED_TOOL_PATH,offset TIME_TOOL_PATH,
					offset offset LOGO_PATH,offset HOMEPAGE_PATH,offset PAUSEPAGE_PATH
DRAW_MAP_JMP_TBL	dword	offset drawEmpty_drawMap,offset drawWall_drawMap,offset drawPlayer_drawMap,offset drawBomb_drawMap,offset drawMonster_drawMap,
							offset drawBox_drawMap,offset drawTool_drawMap,offset drawFire_drawMap,offset drawBoss_drawMap,offset drawBlueFire_drawMap,offset drawAttack_drawMap,
							offset drawBossFly_drawMap
STATUS_RECT	RECT	<0,0,WINDOW_WIDTH,60>


.code
;����ָ����StrFont��StrDisp����Ļ�ϻ���UTF-16�ַ��������������⣬���ڱ�������ޱ����ַ���ʱ����
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

;����ָ����StrFont��StrDisp����Ļ�ϻ���GBϵ�е��ַ��������������⣬���ڱ�������ޱ����ַ���ʱ����
drawGbString	proc	graphicsPtr:dword,strToShow:ptr byte,strFontPtr:ptr StrFont,strDispPtr:ptr StrDisp
	local	str1[512]:word
	invoke	MultiByteToWideChar,CP_ACP,NULL,strToShow,-1,addr str1,sizeof str1
	invoke	drawUtf16String,graphicsPtr,addr str1,strFontPtr,strDispPtr
	ret
drawGbString	endp

;����Ļ�������Σ����������⣬���ڱ������͸������ʱ����
drawSolidRect	proc	graphicsPtr:dword,color:dword,x:dword,y:dword,_width:dword,height:dword
	local	brushPtr:dword
	invoke	GdipCreateSolidFill,color,addr brushPtr
	invoke	GdipFillRectangleI,graphicsPtr,brushPtr,x,y,_width,height
	invoke	GdipDeleteBrush,brushPtr
	ret
drawSolidRect	endp

;GdipDrawImageRectI��drawImage����*����*���������⣬���ڱ��������͸��ͨ����pngʱ����
;������ͨͼ����ʹ��GDI��BilBlt��

;��ʼ��bmp
initBmp	proc	path:ptr byte,info:ptr BitmapInfo
	local	bmpInfo:BITMAP
	push	ebx
	invoke	LoadImage,NULL,path,IMAGE_BITMAP,0,0,LR_LOADFROMFILE
	mov	ebx,info
	mov	[ebx].BitmapInfo.hBitmap,eax
	invoke	GetObject,[ebx].BitmapInfo.hBitmap,sizeof(BITMAP),addr bmpInfo
	mov	eax,bmpInfo.bmWidth
	mov	[ebx].BitmapInfo._width,eax
	mov	eax,bmpInfo.bmHeight
	mov	[ebx].BitmapInfo.height,eax
	invoke	CreateCompatibleDC,NULL
	mov	[ebx].BitmapInfo.hdcMem,eax
	invoke	SelectObject,eax,[ebx].BitmapInfo.hBitmap
	pop	ebx
	ret
initBmp	endp

;ɾ��bmp
deleteBmp	proc	info:ptr BitmapInfo
	push	ebx
	mov	ebx,info
	invoke	DeleteDC,[ebx].BitmapInfo.hdcMem
	invoke	DeleteObject,[ebx].BitmapInfo.hBitmap
	pop	ebx
	ret
deleteBmp	endp

;����ͼƬ��Դ����ʼ��UTF-16�ַ�����
initResources	proc
	local	utf16Str[512]:word
	push	ebx
	xor	ebx,ebx
loop_initResources:
	cmp	ebx,IMG_CNT
	je	exitLoop_initResources
	invoke	MultiByteToWideChar,CP_ACP,NULL,[IMG_PATHS+ebx*4],-1,addr utf16Str,sizeof utf16Str
	lea	eax,[bitmapPtrs+ebx*4]
	invoke	GdipLoadImageFromFile,addr utf16Str,eax
	inc	ebx
	jmp	loop_initResources
exitLoop_initResources:
	lea	eax,DENGXIAN_FONT.fontName
	invoke	MultiByteToWideChar,CP_ACP,NULL,offset DENGXIAN,-1,eax,2*FONT_NAME_LEN
	invoke	initBmp,offset WALL_PATH,offset wallInfo
	invoke	initBmp,offset BOX_PATH,offset boxInfo
	invoke	initBmp,offset BG1_PATH,offset bg1Info
	invoke	initBmp,offset BG2_PATH,offset bg2Info
	invoke	initBmp,offset LIFE_ICON_PATH,offset lifeIconInfo
	invoke	initBmp,offset SPEED_ICON_PATH,offset speedIconInfo
	invoke	initBmp,offset CNT_ICON_PATH,offset cntIconInfo
	invoke	initBmp,offset RANGE_ICON_PATH,offset rangeIconInfo
	invoke	CreateFont,30,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,offset ARIAL_NAME
	mov	hFont1,eax
	;invoke	CreateSolidBrush,0ffff00h
	;mov	redBrush,eax
	pop	ebx
	ret
initResources	endp

;����ͼƬ��Դ
releaseResources	proc
	push	ebx
	xor	ebx,ebx
loop_releaseResources:
	cmp	ebx,IMG_CNT
	je	exitLoop_releaseResources
	invoke	GdipFree,[bitmapPtrs+ebx*4]
	inc	ebx
	jmp	loop_releaseResources
exitLoop_releaseResources:
	invoke	deleteBmp,offset wallInfo
	invoke	deleteBmp,offset boxInfo
	invoke	deleteBmp,offset bg1Info
	invoke	deleteBmp,offset bg2Info
	invoke	deleteBmp,offset lifeIconInfo
	invoke	deleteBmp,offset speedIconInfo
	invoke	deleteBmp,offset cntIconInfo
	invoke	deleteBmp,offset rangeIconInfo
	invoke	DeleteObject,hFont1
	;invoke	DeleteObject,redBrush
	pop	ebx
	ret
releaseResources	endp

calcDrawPos	proc	xPos:dword,yPos:dword,frac_x:dword,frac_y:dword,drawXPos:ptr dword,drawYPos:ptr dword
	;ÿһ������t�����أ�ÿ������С���귶Χ��-k��k����ǰС������n���з������㣬n*t/k������ƫ����
	mov	edx,ELEMENT_WIDTH
	mov	eax,frac_x
	imul	edx
	mov	ecx,FRAC_RANGE
	idiv	ecx
	sar	eax,1
	mov	edx,xPos
	add	edx,eax
	mov	eax,drawXPos
	mov	[eax],edx
	mov	edx,DRAW_Y_STEP
	mov	eax,frac_y
	imul	edx
	mov	ecx,FRAC_RANGE
	idiv	ecx
	sar	eax,1
	mov	edx,yPos
	add	edx,eax
	mov	eax,drawYPos
	mov	[eax],edx
	ret
calcDrawPos	endp

drawMap	proc	graphicsPtr:dword,hdcBuffer:HDC
	;ebx����ͼƫ������esi:xPos��edi:yPos
	local	layer:dword,id:dword,drawXPos:dword,drawYPos:dword,monsterSpeed:dword
	local	bossFlyXPos:dword,bossFlyYPos:dword,bossFlyWidth:dword,bossFlyHeight:dword
	local	tempStr[13]:byte
	push	ebx
	push	esi
	push	edi
	mov	bossFlyXPos,-1
	cmp	game.level,4
	je	drawBossBG_drawMap
	invoke	BitBlt,hdcBuffer,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,bg1Info.hdcMem,0,0,SRCCOPY	;����
	jmp	endDrawBG_drawMap
drawBossBG_drawMap:
	invoke	BitBlt,hdcBuffer,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,bg2Info.hdcMem,0,0,SRCCOPY	;����
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
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,wallInfo.hdcMem,0,0,SRCCOPY	;����
	jmp	exitSwitch_drawMap
drawPlayer_drawMap	label	dword
	mov	eax,game.player.timer
	shr	eax,3	;��Ƶ����
	and	eax,1
	jnz	exitSwitch_drawMap	;�޵�״̬�����˸
	mov	eax,game.player.direction
	shl	eax,2	;eax=eax*4(4 imgs pre direction)
	cmp	game.player.isMove,STILL
	je	playerNotMove_drawMap
	mov	edx,game.timer
	shr	edx,3	;��Ƶ����
	and	edx,3
	add	eax,edx
playerNotMove_drawMap:
	push	eax
	invoke	calcDrawPos,esi,edi,game.player.frac_y,game.player.frac_x,addr drawXPos,addr drawYPos
	pop	eax
	invoke	drawImage,graphicsPtr,bitmapPtrs[PLY1_UP_IMG*4+eax*4],drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawBomb_drawMap	label	dword
	mov	eax,id
	mov	edx,sizeof Bomb
	mul	edx
	mov	eax,game.bombs[eax].timer
	shr	eax,4	;��Ƶ����
	and	eax,1
	invoke	drawImage,graphicsPtr,bitmapPtrs[BOMB_IMG*4+eax*4],esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawMonster_drawMap	label	dword
	mov	eax,id
	mov	edx,sizeof Monster
	mul	edx
	mov	edx,game.monsters[eax].speed
	mov	monsterSpeed,edx
	mov	edx,game.monsters[eax].direction
	shl	edx,2	;edx=edx*4(4 imgs pre direction)
	push	edx
	lea	edx,drawYPos
	push	edx
	lea	edx,drawXPos
	push	edx
	push	game.monsters[eax].frac_x
	push	game.monsters[eax].frac_y
	push	edi
	push	esi
	call	calcDrawPos	;ΪʲôҪ�ֶ�call�أ���Ϊ���ɵ��masm��addr�����Ĭ����eax��lea����eax��ֵ����û��
	pop	edx
	mov	eax,game.timer
	shr	eax,3
	and	eax,3
	add	edx,eax
	cmp	monsterSpeed,MONSTER_1_SPEED
	je	drawMonster1_drawMap
	cmp	monsterSpeed,MONSTER_2_SPEED
	je	drawMonster2_drawMap
	invoke	drawImage,graphicsPtr,bitmapPtrs[MON3_UP_IMG*4+edx*4],drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawMonster1_drawMap:
	invoke	drawImage,graphicsPtr,bitmapPtrs[MON1_UP_IMG*4+edx*4],drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawMonster2_drawMap:
	invoke	drawImage,graphicsPtr,bitmapPtrs[MON2_UP_IMG*4+edx*4],drawXPos,drawYPos,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawBox_drawMap	label	dword
	invoke	BitBlt,hdcBuffer,esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT,boxInfo.hdcMem,0,0,SRCCOPY	;����
	jmp	exitSwitch_drawMap
drawTool_drawMap	label	dword
	mov	eax,id
	mov	edx,sizeof Tool
	mul	edx
	mov	eax,game.tools[eax]._type
	invoke	drawImage,graphicsPtr,bitmapPtrs[TOOL_IMG*4+eax*4],esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawFire_drawMap	label	dword
	;��0��ͼ�ǻ�����ʧ����3��ͼ�ǻ���ճ���
	mov	eax,id
	mov	edx,sizeof Bomb
	mul	edx
	mov	eax,game.bombs[eax].timer
	shr	eax,2	;��Ƶ����
	and	eax,3
	invoke	drawImage,graphicsPtr,bitmapPtrs[FIRE_IMG*4+eax*4],esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawBoss_drawMap	label	dword
	mov	eax,game.timer
	shr	eax,3
	and	eax,3
	mov	drawXPos,esi
	sub	drawXPos,37
	mov	drawYPos,edi
	sub	drawYPos,60
	invoke	drawImage,graphicsPtr,bitmapPtrs[DRA_IMG*4+eax*4],drawXPos,drawYPos,135,180
	jmp	exitSwitch_drawMap
drawBlueFire_drawMap	label	dword
	;��0��ͼ�ǻ�����ʧ����3��ͼ�ǻ���ճ���
	mov	eax,id
	mov	edx,sizeof Attack
	mul	edx
	mov	eax,game.attacks[eax].timer
	shr	eax,2	;��Ƶ����
	and	eax,3
	invoke	drawImage,graphicsPtr,bitmapPtrs[BFIRE_IMG*4+eax*4],esi,edi,ELEMENT_WIDTH,ELEMENT_HEIGHT
	jmp	exitSwitch_drawMap
drawAttack_drawMap	label	dword
	invoke	drawSolidRect,graphicsPtr,80ff0000h,esi,edi,ELEMENT_WIDTH,DRAW_Y_STEP
	jmp	exitSwitch_drawMap
drawBossFly_drawMap	label	dword
	cmp	game.boss.sky_time,TAKE_OFF_TIME
	jle	testShowLanding_drawMap
	mov	eax,SKY_TIME
	sub	eax,game.boss.sky_time
	cmp	eax,15
	jg	showBossLeave_drawMap
	lea	edx,[eax+eax*2+135]
	mov	bossFlyWidth,edx
	lea	edx,[eax*4+180]
	mov	bossFlyHeight,edx
	lea	edx,[eax*8]
	neg	edx
	lea	edx,[edi+edx-60]
	mov	bossFlyYPos,edx
	lea	edx,[eax+eax*2+75]
	sar	edx,1
	neg	edx
	lea	edx,[esi+edx]
	mov	bossFlyXPos,edx
	jmp	exitSwitch_drawMap
showBossLeave_drawMap:
	shl	eax,4
	lea	edx,[edi+eax-420]
	mov	bossFlyYPos,edx
	mov	bossFlyXPos,esi
	sub	bossFlyXPos,60
	mov	bossFlyWidth,180
	mov	bossFlyHeight,240
	jmp	exitSwitch_drawMap
testShowLanding_drawMap:
	cmp	game.boss.pre_drop_time,0
	jle	exitSwitch_drawMap
	mov	eax,game.boss.pre_drop_time
	cmp	eax,15
	jl	showBossLand_drawMap
	shl	eax,4
	neg	eax
	lea	edx,[edi+eax+60]
	mov	bossFlyYPos,edx
	mov	bossFlyXPos,esi
	sub	bossFlyXPos,60
	mov	bossFlyWidth,180
	mov	bossFlyHeight,240
	jmp	exitSwitch_drawMap
showBossLand_drawMap:
	lea	edx,[eax+eax*2+135]
	mov	bossFlyWidth,edx
	lea	edx,[eax*4+180]
	mov	bossFlyHeight,edx
	lea	edx,[eax*8]
	neg	edx
	lea	edx,[edi+edx-60]
	mov	bossFlyYPos,edx
	lea	edx,[eax+eax*2+75]
	sar	edx,1
	neg	edx
	lea	edx,[esi+edx]
	mov	bossFlyXPos,edx
drawEmpty_drawMap	label	dword
exitSwitch_drawMap:
	inc	ebx
	inc	layer
	cmp	layer,3
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
	cmp	bossFlyXPos,0
	jl	skipDrawBossFly_drawMap
	mov	eax,game.timer
	shr	eax,3
	and	eax,3
	invoke	drawImage,graphicsPtr,bitmapPtrs[DRA_IMG*4+eax*4],bossFlyXPos,bossFlyYPos,bossFlyWidth,bossFlyHeight
skipDrawBossFly_drawMap:
	invoke	FillRect,hdcBuffer,offset STATUS_RECT,COLOR_WINDOW+1
	invoke	BitBlt,hdcBuffer,100,10,40,40,lifeIconInfo.hdcMem,0,0,SRCCOPY
	invoke	BitBlt,hdcBuffer,300,10,40,40,speedIconInfo.hdcMem,0,0,SRCCOPY
	invoke	BitBlt,hdcBuffer,600,10,40,40,cntIconInfo.hdcMem,0,0,SRCCOPY
	invoke	BitBlt,hdcBuffer,800,10,40,40,rangeIconInfo.hdcMem,0,0,SRCCOPY
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
	div	ecx	;eax������
	cmp	eax,30
	jg	notSetRed_drawMap
	push	eax
	invoke	SetTextColor,hdcBuffer,00000ffh
	pop	eax
notSetRed_drawMap:
	xor	edx,edx
	mov	ecx,60	;1min=60s
	div	ecx	;eax�Ƿ֣�edx����
	invoke	crt_sprintf,addr tempStr,offset TIME_FMT,eax,edx
	invoke	crt_strlen,addr tempStr
	invoke	TextOut,hdcBuffer,465,20,addr tempStr,eax
	pop	edi
	pop	esi
	pop	ebx
	ret
drawMap	endp

drawLogo	proc	graphicsPtr:dword
	cmp	mainwinp.frames,15
	jle	appear_drawLogo
	cmp	mainwinp.frames,15+25
	jle	hold_drawLogo
	cmp	mainwinp.frames,15+25+15
	jle	disappear_drawLogo
	mov mainwinp.winState, winState_startPage	
	mov	eax,1
	ret
appear_drawLogo:
	invoke	drawSolidRect,graphicsPtr,0ff000000h,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	drawImage,graphicsPtr,bitmapPtrs[LOGO_IMG*4],LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	mov	edx,mainwinp.frames
	shl	edx,4
	mov	eax,255
	sub	eax,edx
	shl	eax,24
	invoke	drawSolidRect,graphicsPtr,eax,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	jmp	exit_drawLogo
hold_drawLogo:
	invoke	drawSolidRect,graphicsPtr,0ff000000h,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	drawImage,graphicsPtr,bitmapPtrs[LOGO_IMG*4],LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	jmp	exit_drawLogo
disappear_drawLogo:
	invoke	drawSolidRect,graphicsPtr,0ff000000h,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	drawImage,graphicsPtr,bitmapPtrs[LOGO_IMG*4],LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
	mov	edx,mainwinp.frames
	sub	edx,15+25
	shl	edx,4+24
	invoke	drawSolidRect,graphicsPtr,edx,LOGO_X_POS,LOGO_Y_POS,LOGO_WIDTH,LOGO_HEIGHT
exit_drawLogo:
	xor	eax,eax
	ret
drawLogo	endp

drawStory	proc	graphicsPtr:dword
	local strDispPtr:StrDisp, strFontPtr:StrFont
	cmp mainwinp.frames,0
	jl	movePrint_drawStory
	;׼������Ϸ
	invoke  crt_time,NULL
	invoke  crt_srand,eax	;����Ϸǰ����
	invoke  initGame
	mov mainwinp.winState, winState_onGame	
	jmp ret_drawStory
movePrint_drawStory:
	mov eax, WINDOW_HEIGHT
	sub eax, mainwinp.frames	;eax = WINDOW_HEIGHT - frames
	mov ecx, WINDOW_WIDTH
 	sar ecx, 1	;ecx = WINDOW_WIDTH/2
	mov strDispPtr.x, ecx
	mov strDispPtr.y, eax
	mov strDispPtr._width, 600
	mov strDispPtr.height, 600
	mov strDispPtr.hAlign, StringAlignmentCenter
	mov strDispPtr.vAlign, StringAlignmentNear
	invoke crt_strcpy, addr strFontPtr.fontName, offset DENGXIAN, FONT_NAME_LEN
	mov strFontPtr.fontSize, 14
	mov strFontPtr.color, 0FFFFFFFFH
	mov strFontPtr.style, FontStyleRegular
	invoke drawGbString, graphicsPtr, offset storyUtf16Str, addr strFontPtr, addr strDispPtr
ret_drawStory:
	ret
drawStory	endp

drawWindow	proc	graphicsPtr:dword,hdcBuffer:HDC
	;���Ǹ���ת��
	cmp mainwinp.winState, winState_logoPage
	je logoPage_drawWindow
	cmp mainwinp.winState, winState_startPage
	je startPage_drawWindow
	cmp mainwinp.winState, winState_onStory
	je onStory_drawWindow
	cmp mainwinp.winState, winState_onGame
	je onGame_drawWindow
	cmp mainwinp.winState, winState_pauseGame
	je pauseGame_drawWindow
	jmp ret_drawWindow
logoPage_drawWindow:
	invoke	drawLogo, graphicsPtr
	jmp ret_drawWindow
startPage_drawWindow:
	invoke	drawImage,graphicsPtr,bitmapPtrs[HOMEPAGE_IMG*4],0,0,WINDOW_WIDTH,WINDOW_WIDTH
	jmp ret_drawWindow
onStory_drawWindow:
	invoke	drawStory, graphicsPtr
	jmp ret_drawWindow
onGame_drawWindow:
	invoke	drawMap, graphicsPtr,hdcBuffer
	jmp ret_drawWindow
pauseGame_drawWindow:
	invoke	drawImage,graphicsPtr,bitmapPtrs[PAUSEPAGE_IMG*4],0,0,WINDOW_WIDTH,WINDOW_WIDTH
	jmp ret_drawWindow
ret_drawWindow:
	ret
drawWindow	endp

end