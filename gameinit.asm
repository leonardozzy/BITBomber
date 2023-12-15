.486
.model	flat,stdcall
option	casemap:none

include common.inc

.code
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
    invoke  crt_memset,game.map,0,ROW*COL*DEPTH*sizeof Object
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
setMonster1_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[ebx*4].id,dx
    inc game.monster_num
    invoke  initMonster,game.monster_num,esi,edi,MONSTER_1_SPEED
    jmp setMap_initLevel
setMonster2_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[ebx*4].id,dx
    inc game.monster_num
    invoke  initMonster,game.monster_num,esi,edi,MONSTER_2_SPEED
    jmp setMap_initLevel
setMonster3_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[ebx*4].id,dx
    inc game.monster_num
    invoke  initMonster,game.monster_num,esi,edi,MONSTER_3_SPEED
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
    mov game.map[eax*4]._type,PLAYER
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
    jz  exitLoop1_dealBomb
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
    invoke  calcMapOffset,x,y,0
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
    ;invoke  die    ;暂时注释，函数实现后取消注释
    jmp exit_clear
box_clear:
    mov game.map[eax*4]._type,EMPTY
    invoke  crt_rand
    and eax,3
    cmp eax,1
    jne exit_clear
    ;invoke  placeTool,x,y  ;暂时注释，函数实现后取消注释
    jmp exit_clear
boss_clear:
    dec game.boss.life
    cmp game.boss.life,0
    jne exit_clear
    invoke  crt_puts,offset WIN_STR
    invoke  crt_exit,0
    jmp exit_clear
clear   endp

clearFire   proc    x:dword,y:dword
    invoke  calcMapOffset,x,y,2
    mov game.map[eax*4]._type,EMPTY
    ret
clearFire   endp

end