.486
.model	flat,stdcall
option	casemap:none

public  mainwinp
include	common.inc
extrn game:Game

.data
mainwinp	MainWinp	<>
mciPlayParms	MCI_PLAY_PARMS <>
mciOpenParms	MCI_OPEN_PARMS <>
Mp3DeviceID dword 0
dancemode_si STARTUPINFO <>
dancemode_pi PROCESS_INFORMATION <>
audioCmdBuf byte 256 dup(0)

.const 
BGM_HOME_PATH	byte	"./audio/HomePage.mp3",0
BGM_STORY_PATH	byte	"./audio/zhp16s.wav",0
BGM_ONGAME_PATH	byte	"./audio/onGame.mp3",0
BGM_ZHP16_PATH	byte	"./audio/zhp16s.mp3",0
PLAY_SPRINTF byte "play %s",0
PLAY_REPEAT_SPRINTF byte "play %s repeat",0
STOP_SPRINTF byte "stop %s",0
AUDIO_SPRINTF byte "setaudio %s volume to %d",0


Mp3Device   db "MPEGVideo",0
CLASS_NAME	byte	"MainWindow",0	;窗口类名
WINDOW_NAME	byte	"BIT BOMBERMAN",0	;窗口显示名
GP_INPUT	GdiplusStartupInput	<1,0,0,0>
MSGBOX_WINDOW_FAIL_TEXT	byte	"窗口创建失败！",0
MSGBOX_ERROR_TITLE	byte	"错误",0
MSGBOX_WINDOW_ABOUTME_TEXT	byte	"关于信息",0
MSGBOX_ABOUTME_TITLE	byte	"关于",0
MSGBOX_WINDOW_SAVESUCC_TEXT	byte	"游戏进度保存成功",0
MSGBOX_SAVESUCC_TITLE	byte	"消息",0
MSGBOX_WINDOW_ZHANGHP_TITLE	byte	"来自张老师的消息",0
MSGBOX_ANSCORR_TEXT	byte	"恭喜你答对了，继续吧！",0
MSGBOX_ANSERR_TEXT	byte	"答错了！你的属性将变为初值",0
DANCEMODE_PATH	db	".\\DanceMode_ext\\python.exe",0
DANCEMODE_PY_PATH	db	".\\DanceMode_ext\\python.exe .\\DanceMode_ext\\d_kep.py",0

.code

InitDanceMode proc
	invoke crt_memset,offset dancemode_si,0,SIZEOF STARTUPINFO
	invoke crt_memset,offset dancemode_pi,0,SIZEOF PROCESS_INFORMATION
	ret
InitDanceMode endp
StartDanceMode proc
	cmp dancemode_pi.hProcess,0
	jne killDance_StartDanceMode
	invoke CreateProcessA, offset DANCEMODE_PATH,offset DANCEMODE_PY_PATH, NULL, NULL,0,CREATE_NEW_CONSOLE,NULL,NULL,offset dancemode_si,offset dancemode_pi
	ret
	killDance_StartDanceMode:
	invoke	TerminateProcess,dancemode_pi.hProcess,300
	invoke	InitDanceMode
	ret
StartDanceMode endp

readKey Proc
	invoke	GetKeyState,VK_SPACE
	test	eax,8000h
	jnz	keyBomb_readKey
	invoke	GetKeyState,VK_W
	test	eax,8000h
	jnz	keyW_readKey
	invoke	GetKeyState,VK_S
	test	eax,8000h
	jnz	keyS_readKey
	invoke	GetKeyState,VK_A
	test	eax,8000h
	jnz	keyA_readKey
	invoke	GetKeyState,VK_D
	test	eax,8000h
	jnz	keyD_readKey
	invoke	GetKeyState,VK_ESCAPE
	test	eax,8000h
	jnz	keyEsc_readKey
	invoke	GetKeyState,VK_R
	test	eax,8000h
	jnz	keyR_readKey
	invoke	GetKeyState,VK_RETURN
	test	eax,8000h
	jnz	keySpace_readKey
	mov	eax,-1
	ret
keyBomb_readKey:
    mov eax,SETBOMB
	ret
keyW_readKey:
    mov eax,UP
	ret
keyS_readKey:
    mov eax,DOWN
	ret
