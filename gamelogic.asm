.386
.model	flat,stdcall
option	casemap:none

include	common.inc
public  game
public  level_cnt
public	question_cnt
extrn	mainwinp:MainWinp

.const
BOMB_AUDIO   byte    "./audio/Bomb.wav",0
PICK_AUDIO   byte   "./audio/PickUpTool.mp3",0  
DIE_AUDIO    byte   "./audio/Die.mp3",0
LEVEL_UP_AUDIO byte "./audio/Levelup.mp3",0
DRAGON_ROAR_AUDIO byte "./audio/DragonRoar.mp3",0
DRAGON_HURT_AUDIO byte "./audio/DragonHurt.wav",0
ATTACK_AUDIO	byte	"./audio/Attack.wav",0

PLAY_SPRINTF byte "play %s",0
OPEN_FILE_READ_ONLY	byte	"r",0
ONE_INT_FORMAT	byte	"%d",0
LEVEL_FILENAME_FORMAT   byte    "./levels/%02d.level",0
;四字节对齐，提升读取效率
align  4
PLAYER_INPUT_JMP_TBL    dword   offset playerPressUp_pollingPlayer,offset playerPressDown_pollingPlayer,offset playerPressLeft_pollingPlayer,offset playerPressRight_pollingPlayer
TOOL_TYPE_JMP_TBL   dword   offset addLife_pollingPlayer,offset addRange_pollingPlayer,offset addCnt_pollingPlayer,offset addSpeed_pollingPlayer,offset addTime_pollingPlayer
PLACE_ATTACK_JMP_TBL	dword	offset placeAttackUp_bossAttack,offset placeAttackDown_bossAttack,offset placeAttackLeft_bossAttack,offset placeAttackRight_bossAttack
BOSS_STATE_CHG_TBL	dword	0,offset toTakeoff_pollingBoss,offset toInSky_pollingBoss,offset toLanding_pollingBoss,offset toInMap_pollingBoss,offset toLanding_pollingBoss
CALC_NEXT_MOVE_JMP_TBL  dword   offset direUp_calculateNextMove,offset direDown_calculateNextMove,offset direLeft_calculateNextMove,offset direRight_calculateNextMove
PICK_DIRECTION_JMP_TBL	dword	offset empty_pickDirection,offset r_pickDirection,offset l_pickDirection,offset lr_pickDirection,
								offset f_pickDirection,offset fr_pickDirection,offset fl_pickDirection,offset flr_pickDirection
POLL_MONSTER_JMP_TBL	dword	offset direUp_pollingMonster,offset direDown_pollingMonster,offset direLeft_pollingMonster,offset direRight_pollingMonster
FROM_DIRECTION_TBL  dword   DOWN,UP,RIGHT,LEFT
LEFT_DIRECTION_TBL	dword	LEFT,RIGHT,DOWN,UP
RIGHT_DIRECTION_TBL	dword	RIGHT,LEFT,UP,DOWN

.data?
game    Game    <>
level_cnt	dword	?
question_cnt	dword	?

.code
isMoveable	proc	x:dword,y:dword
	invoke	calcMapOffset,x,y,0
	cmp	game.map[eax*4]._type,BOMB
	je	ret_0_isMoveable
	cmp	game.map[eax*4]._type,BOX
	je	ret_0_isMoveable
	cmp	game.map[eax*4]._type,WALL
	je	ret_0_isMoveable
	mov	eax,1
	ret
ret_0_isMoveable:
	xor	eax,eax
	ret
isMoveable	endp

isMoveableMonster   proc    x:dword, y:dword
	invoke isMoveable, x, y
	test    eax,eax
	jz ret_isMoveableMonster
	invoke calcMapOffset, x, y, 2
	cmp game.map[eax*4]._type,MONSTER
	mov eax,0	;不能xor，因为破坏标志位
	je ret_isMoveableMonster
	inc eax ; none of above,ret 1
ret_isMoveableMonster:
	ret
isMoveableMonster   endp

placeBomb	proc	
	push    ebx
	cmp game.player.bomb_cnt,0
	jng ret_placeBomb
	invoke calcMapOffset,game.player.x,game.player.y,0
	cmp game.map[4*eax]._type,EMPTY
	jne ret_placeBomb
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

die proc
	local audioCmd[100]:byte
	cmp game.player.timer,0
	jg  no_die
	invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset DIE_AUDIO
	invoke mciSendString,addr audioCmd,0,0,0
	dec	game.player.life
	cmp game.player.life,0
	je l1_die
	invoke calcMapOffset,game.player.x,game.player.y,1
	mov game.map[eax*4] ,EMPTY
	mov game.player.x,1
	mov game.player.y,1
	mov game.player.frac_x,0
	mov game.player.frac_y,0
	invoke calcMapOffset,1,1,1
	mov game.map[eax*4]._type ,PLAYER
	mov game.player.timer,INVISIBLE_TIMER
	mov eax,game.level_timer
	mov game.timer,eax
	jmp	ret_1_die
no_die:
	xor	eax,eax
	ret
l1_die:
	mov mainwinp.transitionFunc,jobResetTimer
	mov	mainwinp.shouldFade,TRUE
	mov mainwinp.intentState,GAME_OVER_STATE
