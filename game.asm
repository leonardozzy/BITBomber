.386
.model flat, stdcall
option casemap:none
include common.inc
.code

clearFire proc	x:dword,y:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,EMPTY
	ret
clearFire ENDP

preAttack proc C x:dword,y:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,ATTACK
	ret
preAttack ENDP

makeAttack proc C x:dword,y:dword
	invoke calcMapOffset,x,y,2
	mov game.map[eax*4]._type,BLUEFIRE
	;invoke clear,x,y;ÔÝÊ±×¢ÊÍ
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

bossDrop proc C
	mov game.boss.in_map,1
	invoke dealAttack,game.boss.x,game.boss.y,offset clear
bossDrop endp

pollingBoss proc C
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

end