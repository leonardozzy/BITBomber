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
	cmp	game.monsters[ebx].direction,UP
	je	monsterMoveUp_pollingMonster
	cmp	game.monsters[ebx].direction,DOWN
	je	monsterMoveDown_pollingMonster
	cmp	game.monsters[ebx].direction,LEFT
	je	monsterMoveLeft_pollingMonster
	mov	monster_from,LEFT
	jmp	exitSwitch1_pollingMonster
monsterMoveUp_pollingMonster:
	mov	monster_from,DOWN
	jmp	exitSwitch1_pollingMonster
monsterMoveDown_pollingMonster:
	mov	monster_from,UP
	jmp	exitSwitch1_pollingMonster
monsterMoveLeft_pollingMonster:
	mov	monster_from,RIGHT
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

end
