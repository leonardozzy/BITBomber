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
	mov eax,game.player.status
	cmp eax,NORMAL
	je l1_setInvisible
	mov eax,0
	jmp end_setInvisible
l1_setInvisible:
	mov game.player.status,INVISIBLE
	mov game.player.timer,INVISIBLE_TIMER
	mov eax,1
	jmp end_setInvisible
end_setInvisible:
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
	mov eax,game.player.status
	cmp eax,INVISIBLE
	je end_die
	mov eax,game.player.life
	dec eax
	mov game.player.life,eax
	cmp eax,0
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
	mov eax,0

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
	cmp eax,UP
	je up_case
	cmp eax,DOWN
	je down_case
	cmp eax,LEFT
	je left_case
	cmp eax,RIGHT
	je right_case
	jmp end_calculateNextMove
up_case:
	mov ebx,x
	sub ebx,1
	mov new_x,ebx
	mov ebx,y
	mov new_y,ebx

	jmp end_calculateNextMove
down_case:
	mov ebx,x
	add ebx,1
	mov new_x,ebx
	mov ebx,y
	mov new_y,ebx
	jmp end_calculateNextMove

left_case:
	mov ebx,x
	mov new_x,ebx
	mov ebx,y
	sub ebx,1
	mov new_y,ebx
	jmp end_calculateNextMove

;        case RIGHT: *new_x = x; *new_y = y + 1; break; // Move right
right_case:
	mov ebx,x
	mov new_x,ebx
	mov ebx,y
	add ebx,1
	mov new_y,ebx
	jmp end_calculateNextMove

end_calculateNextMove:
	mov eax,0
	ret
calculateNextMove endp

;void pollingMonster(Game *this) {
;    for (int i = 0; i < MAX_MONSTER; i++) {
;        if (this->monsters[i].valid) {
;
;            //判断下一步是否有两个及以上方向可走
;            int direct_able = 0;
;            int monster_from = 0;
;            switch (this->monsters[i].direction) {
;                case UP:
;                    monster_from = DOWN;
;                    break; // Move up
;                case DOWN:
;                    monster_from = UP;
;                    break; // Move down
;                case LEFT:
;                    monster_from = RIGHT;
;                    break; // Move left
;                case RIGHT:
;                    monster_from = LEFT;
;                    break; // Move right
;            }
;            for (int j = 0; j < 4; j++) {
;                int newX = this->monsters[i].x;
;                int newY = this->monsters[i].y;
;
;                switch (j) {
;                    case UP:
;                        newX--;
;                        break; // Move up
;                    case DOWN:
;                        newX++;
;                        break; // Move down
;                    case LEFT:
;                        newY--;
;                        break; // Move left
;                    case RIGHT:
;                        newY++;
;                        break; // Move right
;                }
;                if (isMoveableMonster(this, newX, newY) && monster_from != j) {
;                    direct_able++;
;                }
;            }
;            //get last step from monster from
;            int before_x;
;            int before_y;
;            calculateNextMove(this->monsters[i].x, this->monsters[i].y,
;                              monster_from, &before_x, &before_y);       
;            if (direct_able >= 2 && isMoveableMonster(this, before_x, before_y)) {
;                this->monsters[i].direction = changeDirection(this, i);
;            }
;
;            int move = this->monsters[i].direction;
;            int newMonsterX = this->monsters[i].x;
;            int newMonsterY = this->monsters[i].y;
;            //if moveonestep didn't move the players, which meansnothing will
;            // happen here.
;            moveOneStep(this->monsters[i].x, this->monsters[i].y, move, &newMonsterX, &newMonsterY
;            , &(this->monsters[i].frac_x), &(this->monsters[i].frac_y), this->monsters[i].speed);
;
;            // Check if new position is valid
;            if (isMoveableMonster(this, newMonsterX, newMonsterY)) {
;                // Check if monster encounters the player
;                if (newMonsterX == this->player.x && newMonsterY == this->player.y) {
;                    die(this);
;                }
;                // Move the monster
;                this->map[this->monsters[i].x][this->monsters[i].y][1]._tpye = EMPTY;
;                this->monsters[i].x = newMonsterX;
;                this->monsters[i].y = newMonsterY;
;                this->map[newMonsterX][newMonsterY][1]._tpye = MONSTER;
;                this->map[newMonsterX][newMonsterY][1].id = i;
;            } else {
;                // Change direction if the monster encounters a wall
;                this->monsters[i].direction = changeDirection(this, i);
;
;            }
;        }
;    }
;}


pollingMonster	proc
	local direct_able,monster_from:DWORD
	local before_x,before_y:DWORD
	local newX, newY:DWORD
	local move,newMonsterX,newMonsterY:DWORD
	push esi
	push edi
	push ebx
	
	;push 0 ;direct_able
	;push 0 ;monster_from
	mov ecx,0;i
	;for (int i = 0; i < MAX_MONSTER; i++)
	cmp ecx,MAX_MONSTER
	jge end_pollingMonster
