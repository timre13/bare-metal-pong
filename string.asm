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

;***********************************************;
; Convert a 16-bit unsigned integer to its
; decimal representation.
;
; Arguments:
;    AX = input
;
; Returns:
;   EAX = address of zero-terminated output string
;***********************************************;
; FIXME
uint16_to_dec_str:
    push si
    push di

    mov si, ax

    mov cx, 10      ; Divider
    mov di, 4       ; Digit index
                    ; DX is the digit

.loop_:
    div cx
    mov byte [.output_str+di], dl
    add byte [.output_str+di], '0'
    dec di
    cmp di, 0
    jne .loop_

.end:
    pop di
    pop si
    mov eax, .output_str
    ret

.output_str: db "00000",0
