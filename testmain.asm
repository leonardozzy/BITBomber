.486
.model	flat,stdcall
option	casemap:none

include	common.inc
extrn   game:Game
.const
CHAR_MAP    byte    ".#PBM=TFDWA"

.code
draw    proc
    local   i:dword,j:dword,k:dword,tmp:dword
   ; invoke  crt_printf,offset ADDR_STR,offset game.map
    mov i,0
loop1_draw:
    cmp i,ROW
    je  exitLoop1_draw
    mov j,0
loop2_draw:
    cmp j,COL
    je  exitLoop2_draw
    mov tmp,'.'
    mov k,0
loop3_draw:
    cmp k,DEPTH
    je  exitLoop3_draw
    invoke  calcMapOffset,i,j,k
    movzx   eax,game.map[eax*4]._type
    cmp eax,EMPTY
    je  loop3NoDraw_draw
    movzx   edx,[eax+CHAR_MAP]
    mov tmp,edx
loop3NoDraw_draw:
    inc k
    jmp loop3_draw
exitLoop3_draw:
    invoke  crt_putchar,tmp
    inc j
    jmp loop2_draw
exitLoop2_draw:
    invoke  crt_putchar,0ah
    inc i
    jmp loop1_draw
exitLoop1_draw:
    invoke  crt_puts,offset SPLIT_STR
    invoke  crt_printf,offset BOMB_RANGE_STR,game.player.bomb_range
    invoke  crt_printf,offset BOMB_CNT_STR,game.player.bomb_cnt
    invoke  crt_printf,offset SPEED_STR,game.player.speed
    invoke  crt_printf,offset MONSTER_NUM_STR,game.monster_num
    invoke  crt_puts,offset SPLIT_STR
    ret
draw    endp

start:
	invoke  initGame
    invoke  crt_time,NULL
    invoke  crt_srand,eax
loop_start:
    invoke  draw
    invoke  readKey
    ;push    eax
    ;invoke  crt_printf,offset PRINT_INT_STR,eax
    ;pop eax
    cmp eax,-1
    je  noPlayer_start
    invoke  pollingPlayer,eax
noPlayer_start:
    invoke  pollingMonster
    invoke  pollingBomb
    invoke  pollingTool
    invoke  pollingSuccess
    invoke  pollingBoss
    invoke  pollingAttack
    invoke  Sleep,100
    invoke  crt_system,offset CLS_STR
    jmp loop_start
end start
