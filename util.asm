.386
.model	flat,stdcall
option	casemap:none

include common.inc
extrn	dancemode_si:STARTUPINFO
extrn	dancemode_pi:PROCESS_INFORMATION
extrn	game:Game
extrn	mainwinp:MainWinp
extrn	level_cnt:dword
extrn	levelup_question:byte
extrn	levelup_choice1:byte
extrn	levelup_choice2:byte
extrn	levelup_choice3:byte
extrn	levelup_choice4:byte
extrn	level_cnt:dword
extrn	question_cnt:dword

.const
BGM_HOME_PATH	byte	"./audio/HomePage.mp3",0
BGM_ONGAME_PATH	byte	"./audio/InGame.mp3",0
BGM_ZHP16_PATH	byte	"./audio/Zhp16s.mp3",0
BGM_BOSS_PATH	byte	"./audio/Boss.mp3",0
PLAY_SPRINTF byte "play %s",0
PLAY_REPEAT_SPRINTF byte "play %s repeat",0
STOP_SPRINTF byte "stop %s",0
AUDIO_SPRINTF byte "setaudio %s volume to %d",0
DANCEMODE_PATH	byte	".\\DanceMode_ext\\python.exe",0
DANCEMODE_PY_PATH	byte	".\\DanceMode_ext\\python.exe .\\DanceMode_ext\\d_kep.py",0
INFO_FILENAME  byte    "./info.txt",0
FILENAMESAVE	byte	"./save.bb",0
OPEN_FILE_READ_ONLY	byte	"r",0
OPEN_BFILE_READ_ONLY	byte	"rb",0
OPEN_BFILE_WRITE_ONLY	byte	"wb",0
TWO_INT_FORMAT  byte    "%d%d",0
LEVEL_FILENAME_FORMAT   byte    "./levels/%02d.level",0
QUES_FILENAME_FORMAT byte   "./questions/%03d.question",0
FILE_NOT_FOUND_FORMAT   byte    "%s not found!",0

.code
;这个函数用于计算访问地图数组时的等效一维下标。
;真实偏移量还需乘上sizeof Object（目前是4，使用时可以直接比例变址寻址哦）。
;尽量少调用。
calcMapOffset	proc x:dword,y:dword,z:dword
	imul	eax,x,COL*DEPTH
	imul	ecx,y,DEPTH
	add	eax,ecx
	add	eax,z
	ret
calcMapOffset	endp

;判断mousexy是否在xy，x+w y+h范围内，鼠标点击按键检测
isMouseInButton	proc	mousex:dword,mousey:dword,x:dword,y:dword,w:dword,h:dword
	mov	edx,mousex
	cmp	edx,x
	jl	notIn_isMouseInButton
	sub	edx,x
	cmp	edx,w
	jg	notIn_isMouseInButton
	mov	edx,mousey
	cmp	edx,y
	jl	notIn_isMouseInButton
	sub	edx,y
	cmp	edx,h
	jg	notIn_isMouseInButton
	mov	eax,1
	ret
notIn_isMouseInButton:
	xor	eax,eax
	ret
isMouseInButton	endp

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

readKeyInGame	Proc
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
readKeyInGame	endp

jobGameToQuestion	proc
	invoke readQuestion,offset levelup_question,offset levelup_choice1,offset levelup_choice2,offset levelup_choice3,offset levelup_choice4
	mov mainwinp.correctAnswer,eax
	ret
jobGameToQuestion	endp

jobToStory	proc
	local	audioCmdBuf[256]:byte
	invoke	crt_sprintf,addr audioCmdBuf,offset STOP_SPRINTF,offset BGM_HOME_PATH
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
	invoke	crt_sprintf,addr audioCmdBuf,offset PLAY_SPRINTF,offset BGM_ZHP16_PATH
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
	mov	mainwinp.timer,0
	ret
jobToStory	endp

jobToStart	proc
	local	audioCmdBuf[256]:byte
	invoke	crt_time,NULL
	invoke	crt_srand,eax	;随机数播种
	invoke	crt_sprintf,addr audioCmdBuf,offset STOP_SPRINTF,offset BGM_ONGAME_PATH
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
	invoke	crt_sprintf,addr audioCmdBuf,offset STOP_SPRINTF,offset BGM_BOSS_PATH
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
	invoke	crt_sprintf,addr audioCmdBuf,offset PLAY_REPEAT_SPRINTF,offset BGM_HOME_PATH
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
	ret
