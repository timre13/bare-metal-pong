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

SCREEN_W equ 320
SCREEN_H equ 200
SCREEN_W_CHARS equ 40
SCREEN_H_CHARS equ 25


;***********************************************;
; Switch to VGA video mode.
;***********************************************;
switch_to_vga_mode:
    xor ah, ah
    mov al, 0x13
    int 0x10

    ret


;***********************************************;
; Draw all the 256 colors on the screen.
;***********************************************;
draw_palette:
    push bx

    mov ah, 0x0e            ; Function: Print
    mov al, 219             ; Character
    xor bh, bh              ; Page number
    xor bl, bl              ; Color
    
.loop_:
    int 0x10
    mov cl, bl
    inc cl
    and cl, 0x0f
    cmp cl, 0
    jne .dont_print_newline
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    mov al, 219
.dont_print_newline:
    inc bl
    cmp bl, 0
    jne .loop_
    
    pop bx
    ret


;***********************************************;
; Put a pixel in the specified position.
;
; Arguments:
;   AX = x
;   CX = y
;   DH = color
;***********************************************;
draw_pixel:
    push bx
    push es
    push di

    mov bx, 0xa000
    mov es, bx

    mov di, cx
    imul di, SCREEN_W
    add di, ax
    mov [es:di], dh
    
    pop di
    pop es
    pop bx
    ret


;***********************************************;
; Draw the separator line.
;***********************************************;
draw_separator_line:
    mov ax, SCREEN_W/2-1    ; X pos
    xor cx, cx              ; Y pos
    mov dh, SEP_LINE_COLOR  ; Color

.loop1_:
    call draw_pixel
    
    add cx, 3               ; Move down
    cmp cx, SCREEN_H
    jl .loop1_

.after_loop1:
    inc ax                  ; Move right
    mov cx, 1               ; Reset Y with 1px offset

.loop2_:
    call draw_pixel
    
    add cx, 3               ; Move down
    cmp cx, SCREEN_H
    jl .loop2_

.end:
    ret


;***********************************************;
; Draw the ball.
;
; Arguments:
;   AX = x
;   CX = y
;***********************************************;
draw_ball: 
    push bx
    push di
    push si
    
    mov word [.x1], ax
    mov word [.y1], cx
    xor di, di          ; X offset
    xor si, si          ; Y offset

.x_loop:
    mov ax, [.x1]
    add ax, di
    mov cx, [.y1]
    add cx, si

    mov bx, si
    imul bx, BALL_SIZE
    add bx, di
    add bx, .ball_graphics
    mov dl, [bx]            ; Get the "transparency" of the pixel
    imul dx, BALL_COLOR     ; Get the real pixel color
    mov dh, dl
    
    call draw_pixel
    
    inc di
    
    cmp di, BALL_SIZE
    jge .x_loop_end
    jmp .x_loop
    
.x_loop_end:
    xor di, di
    inc si
    
    cmp si, BALL_SIZE
    jl .x_loop

.end:
    pop si
    pop di
    pop bx
    ret

.x1: dw 0x00
.y1: dw 0x00

.ball_graphics:
    db 0,0,0,1,1,0,0,0
    db 0,0,1,1,1,1,0,0
    db 0,1,1,1,1,1,1,0
    db 1,1,1,1,1,1,1,1
    db 1,1,1,1,1,1,1,1
    db 0,1,1,1,1,1,1,0
    db 0,0,1,1,1,1,0,0
    db 0,0,0,1,1,0,0,0


;***********************************************;
; Fill the screen at the ball position with black.
;
; Arguments:
;   AX = x
;   CX = y
;***********************************************;
clear_ball:
    push bx
    push di
    push si

    mov word [.x1], ax
    mov word [.y1], cx
    xor di, di          ; X offset
    xor si, si          ; Y offset
    xor dh, dh          ; Color

.x_loop:
    mov ax, [.x1]
    add ax, di
    mov cx, [.y1]
    add cx, si

    call draw_pixel

    inc di

    cmp di, BALL_SIZE
    jge .x_loop_end
    jmp .x_loop

.x_loop_end:
    xor di, di
    inc si

    cmp si, BALL_SIZE
    jl .x_loop

.end:
    pop si
    pop di
    pop bx
    ret

.x1: dw 0x00
.y1: dw 0x00


;***********************************************;
; Clear the whole screen with black.
;***********************************************;
clear_screen:
    push es
    push edi

    mov ax, 0xa000
    mov es, ax          ; Set up the base address

    cld                 ; Turn on incrementing of index register

    xor eax, eax        ; The data to fill with
    xor edi, edi        ; Index

    mov ecx, SCREEN_W*SCREEN_H/4 ; Set the count
    rep stosd           ; Do the filling
    
    pop edi
    pop es
    ret


;***********************************************;
; Draw a player on the screen.
;
; Arguments:
;   AX = X pos
;   CX = Y pos
;***********************************************;
draw_player:
    push di
    push si
    
    mov word [.x1], ax
    mov word [.y1], cx
    xor di, di          ; X offset
    xor si, si          ; Y offset

