.386
.model	flat,stdcall
option	casemap:none

include	common.inc
public  mainwinp
public	hdcBuffer
public	dancemode_si
public	dancemode_pi
extrn	LOGO_PATH:byte

.data?
mainwinp	MainWinp	<>
dancemode_si STARTUPINFO <>
dancemode_pi PROCESS_INFORMATION <>
hdcBuffer	dword	?
hMemBitmap	dword	?

.const 
CLASS_NAME	byte	"MainWindow",0	;窗口类名
WINDOW_NAME	byte	"BIT BOMBERMAN",0	;窗口显示名
MSGBOX_ERROR_TITLE	byte	"错误",0
MSGBOX_MSG_TITLE	byte	"消息",0
MSGBOX_ABOUT_TITLE	byte	"关于",0
MSGBOX_ABOUT_TEXT	byte	"你说得对，但是《北理炸弹侠》是由二十二小组自主研发的一款全新开放世界冒险游戏。游戏发生在一个被称作“北理工”的幻想世界，在这里，被张华平选中的人将被授予“MASM”，导引IA-32之力。"
MSGBOX_ABOUT_TEXT1	byte	"你将扮演一位名为“炸弹侠”的神秘角色，在自由的旅行中使用汇编炸弹击败强敌，拯救北理工——同时，逐步发掘“恶龙”的真相。",0
MSGBOX_NO_ADMIN_TEXT	byte	"请以管理员身份运行！",0
MSGBOX_WINDOW_FAIL_TEXT	byte	"窗口创建失败！",0
MSGBOX_SAVESUCC_TEXT	byte	"游戏进度保存成功",0
MSGBOX_SAVEFAIL_TEXT	byte	"无法保存游戏进度！",0
MSGBOX_NO_SAVE_TEXT	byte	"找不到存档文件！",0
align	4
LBUTTON_JMP_TBL	dword	offset nop_onLButtonUp,offset start_onLButtonUp,offset story1_onLButtonUp,offset story2_onLButtonUp,offset tutorial_onLButtonUp,offset nop_onLButtonUp,
						offset pause_onLButtonUp,offset question_onLButtonUp,offset answer_onLButtonUp,offset nop_onLButtonUp,offset nop_onLButtonUp,offset nop_onLButtonUp
MAINLOOP_JMP_TBL	dword	offset logo_mainLoop,offset nop_mainLoop,offset story1_mainLoop,offset story2_mainLoop,offset nop_mainLoop,offset game_mainLoop,
							offset nop_mainLoop,offset nop_mainLoop,offset nop_mainLoop,offset gameOver_mainLoop,offset killBoss_mainLoop,offset gameWin_mainLoop
.code
onLButtonUp	proc	lParam:LPARAM
	local	mousex:sdword,mousey:sdword
	mov	eax,mainwinp.currentState
	cmp	eax,mainwinp.intentState
	je	continue_onLButtonUp
	ret
continue_onLButtonUp:
	movsx	edx,word ptr lParam
	mov	mousex,edx
	movsx	edx,word ptr [lParam+2]
	mov	mousey,edx	;移位算出鼠标相对坐标
	jmp	[LBUTTON_JMP_TBL+eax*4]
nop_onLButtonUp	label	near
	ret
start_onLButtonUp	label	near
	invoke isMouseInButton, mousex, mousey, BUTT_STARTNEW_X,BUTT_STARTNEW_Y,BUTT_STARTNEW_W,BUTT_STARTNEW_H
	test	eax,eax
	jnz clickStartNew_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CONTINUESAVE_X,BUTT_CONTINUESAVE_Y,BUTT_CONTINUESAVE_W,BUTT_CONTINUESAVE_H
	test	eax,eax
	jnz clickContinuesave_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_ABOUTME_X,BUTT_ABOUTME_Y,BUTT_ABOUTME_W,BUTT_ABOUTME_H
	test eax, eax
	jnz clickAboutme_onLButtonUp
	ret
clickStartNew_onLButtonUp:
	mov	mainwinp.transitionFunc,jobToStory
	mov	mainwinp.shouldFade,TRUE
	mov	mainwinp.intentState,STORY1_STATE
	ret