ret_1_die:
	mov	eax,1
	ret
die endp

pollingPlayer	proc	input:dword
	local audioCmd[100]:byte
	mov game.player.isMove,STILL
	cmp game.player.timer,0
	je  JmpOverINVISIBLE_pollingPlayer
	dec game.player.timer
JmpOverINVISIBLE_pollingPlayer:
	cmp input,0
	jl	checkDie_pollingPlayer
	cmp input, SETBOMB
	jne JmpOver_placeBomb_pollingPlayer
	invoke placeBomb
	jmp checkDie_pollingPlayer
JmpOver_placeBomb_pollingPlayer:
	invoke calcMapOffset, game.player.x, game.player.y, 1
	mov game.map[eax*4]._type,EMPTY
	mov eax,input
	mov game.player.direction,eax
	mov game.player.isMove,MOVE
	jmp [PLAYER_INPUT_JMP_TBL+eax*4]
playerPressUp_pollingPlayer   label   near
	mov eax,game.player.frac_x
	sub eax,game.player.speed
	mov game.player.frac_x,eax
	cmp eax,-FRAC_RANGE
	jge checkDie_pollingPlayer
	mov eax,game.player.x
	dec eax
	invoke  isMoveable,eax,game.player.y
	test    eax,eax
	jnz  canMoveUp_pollingPlayer
	mov game.player.frac_x,-FRAC_RANGE
	jmp checkDie_pollingPlayer
canMoveUp_pollingPlayer:
	dec game.player.x
	mov eax,game.player.frac_x
	add eax,2*FRAC_RANGE
	mov game.player.frac_x,eax
	jmp checkDie_pollingPlayer
playerPressDown_pollingPlayer label   near
	mov eax,game.player.frac_x
	add eax,game.player.speed
	mov game.player.frac_x,eax
	cmp eax,FRAC_RANGE
	jl checkDie_pollingPlayer
	mov eax,game.player.x
	inc eax
	invoke  isMoveable,eax,game.player.y
	test    eax,eax
	jnz  canMoveDown_pollingPlayer
	mov game.player.frac_x,FRAC_RANGE-1
	jmp checkDie_pollingPlayer
canMoveDown_pollingPlayer:
	inc game.player.x
	mov eax,game.player.frac_x
	sub eax,2*FRAC_RANGE
	mov game.player.frac_x,eax
	jmp checkDie_pollingPlayer
playerPressLeft_pollingPlayer label   near
	mov eax,game.player.frac_y
	sub eax,game.player.speed
	mov game.player.frac_y,eax
	cmp eax,-FRAC_RANGE
	jge checkDie_pollingPlayer
	mov eax,game.player.y
	dec eax
	invoke  isMoveable,game.player.x,eax
	test    eax,eax
	jnz  canMoveLeft_pollingPlayer
	mov game.player.frac_y,-FRAC_RANGE
	jmp checkDie_pollingPlayer
canMoveLeft_pollingPlayer:
	dec game.player.y
	mov eax,game.player.frac_y
	add eax,2*FRAC_RANGE
	mov game.player.frac_y,eax
	jmp checkDie_pollingPlayer
playerPressRight_pollingPlayer    label   near
	mov eax,game.player.frac_y
	add eax,game.player.speed
	mov game.player.frac_y,eax
	cmp eax,FRAC_RANGE
	jl checkDie_pollingPlayer
	mov eax,game.player.y
	inc eax
	invoke  isMoveable,game.player.x,eax
	test    eax,eax
	jnz  canMoveRight_pollingPlayer
	mov game.player.frac_y,FRAC_RANGE-1
	jmp checkDie_pollingPlayer
canMoveRight_pollingPlayer:
	inc game.player.y
	mov eax,game.player.frac_y
	sub eax,2*FRAC_RANGE
	mov game.player.frac_y,eax
checkDie_pollingPlayer:
	invoke calcMapOffset,game.player.x,game.player.y,2
	cmp game.map[eax*4]._type, MONSTER
	je	playerDie_pollingPlayer
	cmp	game.map[eax*4]._type,BLUEFIRE
	je	playerDie_pollingPlayer
	cmp	game.boss.state,IN_MAP_STATE
	je	checkBoss_pollingPlayer
	jmp	pickTool_pollingPlayer
checkBoss_pollingPlayer:
	mov edx,game.player.x
	sub edx,game.boss.x
	cmp edx,-1
	jl  pickTool_pollingPlayer
	cmp edx,1
	jg  pickTool_pollingPlayer
	mov edx,game.player.y
	sub edx,game.boss.y
	cmp edx,-1
	jl  pickTool_pollingPlayer
	cmp edx,1
	jg  pickTool_pollingPlayer
playerDie_pollingPlayer:
	push	eax
	invoke  die
	test	eax,eax
	pop	eax
	jz	JmpOverTool_pollingPlayer
	ret
pickTool_pollingPlayer:
	cmp game.map[eax*4-8]._type, TOOL
	jne JmpOverTool_pollingPlayer
	push eax
	invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset PICK_AUDIO
	invoke mciSendString,addr audioCmd,0,0,0
	pop eax
	movzx   ecx,game.map[eax*4-8].id
	sal ecx, 4  ;tool_index *= sizeof(tool)   考虑万一改变sizeof Tool，这个地方要改
	mov edx,game.tools[ecx]._type
	jmp [TOOL_TYPE_JMP_TBL+edx*4]