keyA_readKey:
    mov eax,LEFT
	ret
keyD_readKey:
    mov eax,RIGHT
	ret
keyEsc_readKey:
    mov eax,GAMEPAUSE
	ret
keyR_readKey:
    mov eax,GAMESTART
	ret
keySpace_readKey:
    mov eax,SPACEJO
	ret
readKey endp

readMutiKey Proc
	mov ecx,0
	invoke	GetKeyState,VK_B
	test	eax,8000h
	jz	keyB_readMutiKey
		or ecx,SETBOMB
	keyB_readMutiKey:
	invoke	GetKeyState,VK_W
	test	eax,8000h
	jz	keyW_readMutiKey
		or ecx,UP
	keyW_readMutiKey:
	invoke	GetKeyState,VK_S
	test	eax,8000h
	jz	keyS_readMutiKey
		or ecx,DOWN
	keyS_readMutiKey:
	invoke	GetKeyState,VK_A
	test	eax,8000h
	jz	keyA_readMutiKey
		or ecx,LEFT
	keyA_readMutiKey:
	invoke	GetKeyState,VK_D
	test	eax,8000h
	jz	keyD_readMutiKey
		or ecx,RIGHT
	keyD_readMutiKey:
	invoke	GetKeyState,VK_ESCAPE
	test	eax,8000h
	jz	keyEsc_readMutiKey
		or ecx,GAMEPAUSE
	keyEsc_readMutiKey:
	invoke	GetKeyState,VK_R
	test	eax,8000h
	jz	keyR_readMutiKey
		or ecx,GAMESTART
	keyR_readMutiKey:
	invoke	GetKeyState,VK_SPACE
	test	eax,8000h
	jz	keySpace_readMutiKey
		or ecx,SPACEJO
	keySpace_readMutiKey:
	mov eax,ecx
	ret
readMutiKey endp

OnLButtonUp proc wParam:WPARAM, lParam:LPARAM, hwnd:HWND
	local mousex:sword, mousey:sword, questionChoice:dword
	mov eax, lParam
	mov mousex, ax
	shr eax, 16
	mov mousey, ax	;移位算出鼠标相对坐标
	cmp mainwinp.winState, winState_logoPage
	je logoPage_OnLButtonUp
	cmp mainwinp.winState, winState_startPage
	je startPage_OnLButtonUp
	cmp mainwinp.winState, winState_onStory
	je onStory_OnLButtonUp
	cmp mainwinp.winState, winState_onGame
	je onGame_OnLButtonUp
	cmp mainwinp.winState, winState_pauseGame
	je pauseGame_OnLButtonUp
	cmp mainwinp.winState, winState_levelup
	je levelup_OnLButtonUp
	jmp ret_OnLButtonUp
logoPage_OnLButtonUp:
	
	jmp ret_OnLButtonUp
startPage_OnLButtonUp:
	invoke isMouseInButton, mousex, mousey, BUTT_STARTNEW_X,BUTT_STARTNEW_Y,BUTT_STARTNEW_W,BUTT_STARTNEW_H
	cmp eax, 1	;在此按钮区域
	je clickStartNew_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CONTINUESAVE_X,BUTT_CONTINUESAVE_Y,BUTT_CONTINUESAVE_W,BUTT_CONTINUESAVE_H
	cmp eax, 1	;在此按钮区域
	je clickContinuesave_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_ABOUTME_X,BUTT_ABOUTME_Y,BUTT_ABOUTME_W,BUTT_ABOUTME_H
	cmp eax, 1	;在此按钮区域
	je clickAboutme_OnLButtonUp
	
	jmp ret_OnLButtonUp	;不在任何按钮范围
	clickStartNew_OnLButtonUp:
		invoke crt_sprintf ,offset audioCmdBuf, offset STOP_SPRINTF,offset BGM_HOME_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL	;stop bgm
		invoke crt_sprintf ,offset audioCmdBuf, offset PLAY_SPRINTF,offset BGM_ZHP16_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL	;播放故事bgm
		mov mainwinp.frames, 0
		mov mainwinp.nowStoryNum,1
		mov mainwinp.winState, winState_onStory	;点全新游戏了，到下一状态
		jmp ret_OnLButtonUp
	clickContinuesave_OnLButtonUp:
		invoke crt_sprintf ,offset audioCmdBuf, offset STOP_SPRINTF,offset BGM_HOME_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL	;stop bgm
		invoke crt_sprintf ,offset audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_ONGAME_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL	;播放故事bgm
		invoke crt_sprintf ,offset audioCmdBuf, offset AUDIO_SPRINTF,offset BGM_ONGAME_PATH,400
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
		invoke load
		invoke  crt_time,NULL
		invoke  crt_srand,eax	;进游戏前播种
		mov mainwinp.winState, winState_onGame	;点继续游戏了，到下一状态
		jmp ret_OnLButtonUp
	clickAboutme_OnLButtonUp:
		invoke	MessageBox,NULL,offset MSGBOX_WINDOW_ABOUTME_TEXT,offset MSGBOX_ABOUTME_TITLE,MB_OK
		jmp ret_OnLButtonUp