before1_for_pollingMonster:
		push eax	
		mov eax,ecx;BUG!!!
		mov esi,sizeof(Monster)
		mul	esi
		mov esi,eax
		pop eax
		;if (this->monsters[i].valid)
		cmp game.monsters[esi].valid,0
		je end_pollingMonster

			mov eax,game.monsters[esi].direction
			cmp eax,UP
			je up1_pollingMonster
			cmp eax,DOWN
			je down1_pollingMonster
			cmp eax,LEFT
			je left1_pollingMonster
			cmp eax,RIGHT
			je right1_pollingMonster
			jmp next1_pollingMonster

		up1_pollingMonster:
			mov monster_from,DOWN
			jmp next1_pollingMonster
		down1_pollingMonster:
			mov monster_from,UP
			jmp next1_pollingMonster
		left1_pollingMonster:
			mov monster_from,RIGHT
			jmp next1_pollingMonster
		right1_pollingMonster:
			mov monster_from,LEFT
			jmp next1_pollingMonster
		next1_pollingMonster:
			;for (int j = 0; j < 4; j++) garded-do
			mov edx,0;j
		before2_pollingMonster:
				;local newX, newY:DWORD
				mov eax,game.monsters[esi].x
				mov newX,eax
				mov eax,game.monsters[esi].y
				mov newY,eax

				cmp edx,UP
				je up2_switch_pollingMonster
				cmp edx,DOWN
				je down2_switch_pollingMonster
				cmp edx,LEFT
				je left2_switch_pollingMonster
				cmp edx,RIGHT
				je right2_switch_pollingMonster
				jmp next22_pollingMonster

			up2_switch_pollingMonster:
				sub newX,1
				jmp next22_pollingMonster
			down2_switch_pollingMonster:
				add newX,1
				jmp next22_pollingMonster

			left2_switch_pollingMonster:
				sub newY,1
				jmp next22_pollingMonster

			right2_switch_pollingMonster:
				add newY,1
				jmp next22_pollingMonster
			next22_pollingMonster:
				cmp monster_from,edx
				je next3_pollingMonster
				invoke isMoveableMonster,newX,newY
				cmp eax,0
				je next3_pollingMonster
				add direct_able,1
			next3_pollingMonster:
			inc edx
			cmp edx,4
			jl before2_pollingMonster
		next2_pollingMonster:
			;get last step from monster from
			invoke calculateNextMove,game.monsters[esi].x,
									game.monsters[esi].y,
									monster_from,
									addr before_x,
									addr before_y
			cmp direct_able,2
			jl next4_pollingMonster
			invoke isMoveableMonster,before_x,before_y
			cmp eax,0
			je next4_pollingMonster
			invoke changeDirection,ecx
			mov game.monsters[esi].direction,eax
		next4_pollingMonster:
			;local move,newMonsterX,newMonsterY:DWORD
			mov eax,game.monsters[esi].direction
			mov move,eax
			mov eax,game.monsters[esi].x
			mov newMonsterX,eax
			mov eax,game.monsters[esi].y
			mov newMonsterY,eax
			invoke moveOneStep,game.monsters[esi].x,
								game.monsters[esi].y,
								move,
								addr newMonsterX,
								addr newMonsterY, 
								addr game.monsters[esi].frac_x,
								addr game.monsters[esi].frac_y,
								game.monsters[esi].speed
			;Check if new position is valid
			invoke isMoveableMonster,newMonsterX,newMonsterY
			cmp eax,0
			je next6_pollingMonster
				mov eax,newMonsterX
				cmp eax,game.player.x
				jne next5_pollingMonster
				mov eax,newMonsterY

				cmp eax,game.player.y
				jne next5_pollingMonster
				invoke die
				jmp next6_pollingMonster

			next5_pollingMonster:
			;move the monster
			invoke calcMapOffset,game.monsters[esi].x,game.monsters[esi].y,1
			mov game.map[eax*4]._type,EMPTY
			push eax
			mov eax,game.monsters[esi].x
			mov eax,newMonsterX
			mov game.monsters[esi].x,eax
			mov eax,game.monsters[esi].y

			pop eax

			invoke calcMapOffset,newMonsterX,newMonsterY,1
			mov game.map[eax*4]._type,MONSTER
			invoke calcMapOffset,newMonsterX,newMonsterY,1
			mov game.map[eax*4].id,cx

			jmp next7_pollingMonster
		next6_pollingMonster:
			invoke changeDirection,ecx
			mov game.monsters[esi].direction,eax
			jmp next7_pollingMonster
		next7_pollingMonster:

	inc ecx
	cmp ecx,MAX_MONSTER
	jl before1_for_pollingMonster
end_pollingMonster:
	;pop eax
	;pop eax
	mov eax,0
	pop ebx
	pop edi
	pop esi
	ret
