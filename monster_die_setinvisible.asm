.486
.model flat, stdcall
option casemap:none

include	common.inc
extrn	game:Game

.code


;int setInvisible(Game *this) {
;	if (this->player.status == NORMAL) {
;		this->player.status = INVISIBLE;
;		this->player.timer = INVISIBLE_TIMER;
;		return 1;
;	}
;	return 0;
;}

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


;void calculateNextMove(int x, int y, int direction, int *new_x, int *new_y) {
;    switch (direction) {
;        case UP: *new_x = x - 1; *new_y = y; break; // Move up
;       case DOWN: *new_x = x + 1; *new_y = y; break; // Move down
;        case LEFT: *new_x = x; *new_y = y - 1; break; // Move left
;        case RIGHT: *new_x = x; *new_y = y + 1; break; // Move right
;    }
;}

calculateNextMove proc stdcall x:dword,y:dword,direction:dword,new_x:ptr dword,new_y:ptr dword
	cmp direction,UP
	je up_case
	cmp direction,DOWN
	je down_case
	cmp direction,LEFT
	je left_case
	cmp direction,RIGHT
	je right_case
	jmp end_calculateNextMove
up_case:
	mov ecx,x
	dec	ecx
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	mov	eax,new_y
	mov	[eax],ecx
	jmp end_calculateNextMove
down_case:
	mov	ecx,x
	inc	ecx
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	mov	eax,new_y
	mov	[eax],ecx
	jmp end_calculateNextMove
left_case:
	mov	ecx,x
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	dec	ecx
	mov	eax,new_y
	mov	[eax],ecx
	jmp end_calculateNextMove
;        case RIGHT: *new_x = x; *new_y = y + 1; break; // Move right
right_case:
	mov	ecx,x
	mov	eax,new_x
	mov	[eax],ecx
	mov	ecx,y
	inc	ecx
	mov	eax,new_y
	mov	[eax],ecx
end_calculateNextMove:
	ret
calculateNextMove endp


getFromDriection proc direction:dword
	cmp direction,UP
	je up_getFromDriection
	cmp direction,DOWN
	je down_getFromDriection
	cmp direction,LEFT
	je left_getFromDriection
	cmp direction,RIGHT
	je right_getFromDriection
	ret

	up_getFromDriection:
	mov eax,DOWN
	ret
	down_getFromDriection:
	mov eax,UP
	ret
	left_getFromDriection:
	mov eax,RIGHT
	ret
	right_getFromDriection:
	mov eax,LEFT
	ret
	

getFromDriection endp



pollingMonster	proc
	local i:DWORD
	local monsteroffset:DWORD
	local tmp1,tmp2:DWORD
	push ebx
	mov i,0
	outer_for_pollingMonster:
		mov eax,i
		mov ebx,sizeof(Monster)
		mul ebx
		mov monsteroffset,eax

		;if (this->monsters[i].valid)
		mov ebx,monsteroffset
		mov eax,game.monsters[ebx].valid
		cmp eax,0
		je MonsterNotValid_pollingMonster
			mov ebx,monsteroffset
			invoke moveOneStep,game.monsters[ebx].x,game.monsters[ebx].y \
							,game.monsters[ebx].direction,addr tmp1,addr tmp2 \
							,addr game.monsters[ebx].frac_x ,addr game.monsters[ebx].frac_y\
							,game.monsters[ebx].speed
			cmp eax,1
			jne notMoveCell_pollingMonster
				invoke movMonsterToNextCell	,i
			notMoveCell_pollingMonster:

		MonsterNotValid_pollingMonster:
	inc i
	cmp i,MAX_MONSTER
	jl outer_for_pollingMonster
	pop ebx
	ret
pollingMonster endp
	