onStory_OnLButtonUp:
	invoke crt_sprintf ,offset audioCmdBuf, offset STOP_SPRINTF,offset BGM_ZHP16_PATH
	invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,offset audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_ONGAME_PATH
	invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,offset audioCmdBuf, offset AUDIO_SPRINTF,offset BGM_ONGAME_PATH,400
	invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
	invoke  crt_time,NULL
	invoke  crt_srand,eax	;进游戏前播种
	invoke  initGame
	mov mainwinp.winState, winState_onGame
	jmp ret_OnLButtonUp
onGame_OnLButtonUp:
	invoke isMouseInButton, mousex, mousey, BUTT_PAUSE_X,BUTT_PAUSE_Y,BUTT_PAUSE_W,BUTT_PAUSE_H
	cmp eax, 1	;在此按钮区域
	je clickPause_OnLButtonUp

	jmp ret_OnLButtonUp	;不在任何按钮范围
	clickPause_OnLButtonUp:
		mov mainwinp.winState, winState_pauseGame
		jmp ret_OnLButtonUp

pauseGame_OnLButtonUp:
	invoke isMouseInButton, mousex, mousey, BUTT_SAVE_X,BUTT_SAVE_Y,BUTT_SAVE_W,BUTT_SAVE_H
	cmp eax, 1	;在此按钮区域
	je clickSave_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CONTINUE_X,BUTT_CONTINUE_Y,BUTT_CONTINUE_W,BUTT_CONTINUE_H
	cmp eax, 1	;在此按钮区域
	je clickContinue_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_DANCEMODE_X,BUTT_DANCEMODE_Y,BUTT_DANCEMODE_W,BUTT_DANCEMODE_H
	cmp eax, 1	;在此按钮区域
	je clickDancemode_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_RETHOME_X,BUTT_RETHOME_Y,BUTT_RETHOME_W,BUTT_RETHOME_H
	cmp eax, 1	;在此按钮区域
	je clickRethome_OnLButtonUp
	
	jmp ret_OnLButtonUp	;不在任何按钮范围
	clickSave_OnLButtonUp:
		invoke archive
		invoke	MessageBox,NULL,offset MSGBOX_WINDOW_SAVESUCC_TEXT,offset MSGBOX_SAVESUCC_TITLE,MB_OK
		jmp ret_OnLButtonUp
	clickContinue_OnLButtonUp:
		mov mainwinp.winState, winState_onGame	
		jmp ret_OnLButtonUp
	clickDancemode_OnLButtonUp:
		invoke StartDanceMode
		;mov mainwinp.winState, winState_onGame	;点继续游戏了，到下一状态
		jmp ret_OnLButtonUp
	clickRethome_OnLButtonUp:
		invoke crt_sprintf ,offset audioCmdBuf, offset STOP_SPRINTF,offset BGM_ONGAME_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
		invoke crt_sprintf ,offset audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_HOME_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL	;播放故事bgm
		
		mov mainwinp.winState, winState_startPage
		jmp ret_OnLButtonUp