jobToStart	endp

jobResetTimer	proc
	mov	mainwinp.timer,0
	ret
jobResetTimer	endp

jobHomeToGame	proc
	local	audioCmdBuf[256]:byte
	invoke	crt_sprintf,addr audioCmdBuf,offset STOP_SPRINTF,offset BGM_HOME_PATH
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
	mov	eax,game.level
	inc	eax
	cmp	eax,level_cnt
	je	setBossBGM_jobContinueGame
	invoke crt_sprintf ,addr audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_ONGAME_PATH
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,addr audioCmdBuf, offset AUDIO_SPRINTF,offset BGM_ONGAME_PATH,400
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	ret
setBossBGM_jobContinueGame:
	invoke crt_sprintf ,addr audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_BOSS_PATH
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,addr audioCmdBuf, offset AUDIO_SPRINTF,offset BGM_BOSS_PATH,400
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	ret
jobHomeToGame	endp

jobTutorialToGame	proc
	local	audioCmdBuf[256]:byte
	invoke crt_sprintf ,addr audioCmdBuf, offset STOP_SPRINTF,offset BGM_ZHP16_PATH
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,addr audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_ONGAME_PATH
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,addr audioCmdBuf, offset AUDIO_SPRINTF,offset BGM_ONGAME_PATH,400
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	ret
jobTutorialToGame	endp

jobAnswerToGame	proc
	local	audioCmdBuf[256]:byte
	inc	game.level
	invoke	initLevel
	mov	eax,game.level
	inc	eax
	cmp	eax,level_cnt
	jne	exit_jobFinishAnswer
	invoke	crt_sprintf,addr audioCmdBuf,offset STOP_SPRINTF,offset BGM_ONGAME_PATH
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,addr audioCmdBuf, offset PLAY_REPEAT_SPRINTF,offset BGM_BOSS_PATH
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
	invoke crt_sprintf ,addr audioCmdBuf, offset AUDIO_SPRINTF,offset BGM_BOSS_PATH,400
	invoke mciSendString ,addr audioCmdBuf,NULL,0,NULL
exit_jobFinishAnswer:
	ret
jobAnswerToGame	endp

jobQuestionToAnswer	proc
	mov	eax,mainwinp.playerAnswer
	cmp	eax,mainwinp.correctAnswer
	je	exit_jobQuestionToAnswer
	mov	game.player.life,1
	mov	game.player.speed,PLAYER_1_SPEED
	mov game.player.bomb_range,2
	mov game.player.bomb_cnt,1
exit_jobQuestionToAnswer:
	ret
jobQuestionToAnswer	endp

checkTimerAndFade	proc	maxTime:dword,nextState:dword,transitionFunc:dword
	mov	eax,mainwinp.timer
	cmp	eax,maxTime
	jne	timerNotReach_checkTimer
	mov	eax,nextState
	mov	mainwinp.intentState,eax
	mov	eax,transitionFunc
	mov	mainwinp.transitionFunc,eax
	mov	mainwinp.shouldFade,TRUE
	ret
timerNotReach_checkTimer:
	inc	mainwinp.timer
	ret
checkTimerAndFade	endp

readInfo    proc    errorInfo:ptr byte
	local   fileNameStr[50]:byte
	push    ebx
	;ebx:文件指针
	invoke  crt_fopen,offset INFO_FILENAME,offset OPEN_FILE_READ_ONLY
	test    eax,eax
	jnz  infoFound_readInfo
	invoke  crt_sprintf,errorInfo,offset FILE_NOT_FOUND_FORMAT,offset INFO_FILENAME
	jmp errorExit_readInfo
infoFound_readInfo:
	mov ebx,eax
	invoke  crt_fscanf,eax,offset TWO_INT_FORMAT,offset level_cnt,offset question_cnt
	cmp eax,2
	jz  numberOk_readInfo
	invoke  crt_sprintf,errorInfo,offset FILE_NOT_FOUND_FORMAT,offset INFO_FILENAME
	jmp errorExit_readInfo
numberOk_readInfo:
	cmp level_cnt,MAX_LEVEL
	jle levelOk_readInfo
	mov level_cnt,MAX_LEVEL
levelOk_readInfo:
	cmp question_cnt,MAX_QUESTION
	jle questionOk_readInfo
	mov question_cnt,MAX_QUESTION
questionOk_readInfo:
	invoke  crt_fclose,ebx
	;ebx循环变量
	xor ebx,ebx
