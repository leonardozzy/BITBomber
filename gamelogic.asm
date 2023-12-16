.486
.model	flat,stdcall
option	casemap:none

include	common.inc
extern  game:Game

.const
FILENAME1	byte	"./level/1.level",0
FILENAME2	byte	"./level/2.level",0
FILENAME3	byte	"./level/3.level",0
FILENAME4	byte	"./level/4.level",0
OPEN_FILE_READ_ONLY	byte	"r",0
OPEN_BFILE_READ_ONLY	byte	"rb",0
OPEN_BFILE_WRITE_ONLY	byte	"wb",0
ONE_INT_FORMAT	byte	"%d",0
WIN_STR	byte	"You Win!",0
GAMEOVER_STR	byte "Game Over!",0
;四字节对齐，提升读取效率
align  4
LEVEL_FILE_NAMES	dword	offset FILENAME1,offset FILENAME2,offset FILENAME3,offset FILENAME4
TOOL_TYPE_JMP_TBL   dword   offset addLife_pollingPlayer,offset addRange_pollingPlayer,offset addCnt_pollingPlayer,offset addSpeed_pollingPlayer,offset addTime_pollingPlayer
MOVE_ONE_STEP_JMP_TBL   dword   offset direUp_moveOneStep,offset direDown_moveOneStep,offset direLeft_moveOneStep,offset direRight_moveOneStep
CALC_NEXT_MOVE_JMP_TBL  dword   offset direUp_calculateNextMove,offset direDown_calculateNextMove,offset direLeft_calculateNextMove,offset direRight_calculateNextMove
POLL_MONSTER_JMP_TBL    dword   offset direUp_pollingMonster,offset direDown_pollingMonster,offset direLeft_pollingMonster,offset direRight_pollingMonster