levelup_OnLButtonUp:
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICEA_X,BUTT_CHOICEA_Y,BUTT_CHOICEA_W,BUTT_CHOICEA_H
	cmp eax, 1	;在此按钮区域
	je clickA_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICEB_X,BUTT_CHOICEB_Y,BUTT_CHOICEB_W,BUTT_CHOICEB_H
	cmp eax, 1	;在此按钮区域
	je clickB_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICEC_X,BUTT_CHOICEC_Y,BUTT_CHOICEC_W,BUTT_CHOICEC_H
	cmp eax, 1	;在此按钮区域
	je clickC_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CHOICED_X,BUTT_CHOICED_Y,BUTT_CHOICED_W,BUTT_CHOICED_H
	cmp eax, 1	;在此按钮区域
	je clickD_OnLButtonUp
	
	jmp ret_OnLButtonUp	;不在任何按钮范围
	clickA_OnLButtonUp:
		mov questionChoice,0
		jmp checkChoice_OnLButtonUp
	clickB_OnLButtonUp:
		mov questionChoice,1
		jmp checkChoice_OnLButtonUp
	clickC_OnLButtonUp:
		mov questionChoice,2
		jmp checkChoice_OnLButtonUp
	clickD_OnLButtonUp:
		mov questionChoice,3
		jmp checkChoice_OnLButtonUp
	checkChoice_OnLButtonUp:
	mov ecx,questionChoice
	cmp mainwinp.levelup_answer,ecx
	je checkChoiceRight_OnLButtonUp
		inc game.level
		invoke  initLevel
		mov mainwinp.winState, winState_onGame
		mov game.player.bomb_range,2
		mov game.player.bomb_cnt,1
		mov game.player.life,1
		mov game.player.speed,PLAYER_1_SPEED
		invoke	MessageBox,hwnd,offset MSGBOX_ANSERR_TEXT,offset MSGBOX_WINDOW_ZHANGHP_TITLE,MB_OK
		jmp ret_OnLButtonUp
	checkChoiceRight_OnLButtonUp:
		inc game.level
		invoke  initLevel
		mov mainwinp.winState, winState_onGame
		invoke	MessageBox,hwnd,offset MSGBOX_ANSCORR_TEXT,offset MSGBOX_WINDOW_ZHANGHP_TITLE,MB_OK
		jmp ret_OnLButtonUp
	jmp ret_OnLButtonUp
ret_OnLButtonUp:
	ret
OnLButtonUp ENDP

mainLoop proc	hwnd:HWND
	local input:dword
    invoke  readKey
	mov input, eax
	cmp mainwinp.winState, winState_logoPage
	je logoPage_mainLoop
	cmp mainwinp.winState, winState_startPage
	je startPage_mainLoop
	cmp mainwinp.winState, winState_onStory
	je onStory_mainLoop
	cmp mainwinp.winState, winState_onGame
	je onGame_mainLoop
	cmp mainwinp.winState, winState_pauseGame
	je pauseGame_mainLoop
	cmp mainwinp.winState, winState_levelup
	je levelup_mainLoop
	cmp mainwinp.winState, winState_gamewin
	je gamewin_mainLoop
	cmp mainwinp.winState, winState_gameover
	je gameover_mainLoop
	cmp mainwinp.winState, winState_segerr
	je segerr_mainLoop
	jmp ret_mainLoop
logoPage_mainLoop:
	inc mainwinp.frames
	; 暂无其它轮询任务
	jmp ret_mainLoop
startPage_mainLoop:
	jmp ret_mainLoop
onStory_mainLoop:
	inc mainwinp.frames
	cmp input, SPACEJO
	je StoryIsOver_mainLoop
	cmp mainwinp.frames,400
	ja StoryIsOver_mainLoop
	
	jmp ret_mainLoop

	StoryIsOver_mainLoop:
		invoke crt_sprintf ,offset audioCmdBuf, offset STOP_SPRINTF,offset BGM_ZHP16_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
		invoke crt_sprintf ,offset audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_ONGAME_PATH
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
		invoke crt_sprintf ,offset audioCmdBuf, offset AUDIO_SPRINTF,offset BGM_ONGAME_PATH,400
		invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL
		
		invoke  crt_time,NULL
		invoke  crt_srand,eax	;进游戏前播种
		invoke  initGame
		mov mainwinp.winState, winState_onGame
		jmp ret_mainLoop
onGame_mainLoop:
	cmp input, GAMEPAUSE
	je GameToPause_mainLoop
		invoke gameLoop, input
		jmp ret_mainLoop
	GameToPause_mainLoop:
		mov mainwinp.winState, winState_pauseGame
		jmp ret_mainLoop
