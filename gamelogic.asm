.486
.model	flat,stdcall
option	casemap:none

public game
include	common.inc
public  level_cnt
extrn	mainwinp:MainWinp
extrn	levelup_question:	byte
extrn	levelup_choice1:    byte
extrn	levelup_choice2:	byte	
extrn	levelup_choice3:    byte	
extrn	levelup_choice4:	byte

.const
LEVEL_CNT_FILENAME  byte    "./levels/count.txt",0
FILENAME1	byte	"./levels/4.level",0
FILENAME2	byte	"./levels/2.level",0
FILENAME3	byte	"./levels/3.level",0
FILENAME4	byte	"./levels/4.level",0
FILENAMESAVE	byte	"./save.bb",0

BOMB_AUDIO   byte    "./audio/Bomb.wav",0
PICK_AUDIO   byte   "./audio/PickUpTool.mp3",0  
DIE_AUDIO    byte   "./audio/Die.mp3",0
LEVEL_UP_AUDIO byte "./audio/Levelup.mp3",0
DRAGON_ROAR_AUDIO byte "./audio/DragonRoar.mp3",0
DRAGON_HURT_AUDIO byte "./audio/DragonHurt.wav",0
BGM_HOME_PATH	byte	"./audio/HomePage.mp3",0
BGM_STORY_PATH	byte	"./audio/Story.mp3",0
BGM_ONGAME_PATH	byte	"./audio/onGame.mp3",0
PLAY_SPRINTF byte "play %s",0
PLAY_REPEAT_SPRINTF byte "play %s repeat",0
STOP_SPRINTF byte "stop %s",0

INFO_FILENAME  byte    "./info.txt",0
OPEN_FILE_READ_ONLY	byte	"r",0
OPEN_BFILE_READ_ONLY	byte	"rb",0
OPEN_BFILE_WRITE_ONLY	byte	"wb",0
ONE_INT_FORMAT	byte	"%d",0
TWO_INT_FORMAT  byte    "%d%d",0
LEVEL_FILENAME_FORMAT   byte    "./levels/%02d.level",0
QUES_FILENAME_FORMAT byte   "./questions/%03d.question",0
FILE_NOT_FOUND_FORMAT   byte    "%s not found!",0
;四字节对齐，提升读取效率

align  4
LEVEL_FILE_NAMES	dword	offset FILENAME1,offset FILENAME2,offset FILENAME3,offset FILENAME4
TOOL_TYPE_JMP_TBL   dword   offset addLife_pollingPlayer,offset addRange_pollingPlayer,offset addCnt_pollingPlayer,offset addSpeed_pollingPlayer,offset addTime_pollingPlayer
MOVE_ONE_STEP_JMP_TBL   dword   offset direUp_moveOneStep,offset direDown_moveOneStep,offset direLeft_moveOneStep,offset direRight_moveOneStep
CALC_NEXT_MOVE_JMP_TBL  dword   offset direUp_calculateNextMove,offset direDown_calculateNextMove,offset direLeft_calculateNextMove,offset direRight_calculateNextMove
PLAYER_INPUT_JMP_TBL    dword   offset playerPressUp_pollingPlayer,offset playerPressDown_pollingPlayer,offset playerPressLeft_pollingPlayer,offset playerPressRight_pollingPlayer
MOV_MONSTER_TO_NEXT_CELL_JMP_TBL    dword   offset up1_switch_movMonsterToNextCell,offset down1_switch_movMonsterToNextCell,offset left1_switch_movMonsterToNextCell,offset right1_switch_movMonsterToNextCell
FROM_DIRECTION_TBL  dword   DOWN,UP,RIGHT,LEFT

.data?
level_cnt	dword	?
question_cnt	dword	?
game    Game    <>

.code
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
	invoke crt_fgets,question,100,edi
	invoke	crt_fgets,choice1,50,edi
	invoke	crt_fgets,choice2,50,edi
	invoke	crt_fgets,choice3,50,edi
	invoke	crt_fgets,choice4,50,edi
    invoke  crt_fgetc,edi
    push    eax
	invoke	crt_fclose,edi
    pop eax
    sub eax,'A'
	pop	edi
	ret
readQuestion endp