addLife_pollingPlayer	label	near
	cmp game.player.life,MAX_LIFE
	jge ToolSwEnd_pollingPlayer
	inc game.player.life
	jmp ToolSwEnd_pollingPlayer
addRange_pollingPlayer	label	near
	cmp game.player.bomb_range,MAX_BOMB_RANGE
	jge  ToolSwEnd_pollingPlayer
	inc game.player.bomb_range
	jmp ToolSwEnd_pollingPlayer
addCnt_pollingPlayer	label	near
	cmp game.player.bomb_cnt,MAX_BOMB_CNT
	jge ToolSwEnd_pollingPlayer
	inc game.player.bomb_cnt
	jmp ToolSwEnd_pollingPlayer
addSpeed_pollingPlayer	label	near
	cmp game.player.speed,MAX_SPEED
	jge ToolSwEnd_pollingPlayer
	inc game.player.speed
	jmp ToolSwEnd_pollingPlayer
addTime_pollingPlayer	label	near
	add game.timer,20*FRAMES_PER_SEC
ToolSwEnd_pollingPlayer:
	mov game.map[eax*4-8]._type, EMPTY
	mov game.tools[ecx].timer, 0
JmpOverTool_pollingPlayer:
	mov game.map[eax*4-4]._type,PLAYER
	ret
pollingPlayer	endp

calculateNextMove proc stdcall x:dword,y:dword,direction:dword,new_x:ptr dword,new_y:ptr dword
	mov eax,direction
	jmp [CALC_NEXT_MOVE_JMP_TBL+eax*4]
direUp_calculateNextMove	label	near
	mov ecx,x
	dec	ecx
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	mov	eax,new_y
	mov	[eax],ecx
	ret
direDown_calculateNextMove	label	near
	mov	ecx,x
	inc	ecx
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	mov	eax,new_y
	mov	[eax],ecx
	ret
direLeft_calculateNextMove	label	near
	mov	ecx,x
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	dec	ecx
	mov	eax,new_y
	mov	[eax],ecx
	ret
direRight_calculateNextMove	label	near
	mov	ecx,x
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	inc	ecx
	mov	eax,new_y
	mov	[eax],ecx
	ret
calculateNextMove endp

pickDirection	proc	x:dword,y:dword,direction:dword
	local	newX:dword,newY:dword
	push	ebx	;directionId
	xor	ebx,ebx
	invoke	calculateNextMove,x,y,direction,addr newX,addr newY
	invoke	isMoveableMonster,newX,newY
	test	eax,eax
	jz	skipFront_pickDirection
	or	ebx,4
skipFront_pickDirection:
	mov	edx,direction
	mov	edx,[LEFT_DIRECTION_TBL+edx*4]
	invoke	calculateNextMove,x,y,edx,addr newX,addr newY
	invoke	isMoveableMonster,newX,newY
	test	eax,eax
	jz	skipLeft_pickDirection
	or	ebx,2
skipLeft_pickDirection:
	mov	edx,direction
	mov	edx,[RIGHT_DIRECTION_TBL+edx*4]
	invoke	calculateNextMove,x,y,edx,addr newX,addr newY
	invoke	isMoveableMonster,newX,newY
	test	eax,eax
	jz	skipRight_pickDirection
	or	ebx,1
skipRight_pickDirection:
	jmp	[PICK_DIRECTION_JMP_TBL+ebx*4]
empty_pickDirection	label	near
	mov	eax,direction
	mov	eax,[FROM_DIRECTION_TBL+eax*4]
	jmp	exit_pickDirection
r1_pickDirection:
r_pickDirection	label	near
	mov	eax,direction
	mov	eax,[RIGHT_DIRECTION_TBL+eax*4]
	jmp	exit_pickDirection
l1_pickDirection:
l_pickDirection	label	near
	mov	eax,direction
	mov	eax,[LEFT_DIRECTION_TBL+eax*4]
	jmp	exit_pickDirection
lr_pickDirection	label	near
	invoke	crt_rand
	and	eax,1
	jz	l1_pickDirection
	jmp	r1_pickDirection
f1_pickDirection:
f_pickDirection	label	near
	mov	eax,direction
exit_pickDirection:
	pop	ebx
	ret
fr_pickDirection	label	near
	invoke	crt_rand
	and	eax,1
	jz	f1_pickDirection
	jmp	r1_pickDirection
fl_pickDirection	label	near
	invoke	crt_rand
	and	eax,1
	jz	f1_pickDirection
	jmp	l1_pickDirection
flr_pickDirection	label	near
	invoke	crt_rand
	and	eax,1
	jz	f1_pickDirection
	invoke	crt_rand
	and	eax,1
	jz	l1_pickDirection
	jmp	r1_pickDirection
pickDirection	endp

pollingMonster	proc
	push	ebx
	push	esi
	xor	ebx,ebx
	xor	esi,esi
