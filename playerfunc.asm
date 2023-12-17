.486
.model	flat,stdcall
option	casemap:none
include common.inc
extrn   game:Game
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
            sal ecx, 4  ;tool_index *= sizeof(tool)
            cmp game.tools[ecx]._type, 0
            jne JO0_pollingPlayer
                inc game.player.life
                jmp ToolSwEnd_pollingPlayer
            JO0_pollingPlayer:
            cmp game.tools[ecx]._type, 1
            jne JO1_pollingPlayer
                inc game.player.bomb_range
                jmp ToolSwEnd_pollingPlayer
            JO1_pollingPlayer:
            cmp game.tools[ecx]._type, 2
            jne JO2_pollingPlayer
                inc game.player.bomb_cnt
                jmp ToolSwEnd_pollingPlayer
            JO2_pollingPlayer:
            cmp game.tools[ecx]._type, 3
            jne JO3_pollingPlayer
                inc game.player.speed
                jmp ToolSwEnd_pollingPlayer
            JO3_pollingPlayer:
            cmp game.tools[ecx]._type, 4
            jne JO4_pollingPlayer
                add game.timer,30
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
local ismove
mov ismove,0
push ebx
    mov edx, speed
    mov ecx, pfrac_x
    cmp direction, UP
    jne JOup_moveOneStep
        sub [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOup_moveOneStep:
    cmp direction, DOWN
    jne JOdown_moveOneStep
        add [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOdown_moveOneStep:
    mov ecx, pfrac_y
    cmp direction, LEFT
    jne JOleft_moveOneStep
        sub [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOleft_moveOneStep:
    cmp direction, RIGHT
    jne JOright_moveOneStep
        add [ecx], edx
        jmp dirSwEnd_moveOneStep
    JOright_moveOneStep:
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

end 
