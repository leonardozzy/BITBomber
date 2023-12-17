.486
.model	flat,stdcall
option	casemap:none

public  mainwinp
include	common.inc

.data
mainwinp	MainWinp	<>
Mp3DeviceID dd 0
.const 
MAIN_BGM_SOUND_PATH	byte	"./sounds/Keygen.mp3",0
Mp3Device   db "MPEGVideo",0
CLASS_NAME	byte	"MainWindow",0	;��������
WINDOW_NAME	byte	"BIT BOMBERMAN",0	;������ʾ��
GP_INPUT	GdiplusStartupInput	<1,0,0,0>
MSGBOX_WINDOW_FAIL_TEXT	byte	"���ڴ���ʧ�ܣ�",0
MSGBOX_ERROR_TITLE	byte	"����",0

.code


readKey Proc
    invoke GetAsyncKeyState,'B'
    test eax, 0001H
	jnz keyB_readKey
    invoke GetAsyncKeyState,'W'
    test eax, 0001H
	jnz keyW_readKey
    invoke GetAsyncKeyState,'S'
    test eax, 0001H
	jnz keyS_readKey
    invoke GetAsyncKeyState,'A'
    test eax, 0001H
	jnz keyA_readKey
    invoke GetAsyncKeyState,'D'
    test eax, 0001H
	jnz keyD_readKey
    invoke GetAsyncKeyState,'P'
    test eax, 0001H
	jnz keyP_readKey
    invoke GetAsyncKeyState,'R'
    test eax, 0001H
	jnz keyR_readKey
    mov eax,-1
    jmp ret_readKey
keyB_readKey:
    mov eax,SETBOMB
    jmp ret_readKey
keyW_readKey:
    mov eax,UP
    jmp ret_readKey
keyS_readKey:
    mov eax,DOWN
    jmp ret_readKey
keyA_readKey:
    mov eax,LEFT
    jmp ret_readKey
keyD_readKey:
    mov eax,RIGHT
    jmp ret_readKey
keyP_readKey:
    mov eax,GAMEPAUSE
    jmp ret_readKey
keyR_readKey:
    mov eax,GAMESTART
    jmp ret_readKey
ret_readKey:
    ret
readKey endp

OnLButtonUp proc wParam:WPARAM, lParam:LPARAM
	local mousex:sword, mousey:sword
	mov eax, lParam
	mov mousex, ax
	shr eax, 16
	mov mousey, ax	;��λ�������������
	cmp mainwinp.winState, winState_logoPage
	je logoPage_OnLButtonUp
	cmp mainwinp.winState, winState_startPage
	je startPage_OnLButtonUp
	cmp mainwinp.winState, winState_onGame
	je onStory_OnLButtonUp
	cmp mainwinp.winState, winState_pauseGame
	je onGame_OnLButtonUp
	cmp mainwinp.winState, winState_pauseGame
	je pauseGame_OnLButtonUp
	jmp ret_OnLButtonUp
logoPage_OnLButtonUp:
	
	jmp ret_OnLButtonUp
startPage_OnLButtonUp:
	;670,510 880,570
	invoke isMouseInButton, mousex, mousey, BUTT_STARTNEW_X,BUTT_STARTNEW_Y,BUTT_STARTNEW_W,BUTT_STARTNEW_H
	cmp eax, 1	;�ڴ˰�ť����
	je clickStartNew_OnLButtonUp
	invoke isMouseInButton, mousex, mousey, BUTT_CONTINUE_X,BUTT_CONTINUE_Y,BUTT_CONTINUE_W,BUTT_CONTINUE_H
	cmp eax, 1	;�ڴ˰�ť����
	je clickContinue_OnLButtonUp
	
	jmp ret_OnLButtonUp	;�����κΰ�ť��Χ
	clickStartNew_OnLButtonUp:
		mov mainwinp.frames, 0
		mov mainwinp.winState, winState_onStory	;��ȫ����Ϸ�ˣ�����һ״̬
		jmp ret_OnLButtonUp
	clickContinue_OnLButtonUp:
		invoke load
		mov mainwinp.winState, winState_onGame	;�������Ϸ�ˣ�����һ״̬
		jmp ret_OnLButtonUp
onGame_OnLButtonUp:
	
	jmp ret_OnLButtonUp
onStory_OnLButtonUp:
	
	jmp ret_OnLButtonUp
pauseGame_OnLButtonUp:
	
	jmp ret_OnLButtonUp
ret_OnLButtonUp:
	ret
OnLButtonUp ENDP

mainLoop proc
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
	jmp ret_mainLoop
logoPage_mainLoop:
	inc mainwinp.frames
	; ����������ѯ����
	jmp ret_mainLoop
startPage_mainLoop:
	; ��ʱû����ѯ����
	jmp ret_mainLoop
onStory_mainLoop:
	inc mainwinp.frames
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
		; ������ѯ����
		jmp ret_mainLoop
	PauseToStart_mainLoop:
		mov mainwinp.winState, winState_onGame
		jmp ret_mainLoop
	jmp ret_mainLoop
ret_mainLoop:
	ret
mainLoop endp