loop_pollingMonster:
	cmp	ebx,MAX_MONSTER*sizeof Monster
	je	exitLoop_pollingMonster
	cmp	game.monsters[ebx].valid,0
	je	continue_pollingMonster
	invoke	calcMapOffset,game.monsters[ebx].x,game.monsters[ebx].y,2
	mov	game.map[eax*4]._type,EMPTY
	mov	eax,game.monsters[ebx].speed	;都要改小坐标的，速度先移进寄存器再说
	mov	edx,game.monsters[ebx].direction
	jmp	[POLL_MONSTER_JMP_TBL+edx*4]	;根据怪的方向来判断
direUp_pollingMonster	label	near
	sub	game.monsters[ebx].frac_x,eax	;试探性地改变小坐标
	jg	setMap_pollingMonster	;没过中点，无事发生
	cmp	game.monsters[ebx].has_turned,0	;过了中点，这个格子有没有选过方向？
	je	makeTurn_pollingMonster	;没有？那你选一个方向吧
	mov	eax,game.monsters[ebx].x	;有？你先别急，看看你前面能不能走
	dec	eax
	invoke	isMoveableMonster,eax,game.monsters[ebx].y
	test	eax,eax
	jz	turnAround_pollingMonster	;不能走？你赶紧掉头吧
	cmp	game.monsters[ebx].frac_x,-FRAC_RANGE	;看看小坐标有没有越界
	jge	setMap_pollingMonster	;没越界，无事发生
	add	game.monsters[ebx].frac_x,2*FRAC_RANGE	;越界，更新大坐标，重置是否选过方向
	dec	game.monsters[ebx].x
	mov	game.monsters[ebx].has_turned,0
	jmp	setMap_pollingMonster
direDown_pollingMonster	label	near
	add	game.monsters[ebx].frac_x,eax
	jl	setMap_pollingMonster
	cmp	game.monsters[ebx].has_turned,0
	je	makeTurn_pollingMonster
	mov	eax,game.monsters[ebx].x
	inc	eax
	invoke	isMoveableMonster,eax,game.monsters[ebx].y
	test	eax,eax
	jz	turnAround_pollingMonster
	cmp	game.monsters[ebx].frac_x,FRAC_RANGE
	jl	setMap_pollingMonster
	sub	game.monsters[ebx].frac_x,2*FRAC_RANGE
	inc	game.monsters[ebx].x
	mov	game.monsters[ebx].has_turned,0
	jmp	setMap_pollingMonster
direLeft_pollingMonster	label	near
	sub	game.monsters[ebx].frac_y,eax
	jg	setMap_pollingMonster
	cmp	game.monsters[ebx].has_turned,0
	je	makeTurn_pollingMonster
	mov	eax,game.monsters[ebx].y
	dec	eax
	invoke	isMoveableMonster,game.monsters[ebx].x,eax
	test	eax,eax
	jz	turnAround_pollingMonster
	cmp	game.monsters[ebx].frac_y,-FRAC_RANGE
	jge	setMap_pollingMonster
	add	game.monsters[ebx].frac_y,2*FRAC_RANGE
	dec	game.monsters[ebx].y
	mov	game.monsters[ebx].has_turned,0
	jmp	setMap_pollingMonster
direRight_pollingMonster	label	near
	add	game.monsters[ebx].frac_y,eax
	jl	setMap_pollingMonster
	cmp	game.monsters[ebx].has_turned,0
	je	makeTurn_pollingMonster
	mov	eax,game.monsters[ebx].y
	inc	eax
	invoke	isMoveableMonster,game.monsters[ebx].x,eax
	test	eax,eax
	jz	turnAround_pollingMonster
	cmp	game.monsters[ebx].frac_y,FRAC_RANGE
	jl	setMap_pollingMonster
	sub	game.monsters[ebx].frac_y,2*FRAC_RANGE
	inc	game.monsters[ebx].y
	mov	game.monsters[ebx].has_turned,0
	jmp	setMap_pollingMonster
turnAround_pollingMonster:
	mov	eax,game.monsters[ebx].direction	;直接反向，并重置是否选过方向
	mov	eax,[FROM_DIRECTION_TBL+eax*4]
	mov	game.monsters[ebx].direction,eax
	mov	game.monsters[ebx].has_turned,0
	jmp	setMap_pollingMonster
makeTurn_pollingMonster:
	invoke	pickDirection,game.monsters[ebx].x,game.monsters[ebx].y,game.monsters[ebx].direction	;选一个方向吧
	cmp	eax,game.monsters[ebx].direction
	je	skipChangeDirection_pollingMonster
	mov	game.monsters[ebx].frac_x,0	;如果改变方向，强制把小坐标重置为中点
	mov	game.monsters[ebx].frac_y,0
	mov	game.monsters[ebx].direction,eax
skipChangeDirection_pollingMonster:
	mov	game.monsters[ebx].has_turned,1	;无论是否改变方向，你已经选过方向了
setMap_pollingMonster:
	invoke	calcMapOffset,game.monsters[ebx].x,game.monsters[ebx].y,2
	mov	game.map[eax*4]._type,MONSTER
	mov	game.map[eax*4].id,si
continue_pollingMonster:
	add	ebx,sizeof Monster
	inc	esi
	jmp	loop_pollingMonster
exitLoop_pollingMonster:
	pop	esi
	pop	ebx
	ret