pauseGame_mainLoop:
	cmp input, GAMESTART
	je PauseToStart_mainLoop
		; 暂无轮询任务
		jmp ret_mainLoop
	PauseToStart_mainLoop:
		mov mainwinp.winState, winState_onGame
		jmp ret_mainLoop
	jmp ret_mainLoop
levelup_mainLoop:

	je ret_mainLoop
gamewin_mainLoop:
	inc mainwinp.frames
	jmp ret_mainLoop
gameover_mainLoop:
	inc mainwinp.frames
	jmp ret_mainLoop
segerr_mainLoop:
	inc mainwinp.frames
	cmp mainwinp.frames,120
	jb JOerrseg_mainLoop
		mov mainwinp.frames,0
		mov mainwinp.winState, winState_gamewin
	JOerrseg_mainLoop:
	jmp ret_mainLoop
ret_mainLoop:
	ret
mainLoop endp

InitBackSound proc hWin:dword
		mov eax,hWin        
		mov mciPlayParms.dwCallback,eax
		mov eax,OFFSET Mp3Device
		mov mciOpenParms.lpstrDeviceType,eax
	ret
InitBackSound endp
StopBackSound proc
		invoke mciSendCommand,mciOpenParms.wDeviceID,MCI_STOP,00000000h,ADDR mciPlayParms
		invoke mciSendCommand,0,MCI_CLOSE,0,ADDR mciOpenParms
		ret  
StopBackSound endp
StartBackSound proc NameOfFile:dword
		invoke StopBackSound
		mov eax,NameOfFile
		mov mciOpenParms.lpstrElementName,eax
		invoke mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
		invoke mciSendCommand,mciOpenParms.wDeviceID,MCI_PLAY,00010000h,ADDR mciPlayParms
		ret  
StartBackSound endp

PlayMp3File proc hWin:DWORD,NameOfFile:DWORD
	LOCAL mciOpenParmslocal:MCI_OPEN_PARMS,mciPlayParmslocal:MCI_PLAY_PARMS
		mov eax,hWin        
		mov mciPlayParmslocal.dwCallback,eax
		mov eax,OFFSET Mp3Device
		mov mciOpenParmslocal.lpstrDeviceType,eax
		mov eax,NameOfFile
		mov mciOpenParmslocal.lpstrElementName,eax
		invoke mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParmslocal
		mov mciPlayParmslocal.dwFrom, 0
		mov eax,mciOpenParmslocal.wDeviceID
		mov Mp3DeviceID,eax
		invoke mciSendCommand,mciOpenParmslocal.wDeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParmslocal
		ret  
PlayMp3File endp

WindowProc	proc	hwnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	local	ps:PAINTSTRUCT,hdc:HDC,hdcBuffer:HDC,memBitmap:HBITMAP,graphicsPtr:dword
	;这个地方没法跳转表
	cmp	uMsg,WM_TIMER
	je	WindowProcTimer
	cmp	uMsg,WM_CREATE
	je	WindowProcCreate
	cmp	uMsg,WM_DESTROY
	je	WindowProcDestroy
	cmp	uMsg,WM_PAINT
	je	WindowProcPaint
	cmp	uMsg,WM_LBUTTONUP
	je	WindowProcOnLButtonUp
WindowProcDefault:
	invoke	DefWindowProc,hwnd,uMsg,wParam,lParam
	ret
WindowProcTimer:
	;在这里进行每一刻的游戏逻辑更新
	invoke mainLoop,hwnd

	invoke	InvalidateRect,hwnd,NULL,TRUE	;通知重绘
	jmp	ExitWindowProc
WindowProcPaint:
	;创建绘图资源
	invoke	BeginPaint,hwnd,addr ps
	mov	hdc,eax
	invoke	CreateCompatibleDC,eax
	mov	hdcBuffer,eax
	invoke	CreateCompatibleBitmap,hdc,WINDOW_WIDTH,WINDOW_HEIGHT
	mov	memBitmap,eax
	invoke	SelectObject,hdcBuffer,eax
	invoke	GdipCreateFromHDC,hdcBuffer,addr graphicsPtr
	;在这里使用graphicsPtr进行画图函数的调用
	invoke	drawWindow,graphicsPtr,hdcBuffer
	invoke	BitBlt,hdc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,hdcBuffer,0,0,SRCCOPY	;双缓冲绘图技术防止闪烁
	;释放绘图资源
	invoke	GdipReleaseDC,graphicsPtr,hdcBuffer
	invoke	GdipDeleteGraphics,graphicsPtr
	invoke	DeleteObject,memBitmap
	invoke	DeleteDC,hdcBuffer
	invoke	EndPaint,hwnd,addr ps
	jmp	ExitWindowProc