loop1_readInfo:
	cmp ebx,level_cnt
	je  exitLoop1_readInfo
	invoke  crt_sprintf,addr fileNameStr,offset LEVEL_FILENAME_FORMAT,ebx
	invoke  crt_fopen,addr fileNameStr,offset OPEN_FILE_READ_ONLY
	test    eax,eax
	jnz fileFound_readInfo
	invoke  crt_sprintf,errorInfo,offset FILE_NOT_FOUND_FORMAT,addr fileNameStr
	jmp errorExit_readInfo
fileFound_readInfo:
	invoke  crt_fclose,eax
	inc ebx
	jmp loop1_readInfo
exitLoop1_readInfo:
	xor ebx,ebx
loop2_readInfo:
	cmp ebx,question_cnt
	je  exitLoop2_readInfo
	invoke  crt_sprintf,addr fileNameStr,offset QUES_FILENAME_FORMAT,ebx
	invoke  crt_fopen,addr fileNameStr,offset OPEN_FILE_READ_ONLY
	test    eax,eax
	jnz fileFound2_readInfo
	invoke  crt_sprintf,errorInfo,offset FILE_NOT_FOUND_FORMAT,addr fileNameStr
	jmp errorExit_readInfo
fileFound2_readInfo:
	invoke  crt_fclose,eax
	inc ebx
	jmp loop2_readInfo
exitLoop2_readInfo:
	xor eax,eax
	jmp exit_readInfo
errorExit_readInfo:
	mov eax,1
exit_readInfo:
	pop ebx
	ret
readInfo    endp

readQuestion proc	question:ptr byte,choice1:ptr byte,choice2:ptr byte,choice3:ptr byte,choice4:ptr byte
	local questionFileName[50]:byte
	push	edi
	invoke crt_rand
	xor	edx,edx
	mov	ecx,question_cnt
	div	ecx
	invoke crt_sprintf,addr questionFileName,offset QUES_FILENAME_FORMAT,edx
	invoke crt_fopen,addr questionFileName,offset OPEN_FILE_READ_ONLY
	test    eax,eax
	jnz fileFound_readQuestion
	invoke  crt_exit,1
	ret
fileFound_readQuestion:
	mov edi,eax
	invoke crt_fgets,question,512,edi
	invoke	crt_fgets,choice1,64,edi
	invoke	crt_fgets,choice2,64,edi
	invoke	crt_fgets,choice3,64,edi
	invoke	crt_fgets,choice4,64,edi
	invoke  crt_fgetc,edi
	push    eax
	invoke	crt_fclose,edi
	pop eax
	sub eax,'A'
	pop	edi
	ret
readQuestion endp

archive proc
	local   file:ptr FILE
	invoke  crt_fopen,offset FILENAMESAVE,offset OPEN_BFILE_WRITE_ONLY
	test	eax,eax
	jz	err_archive
	mov file,eax
	invoke  crt_fwrite,offset game,sizeof Game,1,eax
	invoke  crt_fclose,file
	xor	eax,eax
	ret
err_archive:
	mov	eax,1
	ret
archive endp

load    proc
	local   file:ptr FILE
	invoke  crt_fopen,offset FILENAMESAVE,offset OPEN_BFILE_READ_ONLY
	test    eax,eax
	jz  err_load
	mov file,eax
	invoke  crt_fread,offset game,sizeof Game,1,eax
	invoke  crt_fclose,file
	xor eax,eax
	ret
err_load:
	mov eax,1
	ret
load    endp
end
;alternative save/load functions
comment	!
archive	proc
	local	wallCnt:dword,boxCnt:dword,file:ptr FILE
	local	wallOffset[200]:dword,boxOffset[200]:dword
	push	ebx
	invoke	crt_fopen,offset FILENAMESAVE,offset OPEN_BFILE_WRITE_ONLY
	mov	file,eax
	xor	ebx,ebx
	mov	wallCnt,0
	mov	boxCnt,0
loop_archive:
	cmp	ebx,sizeof game.map
	jge	exitLoop_archive
	cmp	game.map[ebx]._type,WALL
	je	saveWall_archive
	cmp	game.map[ebx]._type,BOX
	je	saveBox_archive
	jmp	continue_archive
saveWall_archive:
	mov	eax,wallCnt
	mov	wallOffset[eax*4],ebx
	inc	wallCnt
	jmp	continue_archive
