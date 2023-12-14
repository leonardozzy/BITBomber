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
    local   file:dword,num:dword,i:dword,j:dword
    invoke  crt_memset,game.map,0,ROW*COL*DEPTH*sizeof Object
    mov edx,game.level
    invoke  crt_fopen,LEVEL_FILE_NAMES[4*edx-4],offset OPEN_FILE_READ_ONLY
    test    eax,eax
    jnz  fileFound_initLevel
    invoke  crt_exit,1
    ret
fileFound_initLevel:
    mov file,eax
    mov game.monster_num,0
    mov i,0
outerLoop_initLevel:
    cmp i,ROW
    je  exitOuterLoop_initLevel
    mov j,0
innerLoop_initLevel:
    cmp j,COL
    je  exitInnerLoop_initLevel
    invoke  crt_fscanf,file,offset ONE_INT_FORMAT,addr num
    invoke  calcMapOffset,i,j,1
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
    mov game.map[eax*4].id,dx
    inc game.monster_num
    push    eax
    invoke  initMonster,game.monster_num,i,j,MONSTER_1_SPEED
    pop eax
    jmp setMap_initLevel
setMonster2_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[eax*4].id,dx
    inc game.monster_num
    push    eax
    invoke  initMonster,game.monster_num,i,j,MONSTER_2_SPEED
    pop eax
    jmp setMap_initLevel
setMonster3_initLevel:
    mov num,MONSTER
    mov edx,game.monster_num
    mov game.map[eax*4].id,dx
    inc game.monster_num
    push    eax
    invoke  initMonster,game.monster_num,i,j,MONSTER_3_SPEED
    pop eax
    jmp setMap_initLevel
setBoss_initLevel:
    push    eax
    invoke  initBoss,i,j
    pop eax
    jmp setMap_initLevel
setMap_initLevel:
    mov edx,num
    mov game.map[eax*4]._type,dx
    inc j
    jmp innerLoop_initLevel
exitInnerLoop_initLevel:
    inc i
    jmp outerLoop_initLevel
exitOuterLoop_initLevel:
    invoke  crt_fscanf,file,offset ONE_INT_FORMAT,offset game.timer
    mov eax,game.timer
    mov game.level_timer,eax
    invoke  crt_fclose,file
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

end