pollingMonster	endp

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

clear   proc    x:dword,y:dword
	local audioCmd[100]:byte   
	invoke  calcMapOffset,x,y,1
	cmp game.map[eax*4+4]._type,MONSTER
	je  monster_clear
	cmp game.map[eax*4]._type,PLAYER
	je  player_clear
	cmp game.map[eax*4-4]._type,BOX
	je  box_clear
	cmp game.map[eax*4+12]._type,BOSS
	je  boss_clear
	cmp game.map[eax*4-4]._type,TOOL
	je tool_clear
exit_clear:
	ret
monster_clear:
	mov game.map[eax*4+4]._type,EMPTY
	movzx   eax,game.map[eax*4+4].id
	imul	eax,sizeof Monster
	mov game.monsters[eax].valid,0
	dec game.monster_num
	ret
player_clear:
	invoke  die
	ret
box_clear:
	mov game.map[eax*4-4]._type,EMPTY
	invoke  crt_rand
	xor edx,edx
	mov ecx,TOOL_CHANCE_RATE
	div ecx
	test	edx,edx
	jne exit_clear
	invoke  placeTool,x,y
	ret
tool_clear:
	mov game.map[eax*4-4]._type,EMPTY
	movzx eax,game.map[eax*4-4].id
	imul	eax,sizeof Tool
	mov game.tools[eax].timer,0
	ret
boss_clear:
	invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset DRAGON_HURT_AUDIO
	invoke mciSendString,addr audioCmd,0,0,0
	dec game.boss.life
	cmp game.boss.life,0
	je boss_die_clear
move_boss_clear:
	mov	game.boss.timer,1
	ret
boss_die_clear:
	mov	mainwinp.transitionFunc,jobResetTimer
	mov	mainwinp.shouldFade,FALSE
	mov mainwinp.intentState,KILL_BOSS_STATE
	ret
clear   endp

preAttack proc x:dword,y:dword,id:dword
	invoke calcMapOffset,x,y,4
	mov game.map[eax*4]._type,ATTACK
	ret
preAttack ENDP

makeAttack proc x:dword,y:dword,id:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,BLUEFIRE
	mov	edx,id
	mov game.map[eax*4].id,dx
	cmp	game.map[eax*4+8]._type,ATTACK
	jne	skipClearAttack_makeAttack
	mov	game.map[eax*4+8]._type,EMPTY
skipClearAttack_makeAttack:
	ret
makeAttack ENDP

makeMonsterAttack	proc	x:dword,y:dword,id:dword
	push	edi
	mov	edi,id
	imul	edi,sizeof Monster
	mov	game.monsters[edi].valid,1
	mov	game.monsters[edi].speed,MONSTER_3_SPEED
	mov	game.monsters[edi].frac_x,0
	mov	game.monsters[edi].frac_y,0
	invoke	crt_rand
	and	eax,3
	mov	game.monsters[edi].direction,eax
	mov	eax,x
	mov	game.monsters[edi].x,eax
	mov	eax,y
	mov	game.monsters[edi].y,eax
	invoke	calcMapOffset,game.attacks[ebx].x,game.attacks[ebx].y,2
	mov	game.map[eax*4]._type,MONSTER
	mov	edx,id
	mov	game.map[eax*4].id,dx
	mov	game.map[eax*4+8],EMPTY
	inc	game.monster_num
	pop	edi
	ret
makeMonsterAttack	endp

clearBlueFire proc x:dword,y:dword,id:dword
	invoke calcMapOffset,x,y,2
	cmp game.map[eax*4]._type,BLUEFIRE
	jne noBlueFire_clearBlueFire
	mov game.map[eax*4]._type,EMPTY
noBlueFire_clearBlueFire:
	ret
clearBlueFire endp

dealAttack  proc    x:dword,y:dword,range:dword,id:dword,jobFunc:dword
	push    esi
	push    edi
	mov esi,x
	sub	esi,range
outerLoop_dealAttack:
	mov eax,x
	add	eax,range
	cmp esi,eax
	jg  exitOuterLoop_dealAttack
	mov edi,y
	sub	edi,range
innerLoop_dealAttack:
	mov eax,y
	add	eax,range
	cmp edi,eax
	jg  exitInnerLoop_dealAttack
	invoke  calcMapOffset,esi,edi,0
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

pollingAttack	proc
	local	audioCmdBuf[100]:byte
	push	ebx
	push    esi
	xor ebx,ebx
	xor esi,esi
loop_pollingAttack:
	cmp ebx,MAX_ATTACK*sizeof(Attack)
	jge end_pollingAttack
	cmp	game.attacks[ebx].timer,0
	jle	noJob_pollingAttack
	dec	game.attacks[ebx].timer
	cmp	game.attacks[ebx].timer,ATTACK_TIME
	jg	showPreAttack_pollingAttack
	je	attack_pollingAttack
	cmp	game.attacks[ebx].timer,0
	jg	continueAttack_pollingAttack
	invoke	dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,1,esi,offset clearBlueFire
	jmp	noJob_pollingAttack
continueAttack_pollingAttack:
	cmp	game.attacks[ebx]._type,JUST_FIRE
	je	setBlueFire_pollingAttack
	jmp	noJob_pollingAttack