.code
placeBomb	proc	
    cmp game.player.bomb_cnt,0
    jng ret_placeBomb
    invoke calcMapOffset,game.player.x,game.player.y,0
    cmp game.map[4*eax]._type,EMPTY
    jne ret_placeBomb
    ;;;if (this->player.bomb_cnt > 0 && this->map[this->player.x][this->player.y][0].type==EMPTY) {
    ; Find an empty slot for a new bomb
    xor ecx,ecx
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
            dec game.player.bomb_cnt
            jmp ret_placeBomb
        ALLBOMB_LOOPEND_placeBomb:
        add ecx, sizeof Bomb ;add sizeof(Bomb) per loop
        cmp ecx, MAX_BOMB*sizeof Bomb
        jb ALLBOMB_LOOP_placeBomb
ret_placeBomb:
	ret
placeBomb	endp

pollingPlayer	proc	input:dword
	local	newPlayerX:dword, newPlayerY:dword
    cmp input, SETBOMB
    jne JmpOver_placeBomb_pollingPlayer
        invoke placeBomb
        jmp ret_pollingPlayer   ; Early return as no movement is required
    JmpOver_placeBomb_pollingPlayer:
    ; deal with player status
    cmp game.player.status,INVISIBLE
    jne JmpOverINVISIBLE_pollingPlayer
        dec game.player.timer
        cmp game.player.timer,0
        jne JmpOverINVISIBLE_pollingPlayer
            mov game.player.status, NORMAL
    JmpOverINVISIBLE_pollingPlayer:
    ; Move player
    mov eax, game.player.x
    mov newPlayerX, eax
    mov eax, game.player.y
    mov newPlayerY, eax
    invoke moveOneStep, game.player.x, game.player.y, input \
        , addr newPlayerX, addr newPlayerY \
        , offset game.player.frac_x, offset game.player.frac_y, game.player.speed
    ; Check if new position is valid
    invoke isMoveable, newPlayerX, newPlayerY
    test    eax,eax
    jz JmpOver_isMoveable_pollingPlayer
        ; Check for collision with monsters
        invoke calcMapOffset, newPlayerX, newPlayerY, 0
        cmp game.map[eax*4 + 4]._type, MONSTER
        jne JmpOverMonster_pollingPlayer
            invoke die
            jmp ret_pollingPlayer
        JmpOverMonster_pollingPlayer:
        cmp game.map[eax*4]._type, TOOL
        jne JmpOverTool_pollingPlayer
            movzx   ecx,game.map[eax*4].id
            sal ecx, 4  ;tool_index *= sizeof(tool)   考虑万一改变sizeof Tool
            mov edx,game.tools[ecx]._type
            jmp [TOOL_TYPE_JMP_TBL+edx*4]
            addLife_pollingPlayer label dword
            inc game.player.life
            jmp ToolSwEnd_pollingPlayer
            addRange_pollingPlayer label dword
            inc game.player.bomb_range
            jmp ToolSwEnd_pollingPlayer
            addCnt_pollingPlayer label dword
            inc game.player.bomb_cnt
            jmp ToolSwEnd_pollingPlayer
            addSpeed_pollingPlayer label dword
            inc game.player.speed
            jmp ToolSwEnd_pollingPlayer
            addTime_pollingPlayer label dword
            add game.timer,30
            ToolSwEnd_pollingPlayer:
            mov game.map[eax*4]._type, EMPTY
            mov game.tools[ecx].timer, 0
        JmpOverTool_pollingPlayer:
        ; Update the player's position on the map
        invoke calcMapOffset, game.player.x, game.player.y, 1
        mov game.map[eax*4], EMPTY
        mov edx, newPlayerX
        mov game.player.x, edx
        mov edx, newPlayerY
        mov game.player.y, edx
        invoke calcMapOffset, game.player.x, game.player.y, 1   ;刚刚更新完，还需要访问
        mov game.map[eax*4], PLAYER
    JmpOver_isMoveable_pollingPlayer:
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
    jmp ret_isMoveable
ret_0_isMoveable:
    xor eax,eax
ret_isMoveable:
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
    , pfrac_y:ptr dword, speed:dword
push ebx
    mov edx, speed
    mov eax,direction
    jmp [MOVE_ONE_STEP_JMP_TBL+eax*4]
    direUp_moveOneStep  label   dword
    mov ecx,pfrac_x
    sub [ecx],edx
    jmp dirSwEnd_moveOneStep
    direDown_moveOneStep    label   dword
    mov ecx,pfrac_x
    add [ecx],edx
    jmp dirSwEnd_moveOneStep
    direLeft_moveOneStep    label   dword
    mov ecx,pfrac_y
    sub [ecx],edx
    jmp dirSwEnd_moveOneStep
    direRight_moveOneStep   label   dword
    mov ecx,pfrac_y
    add [ecx],edx
    dirSwEnd_moveOneStep:
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
pop ebx
    ret
moveOneStep endp


readKey Proc
    invoke GetAsyncKeyState,'B'
    .if eax & 0001H
		mov eax,SETBOMB
        ret
    .endif
    invoke GetAsyncKeyState,'W'
    .if eax & 0001H
		mov eax,UP
        ret
    .endif
    invoke GetAsyncKeyState,'S'
    .if eax & 0001H
		mov eax,DOWN
        ret
    .endif
    invoke GetAsyncKeyState,'A'
    .if eax & 0001H
		mov eax,LEFT
        ret
    .endif
    invoke GetAsyncKeyState,'D'
    .if eax & 0001H
		mov eax,RIGHT
        ret
    .endif
    mov eax,-1
    ret
readKey endp

setInvisible proc
	xor	eax,eax
	cmp	game.player.status,NORMAL
	je l1_setInvisible
	ret
l1_setInvisible:
	mov game.player.status,INVISIBLE
	mov game.player.timer,INVISIBLE_TIMER
	inc	eax
	ret
setInvisible endp

die proc
	cmp	game.player.status,INVISIBLE
	je end_die
	dec	game.player.life
	cmp game.player.life,0
	je l1_die
	jmp l2_die
l1_die:
	invoke crt_puts, offset GAMEOVER_STR
	invoke crt_exit,0
l2_die:
	invoke calcMapOffset,game.player.x,game.player.y,1
	mov game.map[eax*4] ,EMPTY
	mov game.player.x,1
	mov game.player.y,1
	invoke calcMapOffset,game.player.x,game.player.y,1
	mov game.map[eax*4]._type ,PLAYER
	invoke setInvisible
	mov eax,game.level_timer
	mov game.timer,eax
end_die:
	ret
die endp

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

pollingMonster	proc
	local	direct_able:dword,monster_from:dword,before_x:dword,before_y:dword
	local	move:dword,newMonsterX:dword,newMonsterY:dword
	push	ebx
	push	esi
	xor	ebx,ebx
loop_pollingMonster:
	cmp	ebx,MAX_MONSTER*sizeof Monster
	je	exitLoop_pollingMonster
	cmp	game.monsters[ebx].valid,0
	je	loopAdd_pollingMonster
	mov	eax,ebx
	xor	edx,edx
	mov	ecx,sizeof Monster
	div	ecx
	mov	esi,eax
	mov	direct_able,0
    mov eax,game.monsters[ebx].direction
    jmp [POLL_MONSTER_JMP_TBL+eax*4]
    direUp_pollingMonster   label   dword
    mov monster_from,DOWN
    jmp	exitSwitch1_pollingMonster
    direDown_pollingMonster   label   dword
    mov monster_from,UP
    jmp	exitSwitch1_pollingMonster
    direLeft_pollingMonster   label   dword
    mov monster_from,RIGHT
    jmp	exitSwitch1_pollingMonster
    direRight_pollingMonster   label   dword
    mov monster_from,LEFT
exitSwitch1_pollingMonster:
	mov	eax,game.monsters[ebx].x
	dec	eax
	invoke	isMoveableMonster,eax,game.monsters[ebx].y
	test	eax,eax
	jz	judgeDirectAble2_pollingMonster
	cmp	monster_from,UP
	je	judgeDirectAble2_pollingMonster
	inc	direct_able
judgeDirectAble2_pollingMonster:
	mov	eax,game.monsters[ebx].x
	inc	eax
	invoke	isMoveableMonster,eax,game.monsters[ebx].y
	test	eax,eax
	jz	judgeDirectAble3_pollingMonster
	cmp	monster_from,DOWN
	je	judgeDirectAble3_pollingMonster
	inc	direct_able
judgeDirectAble3_pollingMonster:
	mov	eax,game.monsters[ebx].y
	dec	eax
	invoke	isMoveableMonster,game.monsters[ebx].x,eax
	test	eax,eax
	jz	judgeDirectAble4_pollingMonster
	cmp	monster_from,LEFT
	je	judgeDirectAble4_pollingMonster
	inc	direct_able
judgeDirectAble4_pollingMonster:
	mov	eax,game.monsters[ebx].y
	inc	eax
	invoke	isMoveableMonster,game.monsters[ebx].x,eax
	test	eax,eax
	jz	endJudgeDirectAble_pollingMonster
	cmp	monster_from,RIGHT
	je	endJudgeDirectAble_pollingMonster
	inc	direct_able
endJudgeDirectAble_pollingMonster:
	invoke	calculateNextMove,game.monsters[ebx].x,game.monsters[ebx].y,monster_from,addr before_x,addr before_y
	cmp	direct_able,2
	jl	endChangeDire_pollingMonster
	invoke	isMoveableMonster,before_x,before_y
	test	eax,eax
	jz	endChangeDire_pollingMonster
	invoke	changeDirection,esi
	mov	game.monsters[ebx].direction,eax
endChangeDire_pollingMonster:
	mov	eax,game.monsters[ebx].direction
	mov	move,eax
	lea	eax,game.monsters[ebx].frac_x
	lea	edx,game.monsters[ebx].frac_y
	invoke	moveOneStep,game.monsters[ebx].x,game.monsters[ebx].y,move,addr newMonsterX,addr newMonsterY,eax,edx,game.monsters[ebx].speed
	invoke	isMoveableMonster,newMonsterX,newMonsterY
	test	eax,eax
	jz	finalChangeDire_pollingMonster
	mov	eax,newMonsterX
	cmp	eax,game.player.x
	jne	exitPlayerDie_pollingMonster
	mov	eax,newMonsterY
	cmp	eax,game.player.y
	jne	exitPlayerDie_pollingMonster
	invoke	die
exitPlayerDie_pollingMonster:
	invoke	calcMapOffset,game.monsters[ebx].x,game.monsters[ebx].y,1
	mov	game.map[eax*4]._type,EMPTY
	mov	eax,newMonsterX
	mov	game.monsters[ebx].x,eax
	mov	eax,newMonsterY
	mov	game.monsters[ebx].y,eax
	invoke	calcMapOffset,newMonsterX,newMonsterY,1
	mov	game.map[eax*4]._type,MONSTER
	mov	game.map[eax*4].id,si
	jmp	loopAdd_pollingMonster
finalChangeDire_pollingMonster:
	invoke	changeDirection,esi
	mov	game.monsters[ebx].direction,eax
loopAdd_pollingMonster:
	add	ebx,sizeof Monster
	jmp	loop_pollingMonster
exitLoop_pollingMonster:
	pop	esi
	pop	ebx
	ret
pollingMonster	endp
	
changeDirection	proc	index:dword
	local	direction[4]:dword,monster_from:dword,newX:dword,newY:dword
	local	new_direction:dword,available_direction:dword,random_direction:dword
	push	ebx
	push	esi
	mov	eax,index
	mov	edx,sizeof Monster
	mul	edx
	mov	ebx,eax
	mov	direction[0],1
	mov	direction[4],1
	mov	direction[8],1
	mov	direction[12],1
	mov	monster_from,0
	cmp	game.monsters[ebx].direction,UP
	je	monsterUp_changeDirection
	cmp	game.monsters[ebx].direction,DOWN
	je	monsterDown_changeDirection
	cmp	game.monsters[ebx].direction,LEFT
	je	monsterLeft_changeDirection
	mov	monster_from,LEFT
	jmp	exitSwitch1_changeDirection
monsterUp_changeDirection:
	mov	monster_from,DOWN
	jmp	exitSwitch1_changeDirection
monsterDown_changeDirection:
	mov	monster_from,UP
	jmp	exitSwitch1_changeDirection
monsterLeft_changeDirection:
	mov	monster_from,RIGHT
exitSwitch1_changeDirection:
	mov	eax,monster_from
	mov	direction[eax*4],0
	xor	esi,esi
loop1_changeDirection:
	cmp	esi,4
	je	exitLoop1_changeDirection
	invoke	calculateNextMove,game.monsters[ebx].x,game.monsters[ebx].y,esi,addr newX,addr newY
	invoke	isMoveableMonster,newX,newY
	test	eax,eax
	jnz	canMove_changeDirection
	mov	direction[esi*4],0
canMove_changeDirection:
	inc	esi
	jmp	loop1_changeDirection
exitLoop1_changeDirection:
	mov	new_direction,0
	mov	available_direction,0
	xor	esi,esi
loop2_changeDirection:
	cmp	esi,4
	je	exitLoop2_changeDirection
	cmp	direction[esi*4],0
	je	loop2Add_changeDirection
	mov	new_direction,esi
	inc	available_direction
loop2Add_changeDirection:
	inc	esi
	jmp	loop2_changeDirection
exitLoop2_changeDirection:
	cmp	available_direction,0
	je	noAvailable_changeDirection
	invoke	crt_rand
	xor	edx,edx
	mov	ecx,10
	div	ecx
	mov	random_direction,edx
	xor	esi,esi
loop3_changeDirection:
	cmp	esi,random_direction
	je	exitLoop3_changeDirection
	inc	new_direction
	and	new_direction,3
loop4_changeDirection:
	mov	eax,new_direction
	cmp	direction[eax*4],0
	jne	exitLoop4_changeDirection
	inc	new_direction
	and	new_direction,3
	jmp	loop4_changeDirection
exitLoop4_changeDirection:
	inc	esi
	jmp	loop3_changeDirection
exitLoop3_changeDirection:
	mov	eax,new_direction
	mov	game.monsters[ebx].direction,eax
	jmp	exit_changeDirection
noAvailable_changeDirection:
	mov	eax,monster_from
exit_changeDirection:
	pop	esi
	pop	ebx
	ret
changeDirection	endp

clearFire proc	x:dword,y:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,EMPTY
	ret
clearFire ENDP

preAttack proc x:dword,y:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,ATTACK
	ret
preAttack ENDP

makeAttack proc x:dword,y:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,BLUEFIRE
	invoke clear,x,y
	ret
makeAttack ENDP

dealAttack proc x:dword,y:dword,jobFunc:dword
	push edi
	push esi
	mov ecx,x
	dec ecx
	mov edi,3
outLoop_dealAttack:
	cmp edi,0
	je end_dealAttack
	mov edx,y
	dec edx
	mov esi,3
inLoop_dealAttack:
	cmp esi,0
	je endInLoop_dealAttack
	push edx
	push ecx
	invoke calcMapOffset,edi,esi,1
	pop edx
	pop ecx
	cmp game.map[4*eax]._type,WALL
	jne noJob_dealAttack
	push ecx
	push edx
	call jobFunc
noJob_dealAttack:
	dec esi
	inc edx
	jmp inLoop_dealAttack
endInLoop_dealAttack:
	dec edi
	inc ecx
	jmp outLoop_dealAttack
end_dealAttack:
	pop esi
	pop edi
	ret
dealAttack ENDP

pollingAttack proc
	push ebx
	mov ebx,0
loop_pollingAttack:
	cmp ebx,MAX_ATTACK*sizeof(Attack)
	jle end_pollingAttack
	cmp game.attacks[ebx].time,0
	jle noJob_pollingAttack
	dec game.attacks[ebx].time
	cmp game.attacks[ebx].time,ATTACK_TIME
	jle lessAttackTime_pollingAttack
	invoke dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,offset preAttack
	jmp noJob_pollingAttack
lessAttackTime_pollingAttack:
	cmp game.attacks[ecx].time,0
	je equalZeroTime_pollingAttack
	invoke dealAttack,game.attacks[ecx].x,game.attacks[ecx].y,offset makeAttack
	jmp noJob_pollingAttack
equalZeroTime_pollingAttack:
	invoke dealAttack,game.attacks[ecx].x,game.attacks[ecx].y,offset clearFire
noJob_pollingAttack:
	add ebx,sizeof(Attack)
	jmp loop_pollingAttack
end_pollingAttack:
	pop ebx
	ret
pollingAttack ENDP

bossAttack proc
	xor ecx,ecx
loop_bossAttack:
	cmp ecx,MAX_ATTACK*sizeof(Attack)
	jle end_bossAttack
	cmp game.attacks[ecx].time,0
	jle continue_bossAttack
	mov edx,game.player.x
	mov game.attacks[ecx].x,edx
	mov edx,game.player.y
	mov game.attacks[ecx].y,edx
	mov game.attacks[ecx].time,PRE_ATTACK_TIME + ATTACK_TIME
	jmp end_bossAttack
continue_bossAttack:
	add ecx,sizeof(Attack)
	jmp loop_bossAttack
end_bossAttack:
	ret
bossAttack ENDP

bossDrop proc
	mov game.boss.in_map,1
	invoke dealAttack,game.boss.x,game.boss.y,offset clear
bossDrop endp

pollingBoss proc
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
	ret
bossNotInMap_pollingBoss:
	cmp game.boss.sky_time,0
	je bossWillDrop_pollingBoss
	sub game.boss.sky_time,1
	jne skyTimeEnd_pollingBoss
	mov edx,0
	mov eax,game.boss.sky_time
	mov ecx,ATTACK_FREQ
	div ecx
	cmp edx,0
	je beginAttack_pollingBoss
	ret
beginAttack_pollingBoss:
	invoke bossAttack
skyTimeEnd_pollingBoss:
	mov game.boss.pre_drop_time,PRE_DROP_TIME
	mov eax,game.player.x
	mov game.boss.x,eax
	mov eax,game.player.y
	mov game.boss.y,eax
	ret
bossWillDrop_pollingBoss:
	cmp game.boss.pre_drop_time,0
	je end_pollingBoss
	sub game.boss.pre_drop_time,1
	je dropTimeEnd_pollingBoss
	invoke dealAttack,game.boss.x,game.boss.y,offset preAttack
	ret
dropTimeEnd_pollingBoss:
	invoke dealAttack,game.boss.x,game.boss.y,offset clearFire
	invoke bossDrop
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
    local   file:dword,num:dword
    invoke  crt_memset,offset game.map,0,ROW*COL*DEPTH*sizeof Object
    mov edx,game.level
    invoke  crt_fopen,LEVEL_FILE_NAMES[4*edx-4],offset OPEN_FILE_READ_ONLY
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
    mov game.level_timer,eax
    invoke  crt_fclose,file
    ;invoke  crt_printf,offset ADDR_STR,offset game.map
    pop edi
    pop esi
    pop ebx
    ret
initLevel   endp

initGame    proc
    invoke  crt_memset,offset game,0,sizeof Game
    mov game.level,1
    mov game.player.x,1
    mov game.player.y,1
    mov game.player.frac_x,0
    mov game.player.frac_y,0
    mov game.player.bomb_range,1
    mov game.player.bomb_cnt,1
    mov game.player.life,2
    mov game.player.speed,PLAYER_1_SPEED
    mov game.player.status,NORMAL
    invoke  calcMapOffset,0,0,1
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
    ;ebx：bombs数组偏移量
    push    ebx
    xor ebx,ebx
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
    invoke  dealBomb,game.bombs[ebx].x,game.bombs[ebx].y,game.bombs[ebx].range,offset explode
    inc game.player.bomb_cnt
    jmp loopAdd_pollingBomb
setFire_pollingBomb:
    invoke  dealBomb,game.bombs[ebx].x,game.bombs[ebx].y,game.bombs[ebx].range,offset setFire
    jmp loopAdd_pollingBomb
clearFire_pollingBomb:
    invoke  calcMapOffset,game.bombs[ebx].x,game.bombs[ebx].y,0
    mov game.map[eax*4]._type,EMPTY
    invoke  dealBomb,game.bombs[ebx].x,game.bombs[ebx].y,game.bombs[ebx].range,offset clearFire
loopAdd_pollingBomb:
    add ebx,sizeof Bomb
    jmp loop_pollingBomb
exitLoop_pollingBomb:
    pop ebx
    ret
pollingBomb endp

pollingSuccess  proc
    cmp game.monster_num,0
    jne exit_pollingSuccess
    invoke  crt_puts,offset WIN_STR
    dec game.level
    invoke  initLevel
exit_pollingSuccess:
    ret
pollingSuccess  endp

dealBomb    proc    x:dword,y:dword,range:dword,_job:dword
    ;ebx：循环变量，esi：循环界
    push    ebx
    push    esi
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

explode proc    x:dword,y:dword
    invoke  calcMapOffset,x,y,2
    mov game.map[eax*4]._type,FIRE
    invoke  clear,x,y
    ret
explode endp

setFire proc    x:dword,y:dword
    invoke  calcMapOffset,x,y,2
    mov game.map[eax*4]._type,FIRE
    ret
setFire endp

clear   proc    x:dword,y:dword
    invoke  calcMapOffset,x,y,1
    cmp game.map[eax*4]._type,MONSTER
    je  monster_clear
    cmp game.map[eax*4]._type,PLAYER
    je  player_clear
    cmp game.map[eax*4]._type,BOX
    je  box_clear
    cmp game.map[eax*4]._type,BOSS
    je  boss_clear
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
    and eax,3
    cmp eax,1
    jne exit_clear
    invoke  placeTool,x,y
    jmp exit_clear
boss_clear:
    dec game.boss.life
    cmp game.boss.life,0
    jne exit_clear
    invoke  crt_puts,offset WIN_STR
    invoke  crt_exit,0
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

archive proc    path1:ptr byte
    local   file:ptr FILE
    invoke  crt_fopen,path1,offset OPEN_BFILE_WRITE_ONLY
    mov file,eax
    invoke  crt_fwrite,offset game,sizeof Game,1,eax
    invoke  crt_fclose,file
    ret
archive endp

load    proc    path1:ptr byte
    local   file:ptr FILE
    invoke  crt_fopen,path1,offset OPEN_BFILE_READ_ONLY
    mov file,eax
    invoke  crt_fread,offset game,sizeof Game,1,eax
    invoke  crt_fclose,file
    ret
load    endp
end
