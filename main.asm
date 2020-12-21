; BSD 2-Clause License
; 
; Copyright (c) 2020, timre13
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
; 1. Redistributions of source code must retain the above copyright notice, this
;    list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[org 0x7c00]
[bits 16]


%define SHOW_PALETTE_SCREEN

;################# Constants ###################;
SECTOR_NUM_TO_READ equ 3        ; Adjust when game gets bigger

BALL_COLOR         equ 0x2a
BALL_SIZE          equ 8        ; Resize ball bitmap if changed!
BALL_SPEED         equ 2

SEP_LINE_COLOR     equ 0x09

GAME_OVER_SCR_CLR  equ 0xde

PLAYER_1_SPEED     equ 20
PLAYER_COLOR       equ 0x32
PLAYER_HEIGHT      equ 32
PLAYER_WIDTH       equ 4
;PLAYER_1_X         equ 10-PLAYER_WIDTH/2
;PLAYER_2_X         equ SCREEN_W-10-PLAYER_WIDTH/2
PLAYER_1_X         equ 0
PLAYER_2_X         equ SCREEN_W-PLAYER_WIDTH

PLAY_UNTIL_SCORE   equ 10

FRAME_DELAY_MS     equ 10000

TRUE               equ 1
FALSE              equ 0


;***********************************************;
; Entry point.
;***********************************************;
entry:
    ; Save the boot drive number
    mov [boot_drive_num], dl
    

    ; Set up the stack
    xor bp, bp
    mov sp, bp
    mov ss, bp


    mov eax, welcome_msg
    call print_string

    call read_disk
    call switch_to_vga_mode
    mov eax, ok_msg
    call print_string
%ifdef SHOW_PALETTE_SCREEN
    call draw_palette

    call wait_for_keypress
%endif
    
    call clear_screen

    call setup_key_repeat

.main_loop:
    call draw_separator_line

;-------------- Draw ball -------------

    mov ax, [ball_x]
    mov cx, [ball_y]
    call draw_ball

;----- Handle player 2 movement -------

    call get_random8
    cmp ax, 150                     ; Higher value = better bot
    jge .player_2_move_end

    mov ax, [ball_y]
    sub ax, PLAYER_HEIGHT/2+BALL_SIZE/2
    mov cx, [player_2_y]
    cmp cx, ax
    jl .player_2_y_less
    jg .player_2_y_greater
    jmp .player_2_move_end
.player_2_y_less:
    add word [player_2_y], BALL_SPEED
    jmp .player_2_move_end
.player_2_y_greater:
    sub word [player_2_y], BALL_SPEED
.player_2_move_end:

;------------- Draw players -----------

    mov ax, PLAYER_1_X
    mov cx, [player_1_y]
    call draw_player

    mov ax, PLAYER_2_X
    mov cx, [player_2_y]
    call draw_player

    call draw_player_scores

;----------- Handle keypresses --------
    call handle_keypresses


;------ Ball bouncing from edges ------
    call handle_ball_bouncing_from_edges

;------------- Move ball --------------
    call move_ball

    cmp byte [player_1_score], 10
    jl .not_game_over1
    jmp .game_over
.not_game_over1:
    cmp byte [player_2_score], 10
    jl .not_game_over2
    jmp .game_over
.not_game_over2:
    mov eax, FRAME_DELAY_MS
    call wait_for_microsecs                 ; Wait some time

    call clear_screen

    jmp .main_loop              ; Repeat the main loop

.game_over:
    call show_game_over_screen
    jmp halt_loop

;***********************************************;
; Print zero-terminated string.
;
; Arguments:
;   EAX = Source address
;***********************************************;
print_string:
    push bx
    push esi

    mov esi, eax
    mov ah, 0x0e
    xor bh, bh
    mov bl, 0x0f

.loop_:
    mov al, [esi]
    cmp al, 0                   ; If found a null-byte
    jz .end                     ; Exit
    int 0x10
    inc esi                     ; Next byte
    jmp .loop_
    
.end:
    pop esi
    pop bx
    ret