pollingMonster endp


;int changeDirection(Game *this, int index) {
;    int direction[4] = { 1,1,1,1 };
;    //去掉monster来的方向
;    int monster_from = 0;
;    switch (this->monsters[index].direction) {
;        case UP: monster_from = DOWN; break; // Move up
;        case DOWN: monster_from = UP; break; // Move down
;        case LEFT: monster_from = RIGHT; break; // Move left
;        case RIGHT: monster_from = LEFT; break; // Move right
;    }
;    direction[monster_from] = 0;
;    for (int j = 0; j < 4; j++) {
;        int newX = this->monsters[index].x;
;        int newY = this->monsters[index].y;
;        calculateNextMove(this->monsters[index].x, this->monsters[index].y, j, &newX, &newY);
;        if (!isMoveableMonster(this, newX, newY)) {
;            direction[j] = 0;
;        }
;    }
;    //chose the available direction randomly
;    int available_direction = 0;
;    int new_direction = 0;
;    for (int j = 0; j < 4; j++) {
;        if (direction[j] == 1) {
;            new_direction = j;
;            available_direction++;
;        }
;    }
;    if (available_direction == 0) {
;        return monster_from;
;    }
;    int random_direction = rand() % 10;
;    for (int j = 0; j < random_direction; j++) {
;        new_direction++;
;        new_direction %= 4;
;        while (1) {
;            if (direction[new_direction] == 1) {
;                break;
;            }
;            else {
;                new_direction++;
;                new_direction %= 4;
;            }
;        }
;    }
;    this->monsters[index].direction = new_direction;
;    return new_direction;
;}


changeDirection proc stdcall index:dword
	local direction[4]:DWORD
	local monster_from:DWORD
	local newX,newY:DWORD
	local available_direction,new_direction:DWORD
	local random_direction:DWORD
	push esi
	push edi
	push eax
	mov eax,index;BUG!!!
	mov edi,sizeof(Monster)
	mul	edi
	mov edi,eax
	pop eax


	mov eax,game.monsters[edi].direction
	cmp eax,UP
	je up1_switch_changeDirection
	cmp eax,DOWN
	je down1_switch_changeDirection
	cmp eax,LEFT
	je left1_switch_changeDirection
	cmp eax,RIGHT
	je right1_switch_changeDirection
	jmp next1_changeDirection

up1_switch_changeDirection:
	mov monster_from,DOWN
	jmp next1_changeDirection
down1_switch_changeDirection:
	mov monster_from,UP
	jmp next1_changeDirection
left1_switch_changeDirection:
	mov monster_from,RIGHT
	jmp next1_changeDirection
right1_switch_changeDirection:
	mov monster_from,LEFT
	jmp next1_changeDirection
next1_changeDirection:

	mov eax,monster_from
	mov direction[eax],0

	mov ecx,0;j
before2_changeDirection:
	cmp ecx,4
	jge next2_changeDirection
		;local newX,newY:DWORD
		push eax
		mov eax,game.monsters[edi].x
		mov newX,eax
		mov eax,game.monsters[edi].y
		mov newY,eax
		pop eax

invoke calculateNextMove,game.monsters[edi].x,
		game.monsters[edi].y,ecx,addr newX, addr newY
		invoke isMoveableMonster,newX,newY
		cmp eax,0
		jne next33_changeDirection
		mov direction[ecx],0
	next33_changeDirection:
	inc ecx
	jmp before2_changeDirection
next2_changeDirection:
	;chose the available direction randomly
	;local available_direction,new_direction:DWORD
	mov available_direction,0
	mov new_direction,0
	mov ecx,0;j
before3_changeDirection:
	cmp ecx,4
	jge next3_changeDirection
		cmp direction[ecx],1
		jne next4_changeDirection
		mov new_direction,ecx
		add available_direction,1
	next4_changeDirection:
	inc ecx
	jmp before3_changeDirection
next3_changeDirection:



	cmp available_direction,0
	jne next5_changeDirection
		mov eax,monster_from
		ret
next5_changeDirection:
	;int random_direction = rand() % 10;
	;local random_direction:DWORD
	invoke crt_rand
	mov esi,10
	div esi
	mov random_direction,edx
	mov ecx,0;j
before6_changeDirection:
	cmp ecx,random_direction
	jge next6_changeDirection
		inc new_direction
		mov eax,new_direction
		mov esi,4
		div esi
		mov new_direction,edx
		while1_changeDirection:
			cmp direction[new_direction],1
			je next7_changeDirection
			inc new_direction
			mov eax,new_direction
			mov esi,4
			div esi
			mov new_direction,edx
		next7_changeDirection:
	inc ecx
	jmp before6_changeDirection
next6_changeDirection:
	mov eax,new_direction
	mov game.monsters[edi].direction,eax

	pop edi
	pop esi
	ret
changeDirection endp


end
