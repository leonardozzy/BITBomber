.486
.model	flat,stdcall
option	casemap:none

include	common.inc

.code
placeBomb	proc	
push ebx
    cmp game.player.bomb_cnt,0
    jng ret_placeBomb
    invoke calcMapOffset,game.player.x,game.player.y,0
    cmp game.map[4*eax]._type,EMPTY
    jne ret_placeBomb
    ;;;if (this->player.bomb_cnt > 0 && this->map[this->player.x][this->player.y][0].type==EMPTY) {
    ; Find an empty slot for a new bomb
    mov ebx,MAX_BOMB
    sal ebx,4   ;ebx = MAX_BOMB * sizeof(Bomb)=16
    mov ecx,0
    ALLBOMB_LOOP_placeBomb:
        cmp game.bombs[ecx].timer, 0    ;Assuming a bomb's timer <= 0 means it's inactive
        jg ALLBOMB_LOOPEND_placeBomb 
            mov edx, game.player.x
            mov game.bombs[ecx].x, edx
            mov edx, game.player.y
            mov game.bombs[ecx].y, edx
            mov edx, BOMB_TIMER
            add edx, FIRE_TIMER
            mov game.bombs[ecx].timer, edx    ;Set a timer for the bomb
            mov edx, game.player.bomb_range
            mov game.bombs[ecx].range, edx
            mov dx , BOMB
            mov game.map[4*eax]._type, dx
            mov edx, game.player.bomb_cnt
            dec edx
            mov game.player.bomb_cnt, edx
            jmp ret_placeBomb
        ALLBOMB_LOOPEND_placeBomb:
        add ecx, 16 ;add sizeof(Bomb) per loop
        cmp ecx, ebx
        jb ALLBOMB_LOOP_placeBomb
ret_placeBomb:
pop ebx
	ret
placeBomb	endp

pollingPlayer	proc	input:dword
	local	newPlayerX:dword, newPlayerY:dword
push ebx
    mov input, edx
    cmp edx, SETBOMB
    jne JmpOver_placeBomb_pollingPlayer
        invoke placeBomb
        jmp ret_pollingPlayer   ; Early return as no movement is required
    JmpOver_placeBomb_pollingPlayer:
    ; deal with player status
    mov eax, game.player.status
    cmp eax, INVISIBLE
    jne JmpOverINVISIBLE_pollingPlayer
        mov eax, game.player.timer
        dec eax
        mov game.player.timer, eax
        cmp eax,0
        jne JmpOverINVISIBLE_pollingPlayer
            mov eax, NORMAL
            mov game.player.status, eax
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
    cmp eax, 0
    je JmpOver_isMoveable_pollingPlayer
        ; Check for collision with monsters
        invoke calcMapOffset, newPlayerX, newPlayerY, 0
        cmp game.map[eax*4 + 4]._type, MONSTER
        jne JmpOverMonster_pollingPlayer
            push eax
            invoke die
            pop eax
            jmp ret_pollingPlayer
        JmpOverMonster_pollingPlayer:
        cmp game.map[eax*4]._type, TOOL
        jne JmpOverTool_pollingPlayer
            mov cx, game.map[eax*4].id
            sal cx, 4  ;tool_index *= sizeof(tool)
            movzx ecx,cx
            mov ebx, game.tools[ecx]._type
            cmp ebx, 0
            jne JO0_pollingPlayer
                mov edx, game.player.life
                inc edx
                mov game.player.life ,edx
                jmp ToolSwEnd_pollingPlayer
            JO0_pollingPlayer:
            cmp ebx, 1
            jne JO1_pollingPlayer
                mov edx, game.player.bomb_range
                inc edx
                mov game.player.bomb_range, edx
                jmp ToolSwEnd_pollingPlayer
            JO1_pollingPlayer:
            cmp ebx, 2
            jne JO2_pollingPlayer
                mov edx, game.player.bomb_cnt
                inc edx
                mov game.player.bomb_cnt, edx
                jmp ToolSwEnd_pollingPlayer
            JO2_pollingPlayer:
            cmp ebx, 3
            jne JO3_pollingPlayer
                mov edx, game.player.speed
                inc edx
                mov game.player.speed, edx
                jmp ToolSwEnd_pollingPlayer
            JO3_pollingPlayer:
            cmp ebx, 4
            jne JO4_pollingPlayer
                mov edx, game.timer
                add edx, 30
                mov game.timer, edx
                jmp ToolSwEnd_pollingPlayer
            JO4_pollingPlayer:
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
pop ebx
	ret
pollingPlayer	endp

isMoveable  proc    x:dword, y:dword
    invoke calcMapOffset, x, y, 0
    mov cx, game.map[eax*4]._type
    cmp cx, BOMB
    je ret_0_isMoveable
    mov cx, game.map[eax*4+4]._type
    cmp cx, BOX
    je ret_0_isMoveable
    cmp cx, WALL
    je ret_0_isMoveable
    mov eax,1   ; none of above,ret 1
    jmp ret_isMoveable
ret_0_isMoveable:
    mov eax, 0
ret_isMoveable:
    ret
isMoveable  endp

isMoveableMonster   proc    x:dword, y:dword
    invoke isMoveable, x, y
    cmp eax, 0
    je ret_0_isMoveableMonster
    invoke calcMapOffset, x, y, 1
    mov dx, game.map[eax*4]._type
    cmp dx, MONSTER
    je ret_0_isMoveableMonster
    mov eax,1   ; none of above,ret 1
    jmp ret_isMoveableMonster
ret_0_isMoveableMonster:
    mov eax,0
ret_isMoveableMonster:
    ret
isMoveableMonster   endp

moveOneStep proc    x:dword, y:dword, direction:dword \
    , pnew_x:ptr dword, pnew_y:ptr dword, pfrac_x:ptr dword \
    , pfrac_y:ptr dword, speed:dword
push ebx
    mov edx, speed
    mov ecx, pfrac_x
    cmp direction, UP
    je JOup_moveOneStep
        sub [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOup_moveOneStep:
    cmp direction, DOWN
    je JOdown_moveOneStep
        add [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOdown_moveOneStep:
    mov ecx, pfrac_y
    cmp direction, LEFT
    je JOleft_moveOneStep
        sub [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOleft_moveOneStep:
    cmp direction, RIGHT
    je JOright_moveOneStep
        add [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOright_moveOneStep:
    dirSwEnd_moveOneStep:
    mov ebx, FRAC_RANGE
    sal ebx,1   ;ebx = 2*FRAC_RANGE
    mov ecx, pfrac_x
    mov eax, FRAC_RANGE
    cmp [ecx], eax
    jng JOxgreat_moveOneStep
        mov eax, x
        add eax, 1
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        mov edx, pnew_y
        mov [edx],eax
        mov edx, pfrac_x
        sub [edx], ebx
        jmp fracOverSwEnd_moveOneStep
    JOxgreat_moveOneStep:
    mov eax, FRAC_RANGE
    neg eax
    cmp [ecx], eax
    jnl JOxless_moveOneStep
        mov eax, x
        sub eax, 1
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
    mov eax, FRAC_RANGE
    cmp [ecx], eax
    jng JOygreat_moveOneStep
        mov eax, x
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        add eax, 1
        mov edx, pnew_y
        mov [edx],eax
        mov edx, pfrac_y
        sub [edx], ebx
        jmp fracOverSwEnd_moveOneStep
    JOygreat_moveOneStep:
    mov eax, FRAC_RANGE
    neg eax
    cmp [ecx], eax
    jnl JOyless_moveOneStep
        mov eax, x
        mov edx, pnew_x
        mov [edx],eax
        mov eax, y
        sub eax, 1
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



end 