;***********************************************;
; Read the non-first partitons to the memory.
;***********************************************;
; FIXME: This function fails with error code 0x02 on real hardware. Why?
read_disk:
    push bx
    push di
    push es

    xor di, di                  ; Number of disk read tries

.loop_:
    xor ah, ah
    mov dl, [boot_drive_num]
    int 0x13                    ; Reset the drive

    jnc .drive_reset_success

    mov eax, disk_reset_err_msg
    call print_string
    mov al, ah
    call uint8_to_hex_str
    call print_string

.drive_reset_success:

    mov ah, 0x02                ; Function: Read sectors
    mov al, SECTOR_NUM_TO_READ  ; Num of sectors
    mov ch, 0x00                ; Cylinder
    mov cl, 0x02                ; Sector
    xor dx, dx
    mov es, dx                  ; Destination segment
    mov dh, 0x00                ; Head
    mov dl, [boot_drive_num]    ; Drive number
    mov bx, second_partition    ; Destination address
    int 0x13                    ; Do the read

    jnc .success                ; If no error, jump after error write

    mov bh, ah                  ; Save the status code
    mov bl, al                  ; Save the # of sectors read

    inc di                      ; Tried one more time
    
    mov eax, disk_read_err_msg1
    call print_string           ; Print the first part of the message
    mov al, bh                  ; Load the status code
    call uint8_to_hex_str
    call print_string           ; Print the disk status code
    mov eax, disk_read_err_msg2
    call print_string           ; Print the second part of the message
    mov al, bl                  ; Load the sector read count
    call uint8_to_hex_str
    call print_string           ; Print the number of sectors read
    mov eax, disk_read_err_msg3
    call print_string           ; Print the third part of the message

    cmp di, 5
    jl .loop_

    jmp halt_loop               ; If failed after 5 tries, halt

.success:
    mov ax, ok_msg
    call print_string

    pop es
    pop di
    pop bx
    ret


;***********************************************;
; Convert a 8-bit unsigned int to hex string.
; Arguments:
;   AL = input
; Returns: EAX = pointer to output
;***********************************************;
uint8_to_hex_str:
    mov cl, al
    
    shr cl, 4
    mov byte [.output_str], cl
    add byte [.output_str], '0'
    cmp byte [.output_str], '9'     ; If the digit is greater, than 9
    jng .second_digit
    add byte [.output_str], 7       ; Add 7 to make it a letter

.second_digit:
    mov cl, al
    
    and cl, 0x0f
    mov byte [.output_str+1], cl
    add byte [.output_str+1], '0'
    cmp byte [.output_str+1], '9'   ; If the digit is greater, than 9
    jng .end
    add byte [.output_str+1], 7     ; Add 7 to make it a letter

.end:
    mov eax, .output_str
    ret

.output_str: db "00",0


;***********************************************;
; Loop and never return.
;***********************************************;
halt_loop:
    hlt
    jp halt_loop


;################ Variables ####################;
boot_drive_num:     db 0    ; DL will be loaded here
welcome_msg:        db "Reading disk...",13,10,0
disk_reset_err_msg: db "Disk reset err: 0x",0
disk_read_err_msg1: db "Disk read err: 0x",0
disk_read_err_msg2: db ", sectors read: 0x",0
disk_read_err_msg3: db 13,10,0
ok_msg:             db "OK",13,10,0

player_1_y:         dw SCREEN_H/2-PLAYER_HEIGHT/2
player_1_score:     db 0

player_2_y:         dw SCREEN_H/2-PLAYER_HEIGHT/2
player_2_score:     db 0

ball_x:             dw SCREEN_W/2-BALL_SIZE/2
ball_y:             dw SCREEN_H/2-BALL_SIZE/2
is_ball_x_speed_positive: db TRUE  ; bool
is_ball_y_speed_positive: db TRUE  ; bool


times 510-($-$$) db 0   ; Padding
dw 0xaa55               ; Magic number


second_partition:
%include "video.asm"
%include "string.asm"
%include "timer.asm"
%include "gamelogics.asm"
%include "keyboard.asm"
%include "random.asm"

times 512+512*SECTOR_NUM_TO_READ-($-$$) db 0 ; Padding