clickContinuesave_onLButtonUp:
	invoke	load
	test	eax,eax
	jnz	errLoad_onLButtonUp
	mov	mainwinp.transitionFunc,jobHomeToGame
	mov	mainwinp.shouldFade,TRUE
	mov	mainwinp.intentState,GAME_STATE
	ret
errLoad_onLButtonUp:
	invoke	MessageBox,NULL,offset MSGBOX_NO_SAVE_TEXT,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	ret
clickAboutme_onLButtonUp:
	invoke	MessageBox,NULL,offset MSGBOX_ABOUT_TEXT,offset MSGBOX_ABOUT_TITLE,MB_OK
	ret
story1_onLButtonUp	label	near
	mov	mainwinp.transitionFunc,jobResetTimer
	mov	mainwinp.shouldFade,TRUE
	mov	mainwinp.intentState,STORY2_STATE
	ret
story2_onLButtonUp	label	near
	mov	mainwinp.transitionFunc,NULL
	mov	mainwinp.shouldFade,TRUE
	mov	mainwinp.intentState,TUTORIAL_STATE
	ret
tutorial_onLButtonUp	label	near
	mov	mainwinp.transitionFunc,jobTutorialToGame
	mov	mainwinp.shouldFade,TRUE
	mov	mainwinp.intentState,GAME_STATE
	invoke	initGame
	ret
pause_onLButtonUp	label	near
	invoke isMouseInButton, mousex, mousey, BUTT_SAVE_X,BUTT_SAVE_Y,BUTT_SAVE_W,BUTT_SAVE_H
	test	eax,eax
	jnz clickSave_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CONTINUE_X,BUTT_CONTINUE_Y,BUTT_CONTINUE_W,BUTT_CONTINUE_H
	test	eax,eax
	jnz	clickContinue_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_DANCEMODE_X,BUTT_DANCEMODE_Y,BUTT_DANCEMODE_W,BUTT_DANCEMODE_H
	test	eax,eax
	jnz clickDancemode_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_RETHOME_X,BUTT_RETHOME_Y,BUTT_RETHOME_W,BUTT_RETHOME_H
	test	eax,eax
	jnz clickRethome_onLButtonUp
	ret
clickSave_onLButtonUp:
	invoke archive
	test	eax,eax
	jnz	errSave_onLButtonUp
	invoke	MessageBox,NULL,offset MSGBOX_SAVESUCC_TEXT,offset MSGBOX_MSG_TITLE,MB_OK
	ret
errSave_onLButtonUp:
	invoke	MessageBox,NULL,offset MSGBOX_SAVEFAIL_TEXT,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	ret
clickContinue_onLButtonUp:
	mov	mainwinp.transitionFunc,NULL
	mov	mainwinp.shouldFade,FALSE
	mov	mainwinp.intentState,GAME_STATE
	ret
clickDancemode_onLButtonUp:
	invoke StartDanceMode
	ret
clickRethome_onLButtonUp:
	mov	mainwinp.transitionFunc,jobToStart
	mov	mainwinp.shouldFade,TRUE
	mov	mainwinp.intentState,START_STATE
	ret
question_onLButtonUp	label	near
	mov	mainwinp.playerAnswer,-1
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICEA_X,BUTT_CHOICEA_Y,BUTT_CHOICEA_W,BUTT_CHOICEA_H
	test	eax,eax
	jnz clickA_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICEB_X,BUTT_CHOICEB_Y,BUTT_CHOICEB_W,BUTT_CHOICEB_H
	test	eax,eax
	jnz	clickB_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICEC_X,BUTT_CHOICEC_Y,BUTT_CHOICEC_W,BUTT_CHOICEC_H
	test	eax,eax
	jnz	clickC_onLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICED_X,BUTT_CHOICED_Y,BUTT_CHOICED_W,BUTT_CHOICED_H
	test	eax,eax
	jnz clickD_onLButtonUp
	ret
clickA_onLButtonUp:
	mov	mainwinp.playerAnswer,0
	jmp	checkValid_onLButtonUp
