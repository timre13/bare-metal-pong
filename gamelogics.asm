; BSD 2-Clause License
;
; Copyright (c) 2020-2022, timre13
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

move_ball:
    call _handle_ball_bouncing_from_edges
    call _move_ball_real
    ret

;***********************************************;
;***********************************************;
_move_ball_real:
    cmp byte [is_ball_x_speed_positive], FALSE ; If the ball X speed is negative
    je .ball_x_speed_is_negative
    add word [ball_x], BALL_SPEED           ; If it is positive
    jmp .is_ball_x_speed_negative_end
.ball_x_speed_is_negative:
    sub word [ball_x], BALL_SPEED
.is_ball_x_speed_negative_end:

    cmp byte [is_ball_y_speed_positive], FALSE ; If ball Y speed is negative
    je .ball_y_speed_is_negative
    add word [ball_y], BALL_SPEED           ; If it is positive
    jmp .is_ball_y_speed_negative_end
.ball_y_speed_is_negative:
    sub word [ball_y], BALL_SPEED
.is_ball_y_speed_negative_end:
    ret

;***********************************************;
;***********************************************;
_handle_ball_bouncing_from_edges:
    push bx
    push di
    push si

    mov ax, [ball_x]                ; AX = ball X
    mov bx, [ball_y]                ; BX = ball Y
    mov di, [player_1_y]            ; DI = player 1 Y
    mov si, [player_2_y]            ; SI = player 2 Y

.test_ball_x:
    cmp ax, BALL_SPEED-1            ; If the ball touches the left side
    jle .ball_touches_left_side     ; Handle it
    cmp ax, SCREEN_W-BALL_SIZE-1    ; If the ball touches the right side
    jge .ball_touches_right_side    ; Handle it
    jmp .test_ball_y                ; The ball does not touch X side

.ball_touches_right_side:
    ; if (ball_y + ball_size < player_2_y ||
    ;     ball_y > player_2_y + player_height)
    ;   player_1_score();

    mov cx, bx
    add cx, BALL_SIZE
    cmp cx, si
    jl .player_1_score              ; Player 1 scores

    mov cx, si
    add cx, PLAYER_HEIGHT
    cmp bx, cx
    jg .player_1_score              ; Player 1 scores

    jmp .ball_touches_x_edge_end

.player_1_score:
    inc byte [player_1_score]
    jmp .ball_touches_x_edge_end


.ball_touches_left_side:
    ; if (ball_y + ball_size < player_1_y ||
    ;     ball_y > player_1_y + player_height)
    ;   player_2_score();

    mov cx, bx
    add cx, BALL_SIZE
    cmp cx, di
    jl .player_2_score              ; Player 2 scores

    mov cx, di
    add cx, PLAYER_HEIGHT
    cmp bx, cx
    jg .player_2_score              ; Player 2 scores

    jmp .ball_touches_x_edge_end

.player_2_score:
    inc byte [player_2_score]
    jmp .ball_touches_x_edge_end

.ball_touches_x_edge_end:
    xor byte [is_ball_x_speed_positive], 1  ; Bounce the ball
    call play_bouncing_sound


.test_ball_y:
    cmp bx, BALL_SPEED-1            ; If the ball touches the top
    jle .ball_touches_y_edge
    cmp bx, SCREEN_H-BALL_SIZE-1
    jge .ball_touches_y_edge        ; If the ball touches the bottom
    jmp .end

.ball_touches_y_edge:
    xor byte [is_ball_y_speed_positive], 1  ; Bounce the ball
    call play_bouncing_sound

.end:
    pop si
    pop di
    pop bx
    ret


;***********************************************;
;***********************************************;
handle_keypresses:

.check_w:
    mov al, 'w'
    call is_ascii_key_pressed
    cmp al, TRUE
    jne .check_s

.w_pressed:
    ; If the player would go out of the screen, don't move
    cmp word [player_1_y], PLAYER_1_SPEED
    jl .check_s

    sub byte [player_1_y], PLAYER_1_SPEED
    ;call clear_screen

.check_s:
    mov al, 's'
    call is_ascii_key_pressed
    cmp al, TRUE
    jne .check_end

.s_pressed:
    ; If the player would go out of the screen, don't move
    cmp word [player_1_y], SCREEN_H-PLAYER_HEIGHT-PLAYER_1_SPEED
    jge .check_end

    add byte [player_1_y], PLAYER_1_SPEED
    ;call clear_screen

.check_end:
    ret


;***********************************************;
; Sets the variables to their default value.
; Should be called before restarting the game.
;***********************************************;
reset_game:
    mov word [player_1_y], SCREEN_H/2-PLAYER_HEIGHT/2
    mov byte [player_1_score], 0

    mov word [player_2_y], SCREEN_H/2-PLAYER_HEIGHT/2
    mov byte [player_2_score], 0

    mov word [ball_x], SCREEN_W/2-BALL_SIZE/2
    mov word [ball_y], SCREEN_H/2-BALL_SIZE/2
    mov byte [is_ball_x_speed_positive], TRUE  ; bool
    mov byte [is_ball_y_speed_positive], TRUE  ; bool
    ret