PlayMp3File proc hWin:dword,NameOfFile:dword
	LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS
		mov eax,hWin        
		mov mciPlayParms.dwCallback,eax
		mov eax,OFFSET Mp3Device
		mov mciOpenParms.lpstrDeviceType,eax
		mov eax,NameOfFile
		mov mciOpenParms.lpstrElementName,eax
		invoke mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
		mov eax,mciOpenParms.wDeviceID
		mov Mp3DeviceID,eax
		invoke mciSendCommand,Mp3DeviceID,MCI_PLAY,00010000h,ADDR mciPlayParms
		ret  
PlayMp3File endp

WindowProc	proc	hwnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	local	ps:PAINTSTRUCT,hdc:HDC,hdcBuffer:HDC,memBitmap:HBITMAP,graphicsPtr:dword
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
	;���������ÿһ�̵���Ϸ�߼�����
	invoke mainLoop

	invoke	InvalidateRect,hwnd,NULL,TRUE	;֪ͨ�ػ�
	jmp	ExitWindowProc
WindowProcPaint:
	;������ͼ��Դ
	invoke	BeginPaint,hwnd,addr ps
	mov	hdc,eax
	invoke	CreateCompatibleDC,eax
	mov	hdcBuffer,eax
	invoke	CreateCompatibleBitmap,hdc,WINDOW_WIDTH,WINDOW_HEIGHT
	mov	memBitmap,eax
	invoke	SelectObject,hdcBuffer,eax
	invoke	GdipCreateFromHDC,hdcBuffer,addr graphicsPtr
	;������ʹ��graphicsPtr���л�ͼ�����ĵ��ã���ֻ��һ��ʾ��
	;invoke	drawSolidRect,graphicsPtr,0ffffffffh,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	drawWindow,graphicsPtr
	invoke	BitBlt,hdc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,hdcBuffer,0,0,SRCCOPY	;˫�����ͼ������ֹ��˸
	;�ͷŻ�ͼ��Դ
	invoke	GdipReleaseDC,graphicsPtr,hdcBuffer
	invoke	GdipDeleteGraphics,graphicsPtr
	invoke	DeleteObject,memBitmap
	invoke	DeleteDC,hdcBuffer
	invoke	EndPaint,hwnd,addr ps
	jmp	ExitWindowProc
WindowProcCreate:
	invoke PlayMp3File,hwnd,ADDR MAIN_BGM_SOUND_PATH	;������
	invoke ImmAssociateContext, hwnd, NULL	;qjh���Թ��ܣ��������뷨
	invoke	SetTimer,hwnd,1,20,NULL	;�ݶ�ÿ20ms����һ��״̬����ʵ��Ƶ�ʵ�������ֵ
	jmp	ExitWindowProc
WindowProcDestroy:
	invoke	KillTimer,hwnd,1
	invoke	PostQuitMessage,0
	jmp ExitWindowProc
WindowProcOnLButtonUp:
	invoke OnLButtonUp, wParam, lParam
	jmp ExitWindowProc
ExitWindowProc:
	xor	eax,eax
	ret
WindowProc	endp


WinMain	proc	hInst:HINSTANCE,hPrevInst:HINSTANCE,cmdLine:LPSTR,cmdShow:DWORD
	local	wc:WNDCLASS,msg:MSG,gdiToken:dword
	invoke	GdiplusStartup,addr gdiToken,offset GP_INPUT,NULL	;GDI+��������
	invoke	initResources	;����ͼ���ı�����Դ
	mov	wc.lpfnWndProc,offset WindowProc
	mov	eax,hInst
	mov	wc.hInstance,eax
	mov	wc.lpszClassName,offset CLASS_NAME
	invoke LoadIcon, NULL, IDI_WINLOGO	;qjh���Թ��ܣ�����Сͼ��
	mov wc.hIcon, eax 
	invoke LoadCursor, NULL, IDC_ARROW
	mov wc.hCursor, eax		;qjh���Թ��ܣ�ѡ�����ͼ���ֹתȦ���ÿ�
	invoke	RegisterClass,addr wc
	invoke	CreateWindowEx,0,offset CLASS_NAME,offset WINDOW_NAME,WS_OVERLAPPEDWINDOW XOR WS_THICKFRAME XOR WS_MAXIMIZEBOX,CW_USEDEFAULT,CW_USEDEFAULT,1000,750,NULL,NULL,hInst,NULL	;hwnd in eax
	test	eax,eax
	jz	ErrorCreate
	invoke	ShowWindow,eax,cmdShow
	; ��ʼ��win״̬��׼����ʼ���뵭��
	mov mainwinp.frames, 0
	mov mainwinp.winState, winState_logoPage	
EventLoop:
	invoke	GetMessage,addr msg,NULL,0,0
	test	eax,eax
	jz	ExitMain
	invoke	TranslateMessage,addr msg
	invoke	DispatchMessage,addr msg
	jmp	EventLoop
ErrorCreate:
	invoke	MessageBox,NULL,offset MSGBOX_WINDOW_FAIL_TEXT,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	mov	eax,1
ExitMain:
	invoke	releaseResources	;�ͷ�ͼ����Դ
	invoke	GdiplusShutdown,gdiToken	;�ر�GDI+
	ret
WinMain	endp

start:
	invoke	GetModuleHandle,NULL
	mov	edx,eax
	invoke	GetCommandLine
	invoke	WinMain,edx,NULL,eax,SW_SHOWDEFAULT
	invoke	ExitProcess,eax
end	start