clickB_onLButtonUp:
	mov	mainwinp.playerAnswer,1
	jmp	checkValid_onLButtonUp
clickC_onLButtonUp:
	mov	mainwinp.playerAnswer,2
	jmp	checkValid_onLButtonUp
clickD_onLButtonUp:
	mov	mainwinp.playerAnswer,3
checkValid_onLButtonUp:
	cmp	mainwinp.playerAnswer,0
	jl	exitQuestion_onLButtonUp
	mov	mainwinp.transitionFunc,jobQuestionToAnswer
	mov	mainwinp.shouldFade,FALSE
	mov	mainwinp.intentState,ANSWER_STATE
exitQuestion_onLButtonUp:
	ret
answer_onLButtonUp	label	near
	mov mainwinp.transitionFunc,jobAnswerToGame
	mov	mainwinp.shouldFade,TRUE
	mov	mainwinp.intentState,GAME_STATE
	ret
onLButtonUp	endp

mainLoop	proc	hwnd:HWND
	mov	eax,mainwinp.currentState
	cmp	eax,mainwinp.intentState
	je	continue_mainLoop
	invoke	InvalidateRect,hwnd,NULL,TRUE	;通知重绘
	ret
continue_mainLoop:
	jmp	[MAINLOOP_JMP_TBL+eax*4]
nop_mainLoop	label	near
	ret
logo_mainLoop	label	near
	invoke	checkTimerAndFade,15+30,START_STATE,jobToStart
	invoke	InvalidateRect,hwnd,NULL,TRUE	;通知重绘
	ret
story1_mainLoop	label	near
	invoke	checkTimerAndFade,180,STORY2_STATE,jobResetTimer
	ret
story2_mainLoop	label	near
	invoke	checkTimerAndFade,300,TUTORIAL_STATE,NULL
	ret
game_mainLoop	label	near
	invoke	readKeyInGame
	cmp	eax,GAMEPAUSE
	je	wantToPause_mainLoop
	invoke	gameLoop,eax
	invoke	InvalidateRect,hwnd,NULL,TRUE	;游戏每一刻都要通知重绘
	ret
wantToPause_mainLoop:
	mov	mainwinp.shouldFade,FALSE
	mov	mainwinp.transitionFunc,NULL
	mov	mainwinp.intentState,PAUSE_STATE
	ret
gameOver_mainLoop	label	near
	invoke	checkTimerAndFade,120,START_STATE,jobToStart
	ret
killBoss_mainLoop	label	near
	invoke	checkTimerAndFade,120,GAME_WIN_STATE,jobResetTimer
	ret
gameWin_mainLoop	label	near
	invoke	checkTimerAndFade,120,START_STATE,jobToStart
	ret
mainLoop	endp

WindowProc	proc	hwnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	local	ps:PAINTSTRUCT,hdc:HDC
	;这个地方没法跳转表，数很散
	cmp	uMsg,WM_TIMER
	je	WindowProcTimer
	cmp	uMsg,WM_CREATE
	je	WindowProcCreate
	cmp	uMsg,WM_DESTROY
	je	WindowProcDestroy
	cmp	uMsg,WM_PAINT
	je	WindowProcPaint
	cmp	uMsg,WM_LBUTTONUP
	je	WindowProcLButtonUp
WindowProcDefault:
	invoke	DefWindowProc,hwnd,uMsg,wParam,lParam
	ret
WindowProcTimer:
	invoke	mainLoop,hwnd		;在这里进行每一刻的游戏逻辑更新
	jmp	ExitWindowProc
WindowProcPaint:
	invoke	BeginPaint,hwnd,addr ps		;创建绘图资源
	mov	hdc,eax
	invoke	drawWindow		;在这里进行画图函数的调用
	invoke	BitBlt,hdc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,hdcBuffer,0,0,SRCCOPY	;双缓冲绘图技术防止闪烁
	invoke	EndPaint,hwnd,addr ps		;释放绘图资源
	jmp	ExitWindowProc