showPreAttack_pollingAttack:
	cmp	game.attacks[ebx]._type,JUST_FIRE
	je	showBigWarning_pollingAttack
	invoke dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,0,esi,offset preAttack
	jmp	noJob_pollingAttack
showBigWarning_pollingAttack:
	invoke dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,1,esi,offset preAttack
	jmp	noJob_pollingAttack
attack_pollingAttack:
	cmp	game.attacks[ebx]._type,JUST_FIRE
	je	playExplode_pollingAttack
	invoke	dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,0,esi,offset makeMonsterAttack
	jmp	noJob_pollingAttack
playExplode_pollingAttack:
	invoke	crt_sprintf,addr audioCmdBuf,offset PLAY_SPRINTF,offset	ATTACK_AUDIO
	invoke	mciSendString,addr audioCmdBuf,NULL,0,NULL
setBlueFire_pollingAttack:
	invoke	dealAttack,game.attacks[ebx].x,game.attacks[ebx].y,1,esi,offset makeAttack
noJob_pollingAttack:
	add	ebx,sizeof Attack
	inc	esi
	jmp	loop_pollingAttack
end_pollingAttack:
	pop esi
	pop ebx
	ret
pollingAttack	endp

bossAttack proc
	push	ebx
	push	esi
	xor esi,esi
loop_bossAttack:
	cmp esi,MAX_ATTACK*sizeof(Attack)
	jge end_bossAttack
	cmp game.attacks[esi].timer,0
	jg continue_bossAttack
	cmp	game.player.isMove,0
	je	placeAttack_bossAttack
	mov	eax,game.player.direction
	jmp	[PLACE_ATTACK_JMP_TBL+eax*4]
placeAttackUp_bossAttack	label	near
	mov	ebx,game.player.x
	dec	ebx
	invoke	isMoveable,ebx,game.player.y
	test	eax,eax
	jz	placeAttack_bossAttack
	jmp	placeAttackX_bossAttack
placeAttackDown_bossAttack	label	near
	mov	ebx,game.player.x
	inc	ebx
	invoke	isMoveable,ebx,game.player.y
	test	eax,eax
	jz	placeAttack_bossAttack
	jmp	placeAttackX_bossAttack
placeAttackLeft_bossAttack	label	near
	mov	ebx,game.player.y
	dec	ebx
	invoke	isMoveable,game.player.x,ebx
	test	eax,eax
	jz	placeAttack_bossAttack
	jmp	placeAttackY_bossAttack
placeAttackRight_bossAttack	label	near
	mov	ebx,game.player.y
	inc	ebx
	invoke	isMoveable,game.player.x,ebx
	test	eax,eax
	jz	placeAttack_bossAttack
	jmp	placeAttackY_bossAttack
placeAttackX_bossAttack:
	mov	game.attacks[esi].x,ebx
	mov	eax,game.player.y
	mov	game.attacks[esi].y,eax
	jmp	setTimer_bossAttack
placeAttackY_bossAttack:
	mov	eax,game.player.x
	mov	game.attacks[esi].x,eax
	mov	game.attacks[esi].y,ebx
	jmp	setTimer_bossAttack
placeAttack_bossAttack:
	mov edx,game.player.x
	mov game.attacks[esi].x,edx
	mov edx,game.player.y
	mov game.attacks[esi].y,edx
setTimer_bossAttack:
	mov game.attacks[esi].timer,PRE_ATTACK_TIME + ATTACK_TIME
	mov	game.attacks[esi]._type,JUST_FIRE
	jmp end_bossAttack
continue_bossAttack:
	add esi,sizeof(Attack)
	jmp loop_bossAttack
end_bossAttack:
	pop	esi
	pop	ebx
	ret
bossAttack endp

generatePosition	proc	x:ptr dword,y:ptr dword
	invoke	crt_rand
	xor	edx,edx
	mov	ecx,ROW-4
	div	ecx
	add	edx,2
	mov	eax,x
	mov	[eax],edx
	invoke	crt_rand
	xor	edx,edx
	mov	ecx,COL-4
	div	ecx
	add	edx,2
	mov	eax,y
	mov	[eax],edx
	ret
generatePosition	endp

summonMonsters	proc
	local	xValid[ROW]:byte,yValid[COL]:byte,tmpX:dword,tmpY:dword
	push	ebx
	push	esi
	invoke	crt_memset,addr xValid,1,ROW
	invoke	crt_memset,addr yValid,1,COL
	xor	ebx,ebx
	xor	esi,esi
loop_summonMonster:
	cmp	ebx,8*sizeof Attack
	je	exit_summonMonsters
generateXY_summonMonster:
	invoke	generatePosition,addr tmpX,addr tmpY
	invoke	isMoveableMonster,tmpX,tmpY
	test	eax,eax
	mov	ecx,tmpX
	mov	edx,tmpY
	jz	generateXY_summonMonster
	cmp	xValid[ecx],0
	jne	okToSet_summonMonster
	cmp	yValid[edx],0
	je	generateXY_summonMonster
