; Binary turtle

section .text
global turtle

;ebp-4 turtle x posistion
;ebp-8 turtle y posistion
;ebp-12 turtle color RRGGBB
;ebp-16 turtle direction
;ebp-20 pen 0-on/1-off
;ebp-24 move value


turtle:
push ebp
mov ebp, esp
sub esp, 24 			; space for local variables
mov edi, DWORD [ebp+8] 	; bmp file address in edi
mov esi, DWORD [ebp+12] ; bin file address in esi
mov eax, DWORD [ebp+16] ; commands amount in eax
jmp load_word

load_word:
cmp eax, 0 
je endi
mov ecx, 0
mov ch, BYTE [esi]
inc esi
mov cl, BYTE [esi] 		; cx has 16 bits word
dec eax
dec eax
mov dx, 1100000000000000b
and dx, cx
cmp dx, 0000000000000000b
je set_dir
cmp dx, 0100000000000000b
je set_pos
cmp dx, 1000000000000000b
je set_pen
cmp dx, 1100000000000000b
je move


set_dir:
mov edx, 0000000000000011b
and dx, cx
mov DWORD [ebp-16], edx	; set new direction
inc esi
jmp load_word


set_pos:
inc esi
mov ecx, 0
mov ch, BYTE [esi]
inc esi
mov cl, BYTE [esi]		; cx has 16 bits word
dec eax
dec eax


mov edx, 1111110000000000b
and edx, ecx
shr edx, 10
mov DWORD[ebp-8], edx	; loading new y value

mov edx, 0
mov edx, 1111111111b
and edx, ecx
mov DWORD[ebp-4], edx	; loading new x value
inc esi
jmp load_word


move:
mov edx, 1111111111b
and edx, ecx
mov DWORD[ebp-24], edx	; move value update

mov edx, DWORD[ebp-16] 	; direction check
mov ebx, 0
cmp ebx, edx
je move_up

mov ebx, 1
cmp ebx, edx
je move_left

mov ebx, 2
cmp ebx, edx
je move_down

mov ebx, 3
cmp ebx, edx
je move_right


end_move:
inc esi
jmp load_word

;================================================

move_up:
mov edx, DWORD[ebp-24]
cmp edx, 0					;chceck if move ends
je	end_move	
dec edx
mov DWORD[ebp-24], edx
mov	edx, DWORD[ebp-8]
inc edx
mov DWORD[ebp-8], edx
jmp check_up

check_up:
mov ebx, 49
mov	edx, DWORD[ebp-8]
cmp edx, ebx
jle move_up_2
mov edx, 49
mov DWORD[ebp-8], edx
jmp move_up_2

move_up_2:
mov ebx, 1
mov edx, DWORD[ebp-20]
cmp ebx, edx			;check if pen is up or down
je 	move_up
call put_pixel
jmp move_up

;================================================

move_down:
mov edx, DWORD[ebp-24]
cmp edx, 0					;chceck if move ends
je	end_move	
dec edx
mov DWORD[ebp-24], edx
mov	edx, DWORD[ebp-8]
dec edx
mov DWORD[ebp-8], edx
jmp check_down

check_down:
mov ebx, 0
mov	edx, DWORD[ebp-8]
cmp edx, ebx
jge move_down_2
mov edx, 0
mov DWORD[ebp-8], edx
jmp move_down_2

move_down_2:
mov ebx, 1
mov edx, DWORD[ebp-20]
cmp ebx, edx			;check if pen is up or down
je 	move_down
call put_pixel
jmp move_down

;================================================

move_right:
mov edx, DWORD[ebp-24]
cmp edx, 0					;chceck if move ends
je	end_move	
dec edx
mov DWORD[ebp-24], edx
mov	edx, DWORD[ebp-4]
inc edx
mov DWORD[ebp-4], edx
jmp check_right

check_right:
mov ebx, 599
mov	edx, DWORD[ebp-4]
cmp edx, ebx
jle move_right_2
mov edx, 599
mov DWORD[ebp-4], edx
jmp move_right_2

move_right_2:
mov ebx, 1
mov edx, DWORD[ebp-20]
cmp ebx, edx			;check if pen is up or down
je 	move_right
call put_pixel
jmp move_right

;================================================

move_left:
mov edx, DWORD[ebp-24]
cmp edx, 0					;chceck if move ends
je	end_move	
dec edx
mov DWORD[ebp-24], edx
mov	edx, DWORD[ebp-4]
dec edx
mov DWORD[ebp-4], edx
jmp check_left

check_left:
mov ebx, 0
mov	edx, DWORD[ebp-4]
cmp edx, ebx
jge move_left_2
mov edx, 0
mov DWORD[ebp-4], edx
jmp move_left_2

move_left_2:
mov ebx, 1
mov edx, DWORD[ebp-20]
cmp ebx, edx			;check if pen is up or down
je 	move_left
call put_pixel
jmp move_left

;================================================
set_pen:
mov edx, 1000000000000b
and edx, ecx
shr edx, 12
mov DWORD[ebp-20], edx	; 0-down/1-up update

mov edx, 1111b
and dx, cx
shl dx, 8

mov ebx, 11110000b
and ebx, ecx
shr ebx, 4
add edx, ebx
shl edx, 8

mov ebx, 111100000000b
and bx, cx
shr ebx, 8
add dx, bx
shl edx, 4
mov DWORD[ebp-12], edx	; color update

inc esi
jmp load_word
 

;========================================
put_pixel:
;[ebp-4] x
;[ebp-8] y
;[ebp-12] color 0xRRGGBB
mov ebx, edi
add ebx, 10
mov dx, WORD[ebx]
add edx, edi ;addr of bmp in edx

mov ebx, DWORD[ebp-8]
lea ebx, [ebx + ebx*8] ;*9
lea ebx, [ebx + ebx*4] ;*5
lea ebx, [ebx + ebx*4] ;*5
shl ebx, 3 ;*8
;1800 * y in ebx
add edx, ebx ;addr of line in edx
mov ebx, [ebp-4] ;pixel addr in edx
lea ebx, [ebx + ebx*2]
add edx, ebx ;pixel address in edx

mov ebx, 0
mov ebx, DWORD[ebp-12] ;color RRGGBB 3bytes
mov BYTE[edx], bl ;store blue
shr ebx, 8
mov BYTE[edx+1], bl ;store greeen
shr ebx, 8
mov BYTE[edx+2], bl ;store red
ret

;========================================

endi:
 mov eax, 0
 mov esp, ebp
 pop ebp
 ret