.x_loop:
    mov ax, [.x1]
    add ax, di
    mov cx, [.y1]
    add cx, si

    mov dh, PLAYER_COLOR

    call draw_pixel

    inc di

    cmp di, PLAYER_WIDTH
    jge .x_loop_end
    jmp .x_loop

.x_loop_end:
    xor di, di
    inc si

    cmp si, PLAYER_HEIGHT
    jl .x_loop

.end:
    pop si
    pop di
    ret
.x1: dw 0x00
.y1: dw 0x00

;***********************************************;
; Fill the screen with black at the player position.
;
; Arguments:
;   AX = X pos
;   CX = Y pos
;***********************************************;
clear_player:
    push di
    push si

    mov word [.x1], ax
    mov word [.y1], cx
    xor di, di          ; X offset
    xor si, si          ; Y offset
    xor dh, dh

.x_loop:
    mov ax, [.x1]
    add ax, di
    mov cx, [.y1]
    add cx, si

    call draw_pixel
    
    inc di
    
    cmp di, PLAYER_WIDTH
    jge .x_loop_end
    jmp .x_loop
    
.x_loop_end:
    xor di, di
    inc si
    
    cmp si, PLAYER_HEIGHT
    jl .x_loop

.end:
    pop si
    pop di
    ret
.x1: dw 0x00
.y1: dw 0x00


;***********************************************;
; Show game over screen.
; Print a message depending on the winner.
;***********************************************;
show_game_over_screen:
    push es
    push edi
    push esi
    push bx

    call play_game_over_sound

    xor edi, edi        ; Index

    mov ax, 0xa000
    mov es, ax          ; Set up the base address

    xor esi, esi          ; Offset

.offset_loop:
    inc esi
    cmp esi, 12
    jge .print_text
    mov edi, esi

    mov eax, 100000
    call wait_for_microsecs
    
.loop_:
    mov byte [es:edi], 0xb6

    add edi, 11
    
    cmp edi, SCREEN_W*SCREEN_H
    jl .loop_
    jmp .offset_loop

.print_text:
    ; Set cursor position
    mov ah, 0x02
    xor bh, bh                  ; Page
    mov dh, SCREEN_H_CHARS/2-1  ; Row
    mov dl, SCREEN_W_CHARS/2-4  ; Col
    int 0x10

    mov eax, .game_over_msg1
    call print_string

    ; Set cursor position, skip space
    mov ah, 0x02
    xor bh, bh                  ; Page
    mov dh, SCREEN_H_CHARS/2-1  ; Row
    mov dl, SCREEN_W_CHARS/2+1  ; Col
    int 0x10

    mov eax, .game_over_msg2
    call print_string

    mov byte al, [player_1_score]
    mov byte ah, [player_2_score]
    cmp al, ah
    jg .player_1_won
    jmp .player_2_won
    ; No need to handle when the scores are equal,
    ; the players can't reach the same score at the same time.

.player_1_won:
    ; Set cursor position
    mov ah, 0x02
    xor bh, bh                  ; Page
    mov dh, SCREEN_H_CHARS/2+1  ; Row
    mov dl, SCREEN_W_CHARS/2-4  ; Col
    int 0x10

    mov eax, .player_1_won_msg
    call print_string
    jmp .end

.player_2_won:
    ; Set cursor position
    mov ah, 0x02
    xor bh, bh                  ; Page
    mov dh, SCREEN_H_CHARS/2+1  ; Row
    mov dl, SCREEN_W_CHARS/2-4  ; Col
    int 0x10

    mov eax, .player_2_won_msg
    call print_string

.end:
    call stop_playing_sound

    ; Set cursor position
    mov ah, 0x02
    xor bh, bh                  ; Page
    mov dh, SCREEN_H_CHARS-1    ; Row
    mov dl, SCREEN_W_CHARS/2-12 ; Col
    int 0x10

    mov eax, .press_a_key_msg
    call print_string

    call wait_for_keypress

    pop bx
    pop esi
    pop edi
    pop es
    ret

.game_over_msg1:   db "GAME",0
.game_over_msg2:   db "OVER",0
.player_1_won_msg: db "You won.",0
.player_2_won_msg: db "You lose.",0
.press_a_key_msg:  db "Press a key to play again",0


;***********************************************;
; Draw the score of both players on the top.
;***********************************************;
draw_player_scores:
    push bx
    
    ; Set cursor position
    mov ah, 0x02
    xor bh, bh                  ; Page
    xor dx, dx                  ; Row & col
    int 0x10

    mov al, [player_1_score]
    call uint8_to_hex_str       ; TODO: Use decimal
    call print_string

    ; Set cursor position
    mov ah, 0x02
    xor bh, bh                  ; Page
    xor dh, dh                  ; Row
    mov dl, SCREEN_W_CHARS-2    ; Col
    int 0x10

    mov al, [player_2_score]
    call uint8_to_hex_str       ; TODO: Use decimal
    call print_string

    pop bx
    ret