okToSet_summonMonster:
	mov	xValid[ecx],0
	mov	yValid[edx],0
	mov	game.attacks[ebx].x,ecx
	mov	game.attacks[ebx].y,edx
	mov	game.attacks[ebx].timer,PRE_ATTACK_TIME + ATTACK_TIME
	mov	game.attacks[ebx]._type,SUMMON_MONSTER
	add	ebx,sizeof Attack
	inc	esi
	jmp	loop_summonMonster
exit_summonMonsters:
	pop	esi
	pop	ebx
	ret
summonMonsters	endp

killAllMonsters	proc
	push	ebx
	xor	ebx,ebx
	mov	game.monster_num,1
loop_killAllMonsters:
	cmp	ebx,MAX_MONSTER*sizeof Monster
	je	exit_killAllMonsters
	cmp	game.monsters[ebx].valid,0
	je	skipSetMap_killAllMonsters
	invoke	calcMapOffset,game.monsters[ebx].x,game.monsters[ebx].y,2
	mov	game.map[eax*4]._type,EMPTY
	mov	game.monsters[ebx].valid,0
skipSetMap_killAllMonsters:
	add	ebx,sizeof Monster
	jmp	loop_killAllMonsters
exit_killAllMonsters:
	pop	ebx
	ret
killAllMonsters	endp

killAllAttacks	proc
	push	ebx
	xor	ebx,ebx
loop_killAllAttacks:
	cmp	ebx,MAX_ATTACK*sizeof Attack
	je	exit_killAllAttacks
	cmp	game.attacks[ebx].timer,0
	je	continue_killAllAttacks
	mov	game.attacks[ebx].timer,1
continue_killAllAttacks:
	add	ebx,sizeof Attack
	jmp	loop_killAllAttacks
exit_killAllAttacks:
	pop	ebx
	ret
killAllAttacks	endp

pollingBoss	proc
	local audioCmd[100]:byte
	cmp	game.boss.state,NOT_EXIST
	je	exit_pollingBoss
	dec	game.boss.timer
	jz	changeState_pollingBoss
	;根据不同状态干活
	cmp	game.boss.state,IN_SKY_STATE
	jne	exit_pollingBoss
	xor edx,edx
	mov eax,game.boss.timer
	mov ecx,ATTACK_FREQ
	div ecx
	test	edx,edx
	jnz	exit_pollingBoss
	invoke	crt_rand
	and	eax,3	;1/4
	jnz	skipRoar_pollingBoss
	invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset DRAGON_ROAR_AUDIO
	invoke mciSendString,addr audioCmd,0,0,0
skipRoar_pollingBoss:
	invoke bossAttack
	ret
changeState_pollingBoss:
	mov	eax,game.boss.state
	jmp	[BOSS_STATE_CHG_TBL+eax*4]
toTakeoff_pollingBoss	label	near
	invoke calcMapOffset,game.boss.x,game.boss.y,4
	mov game.map[4*eax]._type,EMPTY
	mov	game.boss.state,TAKEOFF_STATE
	mov	game.boss.timer,TAKEOFF_TIME
	invoke	killAllAttacks
	jmp	exit_pollingBoss
toInSky_pollingBoss	label	near
	invoke	crt_rand
	xor	edx,edx
	mov	ecx,MAX_SKY_TIME-MIN_SKY_TIME
	div	ecx
	add	edx,MIN_SKY_TIME
	mov	game.boss.timer,edx
	cmp	game.boss.next_attack_type,0
	je	setSummon_pollingBoss
	mov	game.boss.state,IN_SKY_STATE
	mov	game.boss.next_attack_type,0
	jmp	finishSetSky_pollingBoss
setSummon_pollingBoss:
	mov	game.boss.state,IN_SKY_SUMMON_STATE
	mov	game.boss.next_attack_type,1
	invoke	summonMonsters
finishSetSky_pollingBoss:
	invoke crt_sprintf,addr audioCmd,offset PLAY_SPRINTF,offset DRAGON_ROAR_AUDIO
	invoke mciSendString,addr audioCmd,0,0,0
	jmp	exit_pollingBoss
toLanding_pollingBoss	label	near
	;randomly choose a place to land
	invoke	generatePosition,offset game.boss.x,offset game.boss.y
	mov	game.boss.state,LANDING_STATE
	mov	game.boss.timer,LANDING_TIME
	jmp	exit_pollingBoss
toInMap_pollingBoss	label	near
	invoke	killAllMonsters
	invoke	calcMapOffset,game.boss.x,game.boss.y,4
	mov game.map[eax*4]._type,BOSS
	mov	game.boss.state,IN_MAP_STATE
	mov	game.boss.timer,COOL_TIME
exit_pollingBoss:
	ret
pollingBoss	endp

initMonster	proc    index:dword,x:dword,y:dword,speed:dword
	mov edx,index
	imul	edx,sizeof Monster
	mov game.monsters[edx].direction,0
	mov eax,x
	mov game.monsters[edx].x,eax
	mov eax,y
	mov game.monsters[edx].y,eax
	mov game.monsters[edx].frac_x,0
	mov game.monsters[edx].frac_y,0
	mov	game.monsters[edx].has_turned,0
	mov eax,speed
	mov game.monsters[edx].speed,eax
	mov game.monsters[edx].valid,1
	ret
initMonster	endp