saveBox_archive:
	mov	eax,boxCnt
	mov	boxOffset[eax*4],ebx
	inc	boxCnt
continue_archive:
	add	ebx,DEPTH*sizeof Object
	jmp	loop_archive
exitLoop_archive:
	invoke	crt_fwrite,addr wallCnt,4,1,file
	invoke	crt_fwrite,addr wallOffset,4,wallCnt,file
	invoke	crt_fwrite,addr boxCnt,4,1,file
	invoke	crt_fwrite,addr	boxOffset,4,boxCnt,file
	invoke	crt_fwrite,offset game.monsters,sizeof(Game)-ROW*COL*DEPTH*sizeof(Object),1,file
	invoke	crt_fclose,file
	pop	ebx
	ret
archive	endp

load	proc
	local   file:ptr FILE,cnt:dword,objOffset:dword
	push	ebx
	push	esi
	invoke	crt_memset,offset game.map,0,ROW*COL*DEPTH*sizeof Object
	invoke  crt_fopen,offset FILENAMESAVE,offset OPEN_BFILE_READ_ONLY
	test    eax,eax
	jz  err_load
	mov file,eax
	invoke	crt_fread,addr cnt,4,1,file
	xor	esi,esi
loop1_load:
	cmp	esi,cnt
	je	exitLoop1_load
	invoke	crt_fread,addr objOffset,4,1,file
	mov	eax,objOffset
	mov	game.map[eax]._type,WALL
	inc	esi
	jmp	loop1_load
exitLoop1_load:
	invoke	crt_fread,addr cnt,4,1,file
	xor	esi,esi
loop2_load:
	cmp	esi,cnt
	je	exitLoop2_load
	invoke	crt_fread,addr objOffset,4,1,file
	mov	eax,objOffset
	mov	game.map[eax]._type,BOX
	inc	esi
	jmp	loop2_load
exitLoop2_load:
	invoke	crt_fread,offset game.monsters,sizeof(Game)-ROW*COL*DEPTH*sizeof(Object),1,file
	invoke  crt_fclose,file
	xor	esi,esi
	xor	ebx,ebx
monsterLoop_load:
	cmp	ebx,MAX_MONSTER*sizeof Monster
	je	exitMonsterLoop_load
	cmp	game.monsters[ebx].valid,0
	je	continueMonsterLoop_load
	invoke	calcMapOffset,game.monsters[ebx].x,game.monsters[ebx].y,2
	mov	game.map[eax*4]._type,MONSTER
	mov	game.map[eax*4].id,si
continueMonsterLoop_load:
	add	ebx,sizeof Monster
	inc	esi
	jmp	monsterLoop_load
exitMonsterLoop_load:
	xor	ebx,ebx
	xor	esi,esi
bombLoop_load:
	cmp	ebx,MAX_BOMB*sizeof Bomb
	je	exitBombLoop_load
	cmp	game.bombs[ebx].timer,FIRE_TIMER
	jle	continueBombLoop_load
	invoke	calcMapOffset,game.bombs[ebx].x,game.bombs[ebx].y,0
	mov	game.map[eax*4]._type,BOMB
	mov	game.map[eax*4].id,si
continueBombLoop_load:
	add	ebx,sizeof Bomb
	inc	esi
	jmp	bombLoop_load
exitBombLoop_load:
	xor	ebx,ebx
	xor	esi,esi
toolLoop_load:
	cmp	ebx,MAX_TOOL*sizeof Tool
	je	exitToolLoop_load
	cmp	game.tools[ebx].timer,0
	je	continueToolLoop_load
	invoke	calcMapOffset,game.tools[ebx].x,game.tools[ebx].y,0
	mov	game.map[eax*4]._type,TOOL
	mov	game.map[eax*4].id,si
continueToolLoop_load:
	add	ebx,sizeof Tool
	inc	esi
	jmp	toolLoop_load
exitToolLoop_load:
	invoke	calcMapOffset,game.player.x,game.player.y,1
	mov	game.map[eax*4]._type,PLAYER
	cmp	game.boss.state,IN_MAP_STATE
	jne	skipSetBoss_load
	invoke	calcMapOffset,game.boss.x,game.boss.y,4
	mov	game.map[eax*4]._type,BOSS
skipSetBoss_load:
	xor eax,eax
	jmp	exit_load
err_load:
	mov eax,1
exit_load:
	pop	esi
	pop	ebx
	ret
load	endp
!