WindowProcCreate:
	invoke	ImmAssociateContext, hwnd, NULL	;qjh测试功能，禁用输入法
	invoke	SetTimer,hwnd,1,20,NULL	;暂定每20ms更新一次状态，但实测频率低于理论值
	invoke	InitDanceMode
	invoke crt_sprintf ,offset audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_HOME_PATH
	invoke mciSendString ,offset audioCmdBuf,NULL,0,NULL	;播放故事bgm
	jmp	ExitWindowProc
WindowProcDestroy:
	invoke	KillTimer,hwnd,1
	invoke	PostQuitMessage,0
	jmp ExitWindowProc
WindowProcOnLButtonUp:
	invoke OnLButtonUp, wParam, lParam,hwnd
	jmp ExitWindowProc
ExitWindowProc:
	xor	eax,eax
	ret
WindowProc	endp


WinMain	proc	hInst:HINSTANCE,hPrevInst:HINSTANCE,cmdLine:LPSTR,cmdShow:DWORD
	local	wc:WNDCLASS,msg:MSG,gdiToken:dword,errorMsg[100]:byte
	invoke	checkAllImages,addr errorMsg
	test	eax,eax
	jnz	ErrorLoad
	invoke	readInfo,addr errorMsg
	test	eax,eax
	jnz	ErrorLoad
	invoke	GdiplusStartup,addr gdiToken,offset GP_INPUT,NULL	;GDI+，启动！
	invoke	initResources	;加载图像、文本等资源
	mov	wc.lpfnWndProc,offset WindowProc
	mov	eax,hInst
	mov	wc.hInstance,eax
	mov	wc.lpszClassName,offset CLASS_NAME
	invoke LoadIcon, NULL, IDI_WINLOGO	;qjh测试功能，窗口小图标
	mov wc.hIcon, eax 
	invoke LoadCursor, NULL, IDC_ARROW
	mov wc.hCursor, eax		;qjh测试功能，选定鼠标图标防止转圈不好看
	invoke	RegisterClass,addr wc
	invoke	CreateWindowEx,0,offset CLASS_NAME,offset WINDOW_NAME,WS_OVERLAPPEDWINDOW XOR WS_THICKFRAME XOR WS_MAXIMIZEBOX,CW_USEDEFAULT,CW_USEDEFAULT,1000,750,NULL,NULL,hInst,NULL	;hwnd in eax
	test	eax,eax
	jz	ErrorCreate
	invoke	ShowWindow,eax,cmdShow
	; 初始化win状态，准备开始淡入淡出
	mov mainwinp.frames, 0
	mov mainwinp.winState, winState_logoPage	
EventLoop:
	invoke	GetMessage,addr msg,NULL,0,0
	test	eax,eax
	jz	ExitMain
	invoke	TranslateMessage,addr msg
	invoke	DispatchMessage,addr msg
	jmp	EventLoop
ErrorLoad:
	invoke	MessageBox,NULL,addr errorMsg,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	jmp	ExitMain
ErrorCreate:
	invoke	MessageBox,NULL,offset MSGBOX_WINDOW_FAIL_TEXT,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	mov	eax,1
ExitMain:
	invoke	releaseResources	;释放图像资源
	invoke	GdiplusShutdown,gdiToken	;关闭GDI+
	cmp dancemode_pi.hProcess,0
	je JOkillDance_WinMain
		invoke	TerminateProcess,dancemode_pi.hProcess,300
	JOkillDance_WinMain:
	ret
WinMain	endp

start:
	invoke	GetModuleHandle,NULL
	mov	edx,eax
	invoke	GetCommandLine
	invoke	WinMain,edx,NULL,eax,SW_SHOWDEFAULT
	invoke	ExitProcess,eax
end	start