initBoss    proc    x:dword,y:dword
	mov eax,x
	mov game.boss.x,eax
	mov eax,y
	mov game.boss.y,eax
	mov	game.boss.state,IN_MAP_STATE
	mov	game.boss.timer,COOL_TIME
	mov game.boss.life,BOSS_LIFE
	invoke	crt_rand
	and	eax,1
	mov	game.boss.next_attack_type,eax
	ret
initBoss    endp

initLevel   proc
	local   file:dword,num:dword,str1[20]:byte
	;reset players pos
	mov game.player.x,1
	mov game.player.y,1
	mov game.player.frac_x,0
	mov game.player.frac_y,0
	mov game.player.timer,0
	mov game.player.isMove,STILL
	mov game.player.direction,RIGHT
	;clear map and other objects
	invoke  crt_memset,offset game.map,0,sizeof game.map
	invoke	crt_memset,offset game.bombs,0,sizeof game.bombs
	invoke	crt_memset,offset game.tools,0,sizeof game.tools
	invoke	crt_memset,offset game.attacks,0,sizeof game.attacks
	invoke	crt_memset,offset game.monsters,0,sizeof game.monsters
	invoke	crt_memset,offset game.boss,0,sizeof Boss
	;load level file
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
	mov edx,game.monster_num
	mov game.map[ebx*4+4].id,dx
	invoke  initMonster,game.monster_num,esi,edi,MONSTER_1_SPEED
	inc game.monster_num
	mov num,MONSTER
	jmp setMap_initLevel
setMonster2_initLevel:
	mov edx,game.monster_num
	mov game.map[ebx*4+4].id,dx
	invoke  initMonster,game.monster_num,esi,edi,MONSTER_2_SPEED
	inc game.monster_num
	mov num,MONSTER
	jmp setMap_initLevel
setMonster3_initLevel:
	mov edx,game.monster_num
	mov game.map[ebx*4+4].id,dx
	invoke  initMonster,game.monster_num,esi,edi,MONSTER_3_SPEED
	inc game.monster_num
	mov num,MONSTER
	jmp setMap_initLevel
setBoss_initLevel:
	invoke  initBoss,esi,edi
	mov game.monster_num,1
	jmp setMap_initLevel
setMap_initLevel:
	mov edx,num
	cmp	edx,MONSTER
	je	setMonsterOnMap_initLevel
	cmp	edx,PLAYER
	je	setPlayerOnMap_initLevel
	cmp	edx,BOSS
	je	setBossOnMap_initLevel
	mov game.map[ebx*4-4]._type,dx
	jmp	finishSetMap_initLevel
setPlayerOnMap_initLevel:
	mov game.map[ebx*4]._type,dx
	jmp	finishSetMap_initLevel
setBossOnMap_initLevel:
	mov	game.map[ebx*4+12]._type,dx
	jmp	finishSetMap_initLevel
setMonsterOnMap_initLevel:
	mov	game.map[ebx*4+4]._type,dx
finishSetMap_initLevel:
	inc edi
	jmp innerLoop_initLevel
exitInnerLoop_initLevel:
	inc esi
	jmp outerLoop_initLevel
exitOuterLoop_initLevel:
	invoke  crt_fscanf,file,offset ONE_INT_FORMAT,offset game.timer
	mov eax,game.timer
	imul	eax,FRAMES_PER_SEC
	mov game.level_timer,eax
	mov game.timer,eax
	invoke  crt_fclose,file
	pop edi
	pop esi
	pop ebx
	ret
initLevel   endp

initGame    proc
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

isDestroyable   proc    x:dword,y:dword
	invoke  calcMapOffset,x,y,0
	cmp game.map[4*eax]._type,WALL
	je  retZero_isDestroyable
	cmp game.map[4*eax]._type,BOMB
	je  retZero_isDestroyable
	mov eax,1
	ret
retZero_isDestroyable:
	xor eax,eax
	ret
isDestroyable   endp

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

explode proc    x:dword,y:dword,id:dword
	invoke  calcMapOffset,x,y,3
	mov game.map[eax*4]._type,FIRE
	mov edx,id
	mov game.map[eax*4].id,dx
	invoke  clear,x,y
	ret
explode endp

setFire proc    x:dword,y:dword,id:dword
	invoke  calcMapOffset,x,y,3
	mov game.map[eax*4]._type,FIRE
	mov edx,id
	mov game.map[eax*4].id,dx
	ret
setFire endp

clearFire proc	x:dword,y:dword,id:dword
	invoke calcMapOffset,x,y,3
	mov game.map[eax*4]._type,EMPTY
	ret
clearFire ENDP

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
	mov mainwinp.transitionFunc,jobGameToQuestion
	mov	mainwinp.shouldFade,TRUE
	mov mainwinp.intentState,QUESTION_STATE
exit_pollingSuccess:
	ret
pollingSuccess  endp

gameLoop proc   input:dword
	invoke  pollingPlayer,input
	invoke  pollingAttack
	invoke  pollingMonster
	invoke  pollingBoss
	invoke  pollingBomb
	invoke  pollingTool
	invoke  pollingSuccess
	dec	game.timer
	jne timeNotUp_gameLoop
	mov eax,game.level_timer
	mov game.timer,eax
	invoke  die
timeNotUp_gameLoop:
	ret
gameLoop endp

end