movMonsterToNextCell proc index:dword
	local i,j:DWORD
	local direct_able,monster_from:DWORD
	local newX,newY:DWORD
	local before_x,before_y:DWORD
	local move,newMonsterX,newMonsterY:DWORD
	local monsteroffset:DWORD
	push ebx
	push esi
	mov eax,index
	mov i,eax
	mov eax,i
	mov ebx,sizeof(Monster)
	mul ebx
	mov monsteroffset,eax

	;local direct_able,monster_from:DWORD
	mov direct_able,0
	mov monster_from,0

	mov ebx,monsteroffset
	mov esi,game.monsters[ebx].direction
	invoke getFromDriection,esi				
	mov monster_from,eax
	mov j,0
	inner_for_movMonsterToNextCell:
		;local newX,newY:DWORD
		mov ebx,monsteroffset
		mov eax,game.monsters[ebx].x
		mov newX,eax
		mov eax,game.monsters[ebx].y
		mov newY,eax

		cmp j,UP
		je up1_switch_movMonsterToNextCell
		cmp j,DOWN
		je down1_switch_movMonsterToNextCell
		cmp j,LEFT
		je left1_switch_movMonsterToNextCell
		cmp j,RIGHT
		je right1_switch_movMonsterToNextCell
		jmp end_switch1_movMonsterToNextCell

		up1_switch_movMonsterToNextCell:
		dec newX
		jmp end_switch1_movMonsterToNextCell
		down1_switch_movMonsterToNextCell:
		inc newX
		jmp end_switch1_movMonsterToNextCell
		left1_switch_movMonsterToNextCell:
		dec newY
		jmp end_switch1_movMonsterToNextCell
		right1_switch_movMonsterToNextCell:
		inc newY
		jmp end_switch1_movMonsterToNextCell

		end_switch1_movMonsterToNextCell:

		;if (isMoveableMonster(this, newX, newY) && monster_from != j)
		mov esi,monster_from
		cmp esi,j
		je	endif_isMoveableMonster_monster_from_movMonsterToNextCell
		invoke isMoveableMonster,newX,newY
		cmp eax,0
		je endif_isMoveableMonster_monster_from_movMonsterToNextCell
		inc direct_able

		endif_isMoveableMonster_monster_from_movMonsterToNextCell:			
				
	inc j
	cmp j,4
	jl inner_for_movMonsterToNextCell
				
				
	;get last step from monster from
	get_last_step:
	;local before_x,before_y:DWORD
	mov ebx,monsteroffset
	invoke calculateNextMove,game.monsters[ebx].x,game.monsters[ebx].y,monster_from,addr before_x,addr before_y
	cmp direct_able,2
	jl endif_is_corner_movMonsterToNextCell
	invoke isMoveableMonster,before_x,before_y
	cmp eax,0
	je endif_is_corner_movMonsterToNextCell
	invoke changeDirection,i

				
	mov ebx,monsteroffset
	mov game.monsters[ebx].direction,eax
	endif_is_corner_movMonsterToNextCell:

	;local move,newMonsterX,newMonsterY:DWORD
	mov ebx,monsteroffset
	mov esi,game.monsters[ebx].direction
	mov move,esi
	mov esi,game.monsters[ebx].x
	mov newMonsterX,esi
	mov esi,game.monsters[ebx].y
	mov newMonsterY,esi
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

		mov ebx,monsteroffset
		invoke calcMapOffset,game.monsters[ebx].x,
			game.monsters[ebx].y,1

		mov game.map[eax*4]._type,EMPTY
		mov eax,newMonsterX
		mov game.monsters[ebx].x,eax
		mov eax,newMonsterY
		mov game.monsters[ebx].y,eax
		invoke calcMapOffset,newMonsterX,newMonsterY,1
					
		mov game.map[eax*4]._type,MONSTER
		mov esi,i
		mov game.map[eax*4].id,cx

		jmp end_new_pos_not_valid_movMonsterToNextCell
	middle_new_pos_not_valid_movMonsterToNextCell:
	mov ebx,monsteroffset
	invoke changeDirection,i
				
	mov game.monsters[ebx].direction,eax
	end_new_pos_not_valid_movMonsterToNextCell:
	pop esi
	pop ebx
	ret
movMonsterToNextCell endp


changeDirection	proc	index:dword
	local	direction[4]:dword,monster_from:dword,newX:dword,newY:dword
	local	new_direction:dword,available_direction:dword,random_direction:dword
	local	j:DWORD
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
	invoke getFromDriection,game.monsters[ebx].direction
	mov	monster_from,eax
	mov	eax,monster_from
	mov	direction[eax*4],0
	mov j,0
	loop1:
		mov eax,game.monsters[ebx].x
		mov	newX,eax
		mov eax,game.monsters[ebx].y
		mov newY,eax
		invoke calculateNextMove,game.monsters[ebx].x,game.monsters[ebx].y,j,addr newX,addr newY
		invoke isMoveableMonster,newX,newY
		test eax,eax
		jnz not_movable_direction
			mov eax,j
			mov	direction[eax*4],0
		not_movable_direction:
	inc j
	cmp j,4
	jl loop1
	;chose the available direction randomly
	;local	new_direction:dword,available_direction:dword
	mov available_direction,0
	mov new_direction,0
	mov j,0
	loop2:
		mov eax,j
		cmp direction[eax*4],1
		jne count_avail_direction
			mov eax,j
			mov new_direction,eax
			inc available_direction
		count_avail_direction:

	inc j
	cmp j,4
	jl loop2

	cmp available_direction,0
	jne have_available_direction
		mov eax,monster_from
		jmp end_func
	have_available_direction:

	invoke crt_rand
	xor edx,edx
	mov esi,10
	div esi
	mov random_direction,edx
	; for (int j = 0; j < random_direction; j++)
	mov j,0
	cmp random_direction,0
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
	inc j
	mov eax,j
	cmp eax,random_direction
	jl loop3
	end_loop3:
	mov eax,new_direction
	mov game.monsters[ebx].direction,eax
	end_func:
	pop	esi
	pop	ebx
	ret
changeDirection	endp

end