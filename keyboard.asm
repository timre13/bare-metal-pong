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

;***********************************************;
; Waits until a key is pressed and returns its
; scancode and ASCII value.
;
; Returns:
;   AH = scancode
;   AL = ASCII
;***********************************************;
wait_for_keypress:
    xor ah, ah
    int 0x16
    ; AH = scancode
    ; AL = ASCII
    ret

;***********************************************;
; Returns true if the passed key is pressed.
;
; Arguments:
;   AL = ASCII character
;
; Returns:
;   AL = bit 0 is set if pressed
;***********************************************;
is_ascii_key_pressed:
    push es

    mov cl, al
    mov ah, 0x01
    int 0x16

    jz .not_pressed     ; If there are no pressed keys, return false
    cmp al, cl
    jne .not_pressed

.pressed:
    mov ax, 0x0040
    mov es, ax
    ; The word at 0x0040:0x001a marks the beginning of the keyboard buffer,
    ; the word at 0x0040:0x001c marks the end.
    ; If they both point to the beginning, the buffer is empty.
    mov word [es:0x1a], 0x041e
    mov word [es:0x1c], 0x041e

    mov al, TRUE

    jmp .end
.not_pressed:
    xor al, al
.end:
    pop es
    ret

;***********************************************;
;
;***********************************************;
setup_key_repeat:
    push bx

    mov ah, 0x03
    mov al, 0x05
    xor bx, bx
    int 0x16


    pop bx
    ret