placeBomb	proc	
    push    ebx
    cmp game.player.bomb_cnt,0
    jng ret_placeBomb
    invoke calcMapOffset,game.player.x,game.player.y,0
    cmp game.map[4*eax]._type,EMPTY
    jne ret_placeBomb
    ;;;if (this->player.bomb_cnt > 0 && this->map[this->player.x][this->player.y][0].type==EMPTY) {
    ; Find an empty slot for a new bomb
    xor ecx,ecx
    xor ebx,ebx
    ALLBOMB_LOOP_placeBomb:
        cmp game.bombs[ecx].timer, 0    ;Assuming a bomb's timer <= 0 means it's inactive
        jg ALLBOMB_LOOPEND_placeBomb 
            mov edx, game.player.x
            mov game.bombs[ecx].x, edx
            mov edx, game.player.y
            mov game.bombs[ecx].y, edx
            mov game.bombs[ecx].timer, BOMB_TIMER+FIRE_TIMER    ;Set a timer for the bomb
            mov edx, game.player.bomb_range
            mov game.bombs[ecx].range, edx
            mov game.map[4*eax]._type, BOMB
            mov game.map[4*eax].id,bx
            dec game.player.bomb_cnt
            jmp ret_placeBomb
        ALLBOMB_LOOPEND_placeBomb:
        add ecx, sizeof Bomb ;add sizeof(Bomb) per loop
        inc ebx
        cmp ecx, MAX_BOMB*sizeof Bomb
        jb ALLBOMB_LOOP_placeBomb
ret_placeBomb:
    pop ebx
	ret
placeBomb	endp


pollingPlayer	proc	input:dword
    local audioCmd[100]:byte
    mov game.player.isMove,STILL
    cmp game.player.timer,0
    je  JmpOverINVISIBLE_pollingPlayer
    dec game.player.timer
JmpOverINVISIBLE_pollingPlayer:
    cmp input,0
    jl  ret_pollingPlayer
    cmp input, SETBOMB
    jne JmpOver_placeBomb_pollingPlayer
    invoke placeBomb
    jmp ret_pollingPlayer
JmpOver_placeBomb_pollingPlayer:
    invoke calcMapOffset, game.player.x, game.player.y, 1
    mov game.map[eax*4]._type,EMPTY
    mov eax,input
    mov game.player.direction,eax
    mov game.player.isMove,MOVE
    jmp [PLAYER_INPUT_JMP_TBL+eax*4]

playerPressUp_pollingPlayer   label   dword
    mov eax,game.player.frac_x
    sub eax,game.player.speed
    mov game.player.frac_x,eax
    cmp eax,-FRAC_RANGE
    jge exitInputSwitch_pollingPlayer
    mov eax,game.player.x
    dec eax
    invoke  isMoveable,eax,game.player.y
    test    eax,eax
    jnz  canMoveUp_pollingPlayer
    mov game.player.frac_x,-FRAC_RANGE
    jmp exitInputSwitch_pollingPlayer
canMoveUp_pollingPlayer:
    dec game.player.x
    mov eax,game.player.frac_x
    add eax,2*FRAC_RANGE
    mov game.player.frac_x,eax
    jmp exitInputSwitch_pollingPlayer
playerPressDown_pollingPlayer label   dword
    mov eax,game.player.frac_x
    add eax,game.player.speed
    mov game.player.frac_x,eax
    cmp eax,FRAC_RANGE
    jl exitInputSwitch_pollingPlayer
    mov eax,game.player.x
    inc eax
    invoke  isMoveable,eax,game.player.y
    test    eax,eax
    jnz  canMoveDown_pollingPlayer
    mov game.player.frac_x,FRAC_RANGE-1
    jmp exitInputSwitch_pollingPlayer
canMoveDown_pollingPlayer:
    inc game.player.x
    mov eax,game.player.frac_x
    sub eax,2*FRAC_RANGE
    mov game.player.frac_x,eax
    jmp exitInputSwitch_pollingPlayer
playerPressLeft_pollingPlayer label   dword
    mov eax,game.player.frac_y
    sub eax,game.player.speed
    mov game.player.frac_y,eax
    cmp eax,-FRAC_RANGE
    jge exitInputSwitch_pollingPlayer
    mov eax,game.player.y
    dec eax
    invoke  isMoveable,game.player.x,eax
    test    eax,eax
    jnz  canMoveLeft_pollingPlayer
    mov game.player.frac_y,-FRAC_RANGE
    jmp exitInputSwitch_pollingPlayer
canMoveLeft_pollingPlayer:
    dec game.player.y
    mov eax,game.player.frac_y
    add eax,2*FRAC_RANGE
    mov game.player.frac_y,eax
    jmp exitInputSwitch_pollingPlayer

playerPressRight_pollingPlayer    label   dword
    mov eax,game.player.frac_y
    add eax,game.player.speed
    mov game.player.frac_y,eax
    cmp eax,FRAC_RANGE
    jl exitInputSwitch_pollingPlayer
    mov eax,game.player.y
    inc eax
    invoke  isMoveable,game.player.x,eax
    test    eax,eax
    jnz  canMoveRight_pollingPlayer
    mov game.player.frac_y,FRAC_RANGE-1
    jmp exitInputSwitch_pollingPlayer
canMoveRight_pollingPlayer:
    inc game.player.y
    mov eax,game.player.frac_y
    sub eax,2*FRAC_RANGE
    mov game.player.frac_y,eax
exitInputSwitch_pollingPlayer:
    invoke calcMapOffset, game.player.x, game.player.y, 0
    cmp game.map[eax*4 + 4]._type, MONSTER
    jne JmpOverMonster_pollingPlayer
    invoke die
    jmp ret_pollingPlayer
JmpOverMonster_pollingPlayer:
    cmp game.boss.in_map,0
    je  skipBoss_pollingPlayer
    mov edx,game.player.x
    sub edx,game.boss.x
    cmp edx,-1
    jl  skipBoss_pollingPlayer
    cmp edx,1
    jg  skipBoss_pollingPlayer
    mov edx,game.player.y
    sub edx,game.boss.y
    cmp edx,-1
    jl  skipBoss_pollingPlayer
    cmp edx,1
    jg  skipBoss_pollingPlayer
    invoke  die
    jmp ret_pollingPlayer
skipBoss_pollingPlayer:
    cmp game.map[eax*4]._type, TOOL
    jne JmpOverTool_pollingPlayer
    push eax
    invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset PICK_AUDIO
    invoke mciSendString,addr audioCmd,0,0,0
    pop eax
    movzx   ecx,game.map[eax*4].id
    sal ecx, 4  ;tool_index *= sizeof(tool)   考虑万一改变sizeof Tool，这个地方要改
    mov edx,game.tools[ecx]._type
    jmp [TOOL_TYPE_JMP_TBL+edx*4]
addLife_pollingPlayer label dword
    cmp game.player.life,MAX_LIFE
    jge ToolSwEnd_pollingPlayer
    inc game.player.life
    jmp ToolSwEnd_pollingPlayer
addRange_pollingPlayer label dword
    cmp game.player.bomb_range,MAX_BOMB_RANGE
    jge  ToolSwEnd_pollingPlayer
    inc game.player.bomb_range
    jmp ToolSwEnd_pollingPlayer
addCnt_pollingPlayer label dword
    cmp game.player.bomb_cnt,MAX_BOMB_CNT
    jge ToolSwEnd_pollingPlayer
    inc game.player.bomb_cnt
    jmp ToolSwEnd_pollingPlayer
addSpeed_pollingPlayer label dword
    cmp game.player.speed,MAX_SPEED
    jge ToolSwEnd_pollingPlayer
    inc game.player.speed
    jmp ToolSwEnd_pollingPlayer
addTime_pollingPlayer label dword
    add game.timer,20*FRAMES_PER_SEC
ToolSwEnd_pollingPlayer:
    mov game.map[eax*4]._type, EMPTY
    mov game.tools[ecx].timer, 0
JmpOverTool_pollingPlayer:
    mov game.map[eax*4+4]._type,PLAYER
ret_pollingPlayer:
	ret
pollingPlayer	endp

isMoveable  proc    x:dword, y:dword
    invoke calcMapOffset, x, y, 0
    cmp game.map[eax*4]._type,BOMB
    je ret_0_isMoveable
    cmp game.map[eax*4+4]._type,BOX
    je ret_0_isMoveable
    cmp game.map[eax*4+4]._type,WALL
    je ret_0_isMoveable
    mov eax,1   ; none of above,ret 1
    ret
ret_0_isMoveable:
    xor eax,eax
    ret
isMoveable  endp

isMoveableMonster   proc    x:dword, y:dword
    invoke isMoveable, x, y
    test    eax,eax
    jz ret_isMoveableMonster
    invoke calcMapOffset, x, y, 1
    cmp game.map[eax*4]._type,MONSTER
    mov eax,0
    je ret_isMoveableMonster
    inc eax ; none of above,ret 1
ret_isMoveableMonster:
    ret
isMoveableMonster   endp

moveOneStep proc    x:dword, y:dword, direction:dword \
    , pnew_x:ptr dword, pnew_y:ptr dword, pfrac_x:ptr dword \
    , pfrac_y:ptr dword, speed:dword, _type:word
local ismove:dword,last_fx:dword,last_fy:dword,next_x:dword \
    ,next_y:dword,next_is_moveable:dword
mov ismove,0
push ebx
push esi
    mov esi,pfrac_x
    mov eax,[esi]
    mov last_fx,eax
    mov esi,pfrac_y
    mov eax,[esi]
    mov last_fy,eax
    mov eax,x
    mov next_x,eax
    mov eax,y
    mov next_y,eax
    mov edx, speed
    mov eax,direction
    mov esi,0
    jmp [MOVE_ONE_STEP_JMP_TBL+eax*4]
    direUp_moveOneStep  label   dword
    mov ecx,pfrac_x
    sub [ecx],edx
    mov ecx,pfrac_y
    mov [ecx],esi
    dec next_x
    jmp dirSwEnd_moveOneStep
    direDown_moveOneStep    label   dword
    mov ecx,pfrac_x
    add [ecx],edx
    mov ecx,pfrac_y
    mov [ecx],esi
    inc next_x
    jmp dirSwEnd_moveOneStep
    direLeft_moveOneStep    label   dword
    mov ecx,pfrac_y
    sub [ecx],edx
    mov ecx,pfrac_x
    mov [ecx],esi
    dec next_y
    jmp dirSwEnd_moveOneStep
    direRight_moveOneStep   label   dword
    mov ecx,pfrac_y
    add [ecx],edx
    mov ecx,pfrac_x
    mov [ecx],esi
    inc next_y
    dirSwEnd_moveOneStep:
    mov eax,1
    mov next_is_moveable,eax
    cmp _type,MONSTER
    je MonsterMoveable_moveOneStep
        invoke isMoveable,next_x,next_y
        cmp eax,0
        jne EndMoveable_moveOneStep
            mov eax,0
            mov next_is_moveable,eax
    jmp EndMoveable_moveOneStep
    MonsterMoveable_moveOneStep:
        invoke isMoveableMonster,next_x,next_y
        cmp eax,0
        jne EndMoveable_moveOneStep
            mov eax,0
            mov next_is_moveable,eax
    EndMoveable_moveOneStep:

    cmp _type,MONSTER
    je JOisnext_is_moveable_moveOneStep
    cmp next_is_moveable,1
    je JOnext_isnot_moveable_xyjmpone_moveOneStep
    JOisnext_is_moveable_moveOneStep:
        mov ecx,0
        mov ebx, 2*FRAC_RANGE   ;ebx = 2*FRAC_RANGE

        mov esi,pfrac_x
        cmp direction,UP
        jne elseif1_frac_moveOneStep
        cmp [esi],ecx
        jg elseif1_frac_moveOneStep
        cmp _type,PLAYER
        je elseif1_lastfrac_moveOneStep
            cmp last_fx,ecx
            jle elseif1_frac_moveOneStep
        elseif1_lastfrac_moveOneStep:
            mov ismove,2
            ;jmp ret_moveOneStep
            jmp else_frac_moveOneStep
        elseif1_frac_moveOneStep:
        cmp direction,DOWN
        jne elseif2_frac_moveOneStep
        cmp [esi],ecx
        jl elseif2_frac_moveOneStep
        cmp _type,PLAYER
        je elseif2_lastfrac_moveOneStep
            cmp last_fx,ecx
            jge elseif2_frac_moveOneStep
        elseif2_lastfrac_moveOneStep:
            mov ismove,2
            ;jmp ret_moveOneStep
            jmp else_frac_moveOneStep
        elseif2_frac_moveOneStep:
        mov esi,pfrac_y
        cmp direction,LEFT
        jne elseif3_frac_moveOneStep
        cmp [esi],ecx
        jg elseif3_frac_moveOneStep
        cmp _type,PLAYER
        je elseif3_lastfrac_moveOneStep
            cmp last_fy,ecx
            jle elseif3_frac_moveOneStep
        elseif3_lastfrac_moveOneStep:
            mov ismove,2
            ;jmp ret_moveOneStep
            jmp else_frac_moveOneStep
        elseif3_frac_moveOneStep:
        cmp direction,RIGHT
        jne else_frac_moveOneStep
        cmp [esi],ecx
        jl else_frac_moveOneStep
        cmp _type,PLAYER
        je else_lastfrac_moveOneStep
            cmp last_fy,ecx
            jge else_frac_moveOneStep
        else_lastfrac_moveOneStep:
            mov ismove,2
            ;jmp ret_moveOneStep
        else_frac_moveOneStep:
    JOnext_isnot_moveable_xyjmpone_moveOneStep:
    
    mov ebx, 2*FRAC_RANGE   ;ebx = 2*FRAC_RANGE
    mov ecx, pfrac_x
    cmp dword ptr [ecx],FRAC_RANGE
    jng JOxgreat_moveOneStep
        mov eax, x
        inc eax
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        mov edx, pnew_y
        mov [edx],eax
        mov edx, pfrac_x
        sub [edx], ebx
        mov ismove,1
        jmp fracOverSwEnd_moveOneStep
    JOxgreat_moveOneStep:
    cmp dword ptr [ecx], -FRAC_RANGE
    jnl JOxless_moveOneStep
        mov eax, x
        dec eax
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        mov edx, pnew_y
        mov [edx],eax
        mov edx, pfrac_x
        add [edx], ebx
        mov ismove,1

        jmp fracOverSwEnd_moveOneStep
    JOxless_moveOneStep:
    mov ecx, pfrac_y
    cmp dword ptr [ecx], FRAC_RANGE
    jng JOygreat_moveOneStep
        mov eax, x
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        inc eax
        mov edx, pnew_y
        mov [edx],eax
        mov edx, pfrac_y
        sub [edx], ebx
        mov ismove,1

        jmp fracOverSwEnd_moveOneStep
    JOygreat_moveOneStep:
    cmp dword ptr [ecx], -FRAC_RANGE
    jnl JOyless_moveOneStep
        mov eax, x
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        dec eax
        mov edx, pnew_y
        mov [edx],eax
        mov edx, pfrac_y
        add [edx], ebx
        mov ismove,1

        jmp fracOverSwEnd_moveOneStep
    JOyless_moveOneStep:
        mov eax, x
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        mov edx, pnew_y
        mov [edx],eax
        jmp ret_moveOneStep
    fracOverSwEnd_moveOneStep:
ret_moveOneStep:
mov eax, ismove
pop esi
pop ebx
    ret
moveOneStep endp





;int setInvisible(Game *this) {
;	if (this->player.status == NORMAL) {
;		this->player.status = INVISIBLE;
;		this->player.timer = INVISIBLE_TIMER;
;		return 1;
;	}
;	return 0;
;}

;setInvisible proc
	;xor	eax,eax
	;cmp	game.player.status,NORMAL
	;je l1_setInvisible
	;ret
;l1_setInvisible:
	;mov game.player.status,INVISIBLE
	;mov game.player.timer,INVISIBLE_TIMER
	;inc	eax
	;ret
;setInvisible endp


;void die(Game *this) {
;    if (this->player.status != INVISIBLE) {
;        this->player.life--;
;        if (this->player.life == 0) {
;            puts("Game Over!");
;            exit(0); // End the game
;        }
;        this->map[this->player.x][this->player.y][1]._tpye = EMPTY;
;        this->player.x = this->player.y = 1;
;        this->map[this->player.x][this->player.y][1]._tpye = PLAYER;
;        setInvisible(this, &this->player);
;        this->timer = this->level_timer;
;    }
;}

die proc
    local audioCmd[100]:byte
    invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset DIE_AUDIO
    invoke mciSendString,addr audioCmd,0,0,0
    cmp game.player.timer,0
    jg  end_die
	;cmp	game.player.status,INVISIBLE
	;je end_die
	dec	game.player.life
	cmp game.player.life,0
	je l1_die
	jmp l2_die
l1_die:
	;invoke crt_puts, offset GAMEOVER_STR
	;invoke crt_exit,0
	mov mainwinp.frames,0
    mov mainwinp.winState, winState_gameover
    
	invoke crt_sprintf ,addr audioCmd, offset STOP_SPRINTF,offset BGM_ONGAME_PATH
	invoke mciSendString ,addr audioCmd,NULL,0,NULL
	invoke crt_sprintf ,addr audioCmd, offset PLAY_REPEAT_SPRINTF,offset BGM_HOME_PATH
	invoke mciSendString ,addr audioCmd,NULL,0,NULL
l2_die:
	invoke calcMapOffset,game.player.x,game.player.y,1
	mov game.map[eax*4] ,EMPTY
	mov game.player.x,1
	mov game.player.y,1
    mov game.player.frac_x,0
    mov game.player.frac_y,0
	invoke calcMapOffset,game.player.x,game.player.y,1
	mov game.map[eax*4]._type ,PLAYER
    mov game.player.timer,INVISIBLE_TIMER
	mov eax,game.level_timer
	mov game.timer,eax
end_die:
	ret
die endp


;void calculateNextMove(int x, int y, int direction, int *new_x, int *new_y) {
;    switch (direction) {
;        case UP: *new_x = x - 1; *new_y = y; break; // Move up
;       case DOWN: *new_x = x + 1; *new_y = y; break; // Move down
;        case LEFT: *new_x = x; *new_y = y - 1; break; // Move left
;        case RIGHT: *new_x = x; *new_y = y + 1; break; // Move right
;    }
;}

calculateNextMove proc stdcall x:dword,y:dword,direction:dword,new_x:ptr dword,new_y:ptr dword
    mov eax,direction
    jmp [CALC_NEXT_MOVE_JMP_TBL+eax*4]
    direUp_calculateNextMove    label   dword
	mov ecx,x
	dec	ecx
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	mov	eax,new_y
	mov	[eax],ecx
    ret
    direDown_calculateNextMove    label   dword
	mov	ecx,x
	inc	ecx
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	mov	eax,new_y
	mov	[eax],ecx
	ret
    direLeft_calculateNextMove    label   dword
	mov	ecx,x
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	dec	ecx
	mov	eax,new_y
	mov	[eax],ecx
	ret
    direRight_calculateNextMove    label   dword
	mov	ecx,x
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	inc	ecx
	mov	eax,new_y
	mov	[eax],ecx
	ret
calculateNextMove endp


;getFromDriection proc direction:dword
;	cmp direction,UP
;	je up_getFromDriection
;	cmp direction,DOWN
;	je down_getFromDriection
;	cmp direction,LEFT
;	je left_getFromDriection
;	cmp direction,RIGHT
;	je right_getFromDriection
;	ret
;
;	up_getFromDriection:
;	mov eax,DOWN
;	ret
;	down_getFromDriection:
;	mov eax,UP
;	ret
;	left_getFromDriection:
;	mov eax,RIGHT
;	ret
;	right_getFromDriection:
;	mov eax,LEFT
;	ret
;	
;
;getFromDriection endp



pollingMonster	proc
	local newMonsterX,newMonsterY:DWORD,ismove:dword
	push ebx
    push    esi
    xor esi,esi
	outer_for_pollingMonster:
        mov eax,esi
		mov ebx,sizeof(Monster)
		mul ebx
        mov ebx,eax

		;if (this->monsters[i].valid)
		mov eax,game.monsters[ebx].valid
		cmp eax,0
		je MonsterNotValid_pollingMonster
			invoke moveOneStep,game.monsters[ebx].x,game.monsters[ebx].y \
							,game.monsters[ebx].direction,addr newMonsterX,addr newMonsterY \
							,addr game.monsters[ebx].frac_x ,addr game.monsters[ebx].frac_y\
							,game.monsters[ebx].speed, MONSTER
            mov ismove,eax
			cmp ismove,1
			jne notMoveCell_pollingMonster
                    mov eax,game.player.x
		            cmp eax,newMonsterX
		            jne end_inner2_if_pollingMonster
		            mov eax,game.player.y
		            cmp eax,newMonsterY
		            jne end_inner2_if_pollingMonster
		            invoke die
		            end_inner2_if_pollingMonster:

		            invoke calcMapOffset,game.monsters[ebx].x,game.monsters[ebx].y,1

		            mov game.map[eax*4]._type,EMPTY
		            mov eax,newMonsterX
		            mov game.monsters[ebx].x,eax
		            mov eax,newMonsterY
		            mov game.monsters[ebx].y,eax
		            invoke calcMapOffset,newMonsterX,newMonsterY,1
					
		            mov game.map[eax*4]._type,MONSTER
		            mov game.map[eax*4].id,si
                jmp MonsterNotValid_pollingMonster

            notMoveCell_pollingMonster:
            cmp ismove,2
            jne MonsterNotValid_pollingMonster
	            invoke changeDirection,esi
	            mov game.monsters[ebx].direction,eax
		MonsterNotValid_pollingMonster:
	inc esi
	cmp esi,MAX_MONSTER
	jl outer_for_pollingMonster
    pop esi
	pop ebx
	ret
pollingMonster endp
	


movMonsterToNextCell proc index:dword
    ;ebx: monsteroffset
	local direct_able,monster_from:DWORD
	local newX,newY:DWORD
	local before_x,before_y:DWORD
	local move,newMonsterX,newMonsterY:DWORD
	push ebx
	push esi
	mov eax,index
	mov ebx,sizeof(Monster)
	mul ebx
    mov ebx,eax

	mov direct_able,0
	mov monster_from,0

	mov eax,game.monsters[ebx].direction
    mov eax,[FROM_DIRECTION_TBL+eax*4]
	mov monster_from,eax
    xor esi,esi
	inner_for_movMonsterToNextCell:
		mov eax,game.monsters[ebx].x
		mov newX,eax
		mov eax,game.monsters[ebx].y
		mov newY,eax
        jmp [MOV_MONSTER_TO_NEXT_CELL_JMP_TBL+esi*4]
up1_switch_movMonsterToNextCell label   dword
        dec newX
        jmp end_switch1_movMonsterToNextCell
down1_switch_movMonsterToNextCell   label   dword
        inc newX
        jmp end_switch1_movMonsterToNextCell
left1_switch_movMonsterToNextCell   label   dword
        dec newY
        jmp end_switch1_movMonsterToNextCell
right1_switch_movMonsterToNextCell   label   dword
		inc newY
		end_switch1_movMonsterToNextCell:

		;if (isMoveableMonster(this, newX, newY) && monster_from != j)
        cmp monster_from,esi
		je	endif_isMoveableMonster_monster_from_movMonsterToNextCell
		invoke isMoveableMonster,newX,newY
		cmp eax,0
		je endif_isMoveableMonster_monster_from_movMonsterToNextCell
		inc direct_able

		endif_isMoveableMonster_monster_from_movMonsterToNextCell:			
				
	inc esi
	cmp esi,4
	jl inner_for_movMonsterToNextCell
				
				
	;get last step from monster from
	get_last_step:
	invoke calculateNextMove,game.monsters[ebx].x,game.monsters[ebx].y,monster_from,addr before_x,addr before_y
	cmp direct_able,2
	jl endif_is_corner_movMonsterToNextCell
	invoke isMoveableMonster,before_x,before_y
	cmp eax,0
	je endif_is_corner_movMonsterToNextCell
	invoke changeDirection,index

				
	mov game.monsters[ebx].direction,eax
	endif_is_corner_movMonsterToNextCell:

	mov eax,game.monsters[ebx].direction
	mov move,eax
	mov eax,game.monsters[ebx].x
	mov newMonsterX,eax
	mov eax,game.monsters[ebx].y
	mov newMonsterY,eax
	invoke calculateNextMove,game.monsters[ebx].x,game.monsters[ebx].y,move,addr newMonsterX,addr newMonsterY
	;check if new position is valid
	invoke isMoveableMonster,newMonsterX,newMonsterY
	cmp	eax,0
	je middle_new_pos_not_valid_movMonsterToNextCell
		mov eax,game.player.x
		cmp eax,newMonsterX
		jne end_inner2_if_movMonsterToNextCell
		mov eax,game.player.y
		cmp eax,newMonsterY
		jne end_inner2_if_movMonsterToNextCell
		invoke die
		end_inner2_if_movMonsterToNextCell:

		invoke calcMapOffset,game.monsters[ebx].x,
			game.monsters[ebx].y,1

		mov game.map[eax*4]._type,EMPTY
		mov eax,newMonsterX
		mov game.monsters[ebx].x,eax
		mov eax,newMonsterY
		mov game.monsters[ebx].y,eax
		invoke calcMapOffset,newMonsterX,newMonsterY,1
					
		mov game.map[eax*4]._type,MONSTER
		mov esi,index
		mov game.map[eax*4].id,si

		jmp end_new_pos_not_valid_movMonsterToNextCell
	middle_new_pos_not_valid_movMonsterToNextCell:
	invoke changeDirection,index
				
	mov game.monsters[ebx].direction,eax
	end_new_pos_not_valid_movMonsterToNextCell:
	pop esi
	pop ebx
	ret
movMonsterToNextCell endp


changeDirection	proc	index:dword
	local	direction[4]:dword,monster_from:dword,newX:dword,newY:dword
	local	new_direction:dword,available_direction:dword
	push	ebx;monsteroffset
	push	esi
	mov	eax,index
	mov	edx,sizeof Monster
	mul	edx
	mov	ebx,eax
	mov	direction[0],1
	mov	direction[4],1
	mov	direction[8],1
	mov	direction[12],1
    mov eax,game.monsters[ebx].direction
    mov eax,[FROM_DIRECTION_TBL+eax*4]
	mov	monster_from,eax
	mov	direction[eax*4],0
    xor esi,esi
	loop1:
		mov eax,game.monsters[ebx].x
		mov	newX,eax
		mov eax,game.monsters[ebx].y
		mov newY,eax
		invoke calculateNextMove,game.monsters[ebx].x,game.monsters[ebx].y,esi,addr newX,addr newY
		invoke isMoveableMonster,newX,newY
		test eax,eax
		jnz not_movable_direction
			mov	direction[esi*4],0
		not_movable_direction:
    inc esi
	cmp esi,4
	jl loop1
	;chose the available direction randomly
	mov available_direction,0
	mov new_direction,0
    xor esi,esi
	loop2:
		cmp direction[esi*4],1
		jne count_avail_direction
			mov new_direction,esi
			inc available_direction
		count_avail_direction:
    inc esi
    cmp esi,4
	jl loop2

	cmp available_direction,0
	jne have_available_direction
		mov eax,monster_from
		jmp end_func
	have_available_direction:

	invoke crt_rand
	xor edx,edx
	mov ecx,16
	div ecx ;ramdom_direction in edx
	; for (int j = 0; j < random_direction; j++)
    xor esi,esi
	cmp edx,0
	je end_loop3
	loop3:
		inc new_direction
		and new_direction,3
		while_loop:
		mov eax,new_direction
		cmp direction[eax*4],1
		je find_next_direction
		inc new_direction
		and new_direction,3
		jmp while_loop
		find_next_direction:
	inc esi
	cmp esi,edx
	jl loop3
	end_loop3:
	mov eax,new_direction
	mov game.monsters[ebx].direction,eax
	end_func:
	pop	esi
	pop	ebx
	ret
changeDirection	endp



clearFire proc	x:dword,y:dword,id:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,EMPTY
	ret
clearFire ENDP

preAttack proc x:dword,y:dword,id:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,ATTACK
	ret
preAttack ENDP

makeAttack proc x:dword,y:dword,id:dword
	invoke calcMapOffset,x,y,1
    cmp game.map[eax*4]._type,PLAYER
    jne noKillPlayer_makeAttack
    push eax
    invoke die
    pop eax
noKillPlayer_makeAttack:
    mov game.map[eax*4+4]._type,EMPTY
    cmp game.map[eax*4]._type,BOSS
    je  noKillBomb_makeAttack
	mov game.map[eax*4]._type,BLUEFIRE
    mov edx,id
    mov game.map[eax*4].id,dx
    cmp game.map[eax*4-4]._type,BOMB
    jne noKillBomb_makeAttack
    mov game.map[eax*4-4]._type,EMPTY
    movzx eax,game.map[eax*4-4].id
    mov edx,sizeof(Bomb)
    mul edx
    mov game.bombs[eax].timer,FIRE_TIMER
    inc game.player.bomb_cnt
noKillBomb_makeAttack:
	ret
makeAttack ENDP

clearBlueFire proc x:dword,y:dword,id:dword
    invoke calcMapOffset,x,y,1
    cmp game.map[eax*4]._type,BLUEFIRE
    jne noBlueFire_clearBlueFire
    mov game.map[eax*4]._type,EMPTY
noBlueFire_clearBlueFire:
    ret
clearBlueFire endp

dealAttack  proc    x:dword,y:dword,id:dword,jobFunc:dword
    push    esi
    push    edi
    mov esi,x
    dec esi
outerLoop_dealAttack:
    mov eax,x
    inc eax
    cmp esi,eax
    jg  exitOuterLoop_dealAttack
    mov edi,y
    dec edi
innerLoop_dealAttack:
    mov eax,y
    inc eax
    cmp edi,eax
    jg  exitInnerLoop_dealAttack
    invoke  calcMapOffset,esi,edi,1
    cmp game.map[eax*4]._type,WALL
    je  noJob_dealAttack
    push    id
    push    edi
    push    esi
    call    jobFunc
noJob_dealAttack:
    inc edi
    jmp innerLoop_dealAttack
exitInnerLoop_dealAttack:
    inc esi
    jmp outerLoop_dealAttack
exitOuterLoop_dealAttack:
    pop edi
    pop esi
    ret
dealAttack  endp

pollingAttack proc
	push ebx
    push    esi
	xor ebx,ebx
    xor esi,esi
loop_pollingAttack:
	cmp ebx,MAX_ATTACK*sizeof(Attack)
	jge end_pollingAttack
	cmp game.attacks[ebx].timer,0
	jle noJob_pollingAttack
	dec game.attacks[ebx].timer
	cmp game.attacks[ebx].timer,ATTACK_TIME
	jle lessAttackTime_pollingAttack
	invoke dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,esi,offset preAttack
	jmp noJob_pollingAttack
lessAttackTime_pollingAttack:
	cmp game.attacks[ebx].timer,0
	je equalZeroTime_pollingAttack
	invoke dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,esi,offset makeAttack
	jmp noJob_pollingAttack
equalZeroTime_pollingAttack:
	invoke dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,esi,offset clearBlueFire
noJob_pollingAttack:
	add ebx,sizeof(Attack)
    inc esi
	jmp loop_pollingAttack
end_pollingAttack:
    pop esi
	pop ebx
	ret
pollingAttack ENDP

bossAttack proc
	xor ecx,ecx
loop_bossAttack:
	cmp ecx,MAX_ATTACK*sizeof(Attack)
	jge end_bossAttack
	cmp game.attacks[ecx].timer,0
	jg continue_bossAttack
	mov edx,game.player.x
	mov game.attacks[ecx].x,edx
	mov edx,game.player.y
	mov game.attacks[ecx].y,edx
	mov game.attacks[ecx].timer,PRE_ATTACK_TIME + ATTACK_TIME
	jmp end_bossAttack
continue_bossAttack:
	add ecx,sizeof(Attack)
	jmp loop_bossAttack
end_bossAttack:
	ret
bossAttack ENDP


pollingBoss proc
    local audioCmd[100]:byte   
	cmp game.boss.in_map,0
	je bossNotInMap_pollingBoss
	dec game.boss.cool_time
	cmp game.boss.cool_time,0
	je coolTimeEnd_pollingBoss
	ret
coolTimeEnd_pollingBoss:
	mov game.boss.in_map,0
	mov game.boss.sky_time,SKY_TIME
	mov eax,game.boss.x
	mov edx,game.boss.y
	invoke calcMapOffset,eax,edx,1
	mov game.map[4*eax]._type,EMPTY
    mov game.map[4*eax+4]._type,BOSS_FLY
	ret
bossNotInMap_pollingBoss:
	cmp game.boss.sky_time,0
	je bossWillDrop_pollingBoss
	sub game.boss.sky_time,1
	je skyTimeEnd_pollingBoss
    cmp game.boss.sky_time,TAKE_OFF_TIME
    jg takeoff_pollingBoss
    je takeOffEnd_pollingBoss
	xor edx,edx
	mov eax,game.boss.sky_time
	mov ecx,ATTACK_FREQ
	div ecx
	cmp edx,0
	je beginAttack_pollingBoss
	ret
takeoff_pollingBoss:
    invoke calcMapOffset,game.boss.x,game.boss.y,2
    mov game.map[4*eax],BOSS_FLY
    ret
takeOffEnd_pollingBoss:
    invoke calcMapOffset,game.boss.x,game.boss.y,2
    mov game.map[4*eax],EMPTY
    invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset DRAGON_ROAR_AUDIO
    invoke mciSendString,addr audioCmd,0,0,0
    ret
beginAttack_pollingBoss:
	invoke bossAttack
    ret
skyTimeEnd_pollingBoss:
	mov game.boss.pre_drop_time,PRE_DROP_TIME
	mov eax,game.player.x
    cmp eax,1
    jne noAddX
    inc eax
noAddX:
    cmp eax,ROW-1
    jne noSubX
    dec eax
noSubX:
	mov game.boss.x,eax
	mov eax,game.player.y
    cmp eax,1
    jne noAddY
    inc eax
noAddY:
    cmp eax,COL-1
    jne noSubY
    dec eax
noSubY:
	mov game.boss.y,eax
	ret
bossWillDrop_pollingBoss:
	cmp game.boss.pre_drop_time,0
	je end_pollingBoss
	sub game.boss.pre_drop_time,1
	je dropTimeEnd_pollingBoss
    invoke calcMapOffset,game.boss.x,game.boss.y,2
    mov game.map[4*eax]._type,BOSS_FLY
	ret
dropTimeEnd_pollingBoss:
    invoke dealAttack,game.boss.x,game.boss.y,0,offset clear
	invoke calcMapOffset,game.boss.x,game.boss.y,1
    mov game.map[eax*4]._type,BOSS 
	mov game.boss.in_map,1
	mov game.boss.cool_time,COOL_TIME
end_pollingBoss:
	ret
pollingBoss endp

initMonster	proc    index:dword,x:dword,y:dword,speed:dword
    mov eax,index
    mov edx,sizeof Monster
    mul edx
    mov edx,eax
    mov game.monsters[edx].direction,0
    mov eax,x
    mov game.monsters[edx].x,eax
    mov eax,y
    mov game.monsters[edx].y,eax
    mov game.monsters[edx].frac_x,0
    mov game.monsters[edx].frac_y,0
    mov eax,speed
    mov game.monsters[edx].speed,eax
    mov game.monsters[edx].valid,1
    ret
initMonster	endp

initBoss    proc    x:dword,y:dword
    invoke  calcMapOffset,x,y,1
    mov game.map[eax*4]._type,BOSS
    mov eax,x
    mov game.boss.x,eax
    mov eax,y
    mov game.boss.y,eax
    mov game.boss.cool_time,COOL_TIME
    mov game.boss.in_map,1
    mov game.boss.pre_drop_time,0
    mov game.boss.sky_time,0
    mov game.boss.life,BOSS_LIFE
    ret
initBoss    endp

initLevel   proc
    local   file:dword,num:dword,str1[20]:byte
    ;reset player's pos
    mov game.player.x,1
    mov game.player.y,1
    mov game.player.frac_x,0
    mov game.player.frac_y,0
    mov game.player.timer,0
    mov game.player.isMove,STILL
    mov game.player.direction,RIGHT
    invoke  crt_memset,offset game.map,0,ROW*COL*DEPTH*sizeof Object
    invoke  crt_sprintf,addr str1,offset LEVEL_FILENAME_FORMAT,game.level
    invoke  crt_fopen,addr str1,offset OPEN_FILE_READ_ONLY
    test    eax,eax
    jnz  fileFound_initLevel
    invoke  crt_exit,1
    ret
fileFound_initLevel:
    ;ebx：map数组下标，esi：i，edi：j
    push    ebx
    push    esi
    push    edi
    mov file,eax
    mov game.monster_num,0
    xor esi,esi
outerLoop_initLevel:
    cmp esi,ROW
    je  exitOuterLoop_initLevel
    xor edi,edi
innerLoop_initLevel:
    cmp edi,COL
    je  exitInnerLoop_initLevel
    invoke  crt_fscanf,file,offset ONE_INT_FORMAT,addr num
    invoke  calcMapOffset,esi,edi,1
    mov ebx,eax
    cmp num,MONSTER_1
    je  setMonster1_initLevel
    cmp num,MONSTER_2
    je  setMonster2_initLevel
    cmp num,MONSTER_3
    je  setMonster3_initLevel
    cmp num,BOSS
    je  setBoss_initLevel
    jmp setMap_initLevel
setMonster1_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[ebx*4].id,dx
    invoke  initMonster,game.monster_num,esi,edi,MONSTER_1_SPEED
    inc game.monster_num
    mov num,4
    jmp setMap_initLevel
setMonster2_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[ebx*4].id,dx
    invoke  initMonster,game.monster_num,esi,edi,MONSTER_2_SPEED
    inc game.monster_num
    mov num,4
    jmp setMap_initLevel
setMonster3_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[ebx*4].id,dx
    invoke  initMonster,game.monster_num,esi,edi,MONSTER_3_SPEED
    inc game.monster_num
    mov num,4
    jmp setMap_initLevel
setBoss_initLevel:
    invoke  initBoss,esi,edi
    mov game.monster_num,1
    jmp setMap_initLevel
setMap_initLevel:
    mov edx,num
    mov game.map[ebx*4]._type,dx
    inc edi
    jmp innerLoop_initLevel
exitInnerLoop_initLevel:
    inc esi
    jmp outerLoop_initLevel
exitOuterLoop_initLevel:
    invoke  crt_fscanf,file,offset ONE_INT_FORMAT,offset game.timer
    mov eax,game.timer
    mov edx,FRAMES_PER_SEC
    mul edx
    mov game.level_timer,eax
    mov game.timer,eax
    invoke  crt_fclose,file
    pop edi
    pop esi
    pop ebx
    ret
initLevel   endp

initGame    proc
    invoke  crt_memset,offset game,0,sizeof Game
    mov game.level,0
    mov game.player.bomb_range,2
    mov game.player.bomb_cnt,1
    mov game.player.life,2
    mov game.player.speed,PLAYER_1_SPEED
    invoke  initLevel
    ret
initGame    endp

pollingTool proc
    ;ebx：tools数组偏移量
    push    ebx
    xor ebx,ebx
loop_pollingTool:
    cmp ebx,MAX_TOOL*sizeof Tool
    je  exitLoop_pollingTool
    cmp game.tools[ebx].timer,0
    je  loopAdd_pollingTool
    dec game.tools[ebx].timer
    cmp game.tools[ebx].timer,0
    jne loopAdd_pollingTool
    invoke  calcMapOffset,game.tools[ebx].x,game.tools[ebx].y,0
    mov game.map[eax*4]._type,EMPTY
loopAdd_pollingTool:
    add ebx,sizeof Tool
    jmp loop_pollingTool
exitLoop_pollingTool:
    pop ebx
    ret
pollingTool endp

pollingBomb proc
    local audioCmd[100]:byte
    ;ebx：bombs数组偏移量
    push    ebx
    push    esi
    xor ebx,ebx
    xor esi,esi
loop_pollingBomb:
    cmp ebx,MAX_BOMB*sizeof Bomb
    je  exitLoop_pollingBomb
    cmp game.bombs[ebx].timer,0
    je  loopAdd_pollingBomb
    dec game.bombs[ebx].timer
    cmp game.bombs[ebx].timer,FIRE_TIMER
    jg  loopAdd_pollingBomb
    je  explode_pollingBomb
    cmp game.bombs[ebx].timer,0
    jg  setFire_pollingBomb
    je  clearFire_pollingBomb
    jmp loopAdd_pollingBomb
explode_pollingBomb:
    invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset BOMB_AUDIO
    invoke mciSendString,addr audioCmd,0,0,0
    invoke  calcMapOffset,game.bombs[ebx].x,game.bombs[ebx].y,0
    mov game.map[eax*4]._type,EMPTY
    invoke  dealBomb,game.bombs[ebx].x,game.bombs[ebx].y,esi,game.bombs[ebx].range,offset explode
    inc game.player.bomb_cnt
    jmp loopAdd_pollingBomb
setFire_pollingBomb:
    invoke  dealBomb,game.bombs[ebx].x,game.bombs[ebx].y,esi,game.bombs[ebx].range,offset setFire
    jmp loopAdd_pollingBomb
clearFire_pollingBomb:
    invoke  dealBomb,game.bombs[ebx].x,game.bombs[ebx].y,esi,game.bombs[ebx].range,offset clearFire
loopAdd_pollingBomb:
    add ebx,sizeof Bomb
    inc esi
    jmp loop_pollingBomb
exitLoop_pollingBomb:
    pop esi
    pop ebx
    ret
pollingBomb endp

pollingSuccess  proc
    local audioCmd[100]:byte
    cmp game.monster_num,0
    jne exit_pollingSuccess
        
    invoke crt_sprintf,addr audioCmd,addr PLAY_SPRINTF,addr LEVEL_UP_AUDIO
    invoke mciSendString,addr audioCmd, NULL,0,NULL
    ;invoke  crt_puts,offset WIN_STR
    invoke readQuestion,offset levelup_question\
    ,offset levelup_choice1,offset levelup_choice2\
    ,offset levelup_choice3,offset levelup_choice4
    mov mainwinp.levelup_answer,eax
    mov mainwinp.winState, winState_levelup
exit_pollingSuccess:
    ret
pollingSuccess  endp

dealBomb    proc    x:dword,y:dword,id:dword,range:dword,_job:dword
    ;ebx：循环变量，esi：循环界
    push    ebx
    push    esi
    push    id ;id
    push    y
    push    x
    call    _job
    mov ebx,x
    inc ebx
    mov esi,x
    add esi,range
loop1_dealBomb:
    cmp ebx,esi
    jg  exitLoop1_dealBomb
    invoke  isDestroyable,ebx,y
    test    eax,eax
    jz  exitLoop1_dealBomb
    push    id
    push    y
    push    ebx
    call    _job
    inc ebx
    jmp loop1_dealBomb
exitLoop1_dealBomb:
    mov ebx,x
    dec ebx
    mov esi,x
    sub esi,range
loop2_dealBomb:
    cmp ebx,esi
    jl  exitLoop2_dealBomb
    invoke  isDestroyable,ebx,y
    test    eax,eax
    jz  exitLoop2_dealBomb
    push    id
    push    y
    push    ebx
    call    _job
    dec ebx
    jmp loop2_dealBomb
exitLoop2_dealBomb:
    mov ebx,y
    inc ebx
    mov esi,y
    add esi,range
loop3_dealBomb:
    cmp ebx,esi
    jg  exitLoop3_dealBomb
    invoke  isDestroyable,x,ebx
    test    eax,eax
    jz  exitLoop3_dealBomb
    push    id
    push    ebx
    push    x
    call    _job
    inc ebx
    jmp loop3_dealBomb
exitLoop3_dealBomb:
    mov ebx,y
    dec ebx
    mov esi,y
    sub esi,range
loop4_dealBomb:
    cmp ebx,esi
    jl  exitLoop4_dealBomb
    invoke  isDestroyable,x,ebx
    test    eax,eax
    jz  exitLoop4_dealBomb
    push    id
    push    ebx
    push    x
    call    _job
    dec ebx
    jmp loop4_dealBomb
exitLoop4_dealBomb:
    pop esi
    pop ebx
    ret
dealBomb    endp

isDestroyable   proc    x:dword,y:dword
    invoke  calcMapOffset,x,y,1
    cmp game.map[4*eax]._type,WALL
    je  retZero_isDestroyable
    dec eax
    cmp game.map[4*eax]._type,BOMB
    je  retZero_isDestroyable
    mov eax,1
    ret
retZero_isDestroyable:
    xor eax,eax
    ret
isDestroyable   endp

explode proc    x:dword,y:dword,id:dword
    invoke  calcMapOffset,x,y,2
    mov game.map[eax*4]._type,FIRE
    mov edx,id
    mov game.map[eax*4].id,dx
    invoke  clear,x,y
    ret
explode endp

setFire proc    x:dword,y:dword,id:dword
    invoke  calcMapOffset,x,y,2
    mov game.map[eax*4]._type,FIRE
    mov edx,id
    mov game.map[eax*4].id,dx
    ret
setFire endp

clear   proc    x:dword,y:dword
    local audioCmd[100]:byte   
    invoke  calcMapOffset,x,y,1
    cmp game.map[eax*4]._type,MONSTER
    je  monster_clear
    cmp game.map[eax*4]._type,PLAYER
    je  player_clear
    cmp game.map[eax*4]._type,BOX
    je  box_clear
    cmp game.map[eax*4]._type,BOSS
    je  boss_clear
    invoke calcMapOffset,x,y,0
    cmp game.map[eax*4]._type,TOOL
    je tool_clear
exit_clear:
    ret
monster_clear:
    mov game.map[eax*4]._type,EMPTY
    movzx   eax,game.map[eax*4].id
    mov edx,sizeof Monster
    mul edx
    mov game.monsters[eax].valid,0
    dec game.monster_num
    jmp exit_clear
player_clear:
    invoke  die
    jmp exit_clear
box_clear:
    mov game.map[eax*4]._type,EMPTY
    invoke  crt_rand
    xor edx,edx
    mov ecx,TOOL_CHANCE_RATE
    div ecx
    cmp edx,1
    jne exit_clear
    invoke  placeTool,x,y
    jmp exit_clear
tool_clear:
    mov game.map[eax*4]._type,EMPTY
    movzx eax,game.map[eax*4].id
    mov edx,sizeof Tool
    mul edx
    mov game.tools[eax].timer,0
    jmp exit_clear
boss_clear:
    invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset DRAGON_HURT_AUDIO
    invoke mciSendString,addr audioCmd,0,0,0
    dec game.boss.life
    cmp game.boss.life,0
    jne exit_clear
    ;invoke  crt_puts,offset WIN_STR
    ;invoke  crt_exit,0
	mov mainwinp.frames,0
    mov mainwinp.winState, winState_segerr
    jmp exit_clear
clear   endp

placeTool   proc    x:dword,y:dword
    ;ebx：tools数组偏移量
    push    ebx
    xor ebx,ebx
loop_placeTool:
    cmp ebx,MAX_TOOL*sizeof Tool
    je  exitLoop_placeTool
    cmp game.tools[ebx].timer,0
    jne loopAdd_placeTool
    mov eax,x
    mov game.tools[ebx].x,eax
    mov eax,y
    mov game.tools[ebx].y,eax
    invoke  crt_rand
    xor edx,edx
    mov ecx,5
    div ecx
    mov game.tools[ebx]._type,edx
    mov game.tools[ebx].timer,TOOL_TIMER
    mov eax,ebx
    xor edx,edx
    mov ecx,sizeof Tool
    div ecx
    ;ebx：tool id
    mov ebx,eax
    invoke  calcMapOffset,x,y,0
    mov game.map[eax*4]._type,TOOL
    mov game.map[eax*4].id,bx
    pop ebx
    mov eax,1
    ret
loopAdd_placeTool:
    add ebx,sizeof Tool
    jmp loop_placeTool
exitLoop_placeTool:
    pop ebx
    xor eax,eax
    ret
placeTool   endp

archive proc
    local   file:ptr FILE
    invoke  crt_fopen,offset FILENAMESAVE,offset OPEN_BFILE_WRITE_ONLY
    mov file,eax
    invoke  crt_fwrite,offset game,sizeof Game,1,eax
    invoke  crt_fclose,file
    ret
archive endp

load    proc
    local   file:ptr FILE
    invoke  crt_fopen,offset FILENAMESAVE,offset OPEN_BFILE_READ_ONLY
    mov file,eax
    invoke  crt_fread,offset game,sizeof Game,1,eax
    invoke  crt_fclose,file
    ret
load    endp


gameLoop proc   input:dword
    cmp input,4
    jg other_gameLoop
    invoke  pollingPlayer,input
other_gameLoop:
    invoke  pollingAttack
    invoke  pollingMonster
    invoke  pollingBoss
    invoke  pollingBomb
    invoke  pollingTool
    invoke  pollingSuccess
	dec	game.timer
    jne timeNotEqu0_gameLoop
    mov eax,game.level_timer
    mov game.timer,eax
    invoke  die
timeNotEqu0_gameLoop:
	ret
gameLoop endp

end
