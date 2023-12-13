.486
.model	flat,stdcall
option	casemap:none

include	common.inc

.code
WindowProc	proc	hwnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	local	ps:PAINTSTRUCT,hdc:HDC,rect:RECT,hdcBuffer:HDC,memBitmap:HBITMAP,graphicsPtr:dword
	local	wWidth:dword,wHeight:dword
	cmp	uMsg,WM_TIMER
	je	WindowProcTimer
	cmp	uMsg,WM_CREATE
	je	WindowProcCreate
	cmp	uMsg,WM_DESTROY
	je	WindowProcDestroy
	cmp	uMsg,WM_PAINT
	je	WindowProcPaint
WindowProcDefault:
	invoke	DefWindowProc,hwnd,uMsg,wParam,lParam
	ret
WindowProcTimer:
	;在这里进行每一刻的游戏逻辑更新
	invoke	InvalidateRect,hwnd,NULL,TRUE	;通知重绘
	jmp	ExitWindowProc
WindowProcPaint:
	;创建绘图资源
	invoke	BeginPaint,hwnd,addr ps
	mov	hdc,eax
	invoke	CreateCompatibleDC,eax
	mov	hdcBuffer,eax
	invoke	GetClientRect,hwnd,addr rect
	mov	eax,rect.right
	sub	eax,rect.left
	mov	wWidth,eax
	mov	eax,rect.bottom
	sub	eax,rect.top
	mov	wHeight,eax
	invoke	CreateCompatibleBitmap,hdc,wWidth,eax
	mov	memBitmap,eax
	invoke	SelectObject,hdcBuffer,eax
	invoke	GdipCreateFromHDC,hdcBuffer,addr graphicsPtr
	;在这里进行画图函数的调用，使用graphicsPtr

	invoke	BitBlt,hdc,0,0,wWidth,wHeight,hdcBuffer,0,0,SRCCOPY	;双缓冲绘图技术防止闪烁
	;释放绘图资源
	invoke	GdipReleaseDC,graphicsPtr,hdcBuffer
	invoke	GdipDeleteGraphics,graphicsPtr
	invoke	DeleteObject,memBitmap
	invoke	DeleteDC,hdcBuffer
	invoke	EndPaint,hwnd,addr ps
	jmp	ExitWindowProc
WindowProcCreate:
	invoke	SetTimer,hwnd,1,20,NULL
	jmp	ExitWindowProc
WindowProcDestroy:
	invoke	KillTimer,hwnd,1
	invoke	PostQuitMessage,0
ExitWindowProc:
	xor	eax,eax
	ret
WindowProc	endp


WinMain	proc	hInst:HINSTANCE,hPrevInst:HINSTANCE,cmdLine:LPSTR,cmdShow:DWORD
	local	wc:WNDCLASS,msg:MSG,gdiToken:dword
	invoke	GdiplusStartup,addr gdiToken,offset GP_INPUT,NULL	;GDI+，启动！
	invoke	initResources	;加载图像、文本等资源
	mov	wc.lpfnWndProc,offset WindowProc
	mov	eax,hInst
	mov	wc.hInstance,eax
	mov	wc.lpszClassName,offset CLASS_NAME
	invoke	RegisterClass,addr wc
	invoke	CreateWindowEx,0,offset CLASS_NAME,offset WINDOW_NAME,WS_OVERLAPPEDWINDOW XOR WS_THICKFRAME XOR WS_MAXIMIZEBOX,CW_USEDEFAULT,CW_USEDEFAULT,1000,750,NULL,NULL,hInst,NULL	;hwnd in eax
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
ErrorCreate:
	invoke	MessageBox,NULL,offset MSGBOX_WINDOW_FAIL_TEXT,offset MSGBOX_ERROR_TITLE,MB_ICONERROR
	mov	eax,1
ExitMain:
	invoke	releaseResources	;释放图像资源
	invoke	GdiplusShutdown,gdiToken	;关闭GDI+
	ret
WinMain	endp

start:
	invoke	GetModuleHandle,NULL
	mov	edx,eax
	invoke	GetCommandLine
	invoke	WinMain,edx,NULL,eax,SW_SHOWDEFAULT
	invoke	ExitProcess,eax
end	start