WindowProcCreate:
	;初始化win状态
	mov mainwinp.timer, 0
	mov mainwinp.currentState,LOGO_STATE
	mov mainwinp.intentState,LOGO_STATE
	invoke	ImmAssociateContext, hwnd, NULL	;qjh测试功能，禁用输入法
	invoke	initResources	;加载图像资源进内存
	invoke	InitDanceMode	;初始化体感模式
	;创建双缓冲绘图资源
	invoke	CreateCompatibleDC,NULL
	mov	hdcBuffer,eax
	invoke	GetDC,hwnd
	invoke	CreateCompatibleBitmap,eax,WINDOW_WIDTH,WINDOW_HEIGHT
	mov	hMemBitmap,eax
	invoke	SelectObject,hdcBuffer,eax
	invoke	SetStretchBltMode,hdcBuffer,COLORONCOLOR	;设置GDI的图片缩放模式，防止缩小后色彩错误
	invoke	SetTimer,hwnd,1,20,NULL	;暂定每20ms更新一次状态，但实测频率低于理论值
	jmp	ExitWindowProc
WindowProcDestroy:
	;释放双缓冲绘图资源
	invoke	DeleteObject,hMemBitmap
	invoke	DeleteDC,hdcBuffer
	invoke	KillTimer,hwnd,1	;停止定时器
	invoke	releaseResources	;释放图像资源
	invoke	TerminateProcess,dancemode_pi.hProcess,300
	invoke	PostQuitMessage,0
	jmp ExitWindowProc
WindowProcLButtonUp:
	invoke	onLButtonUp,lParam
ExitWindowProc:
	xor	eax,eax
	ret
WindowProc	endp

WinMain	proc	hInst:HINSTANCE,hPrevInst:HINSTANCE,cmdLine:LPSTR,cmdShow:DWORD
	local	wc:WNDCLASS,msg:MSG,errorMsg[100]:byte
	invoke	drawImage,offset LOGO_PATH,0,0
	invoke	readInfo,addr errorMsg
	test	eax,eax
	jnz	ErrorLoad
	invoke	crt_memset,addr wc,0,sizeof WNDCLASS
	mov	wc.lpfnWndProc,offset WindowProc
	mov	eax,hInst
	mov	wc.hInstance,eax
	mov	wc.lpszClassName,offset CLASS_NAME
	invoke LoadCursor, NULL, IDC_ARROW
	mov wc.hCursor, eax		;选定鼠标图标防止转圈不好看
	invoke	RegisterClass,addr wc
	invoke	CreateWindowEx,0,offset CLASS_NAME,offset WINDOW_NAME,WS_OVERLAPPEDWINDOW XOR WS_THICKFRAME XOR WS_MAXIMIZEBOX,CW_USEDEFAULT,CW_USEDEFAULT,WINDOW_WIDTH,WINDOW_HEIGHT,NULL,NULL,hInst,NULL	;hwnd in eax
	test	eax,eax
	jz	ErrorCreate
	invoke	ShowWindow,eax,cmdShow
EventLoop:
	invoke	GetMessage,addr msg,NULL,0,0
	test	eax,eax
	jz	ExitMain
	invoke	TranslateMessage,addr msg
	invoke	DispatchMessage,addr msg
	jmp	EventLoop
ErrorLoad:
	invoke	MessageBox,NULL,addr errorMsg,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	mov	eax,1
	jmp	ExitMain
ErrorCreate:
	invoke	MessageBox,NULL,offset MSGBOX_WINDOW_FAIL_TEXT,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	mov	eax,1
ExitMain:
	ret
WinMain	endp

start:
	invoke	IsUserAnAdmin
	test	eax,eax
	jz	NoAdmin
	invoke	GetModuleHandle,NULL
	mov	edx,eax
	invoke	GetCommandLine
	invoke	WinMain,edx,NULL,eax,SW_SHOWDEFAULT
	jmp	ExitProg
NoAdmin:
	invoke	MessageBox,NULL,offset MSGBOX_NO_ADMIN_TEXT,offset MSGBOX_ERROR_TITLE,MB_OK
ExitProg:
	invoke	ExitProcess,eax
end	start
