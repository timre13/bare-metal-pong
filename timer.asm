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

[org 0x7c00]
[bits 16]


;***********************************************;
; Wait for the specified number of microseconds.
;
; Arguments:
;   EAX = microseconds to sleep
;***********************************************;
wait_for_microsecs:
    mov dx, ax
    shr eax, 16
    mov cx, ax
    mov ah, 0x86
    int 0x15

    jnc .end        ; If no errors, exit
    cmp ah, 0x83
    jne .ah_not_0x83
    ; AH is 0x83 = wait already in progress
    jmp .end        ; Just exit, TODO: is it OK to exit?
    ;jmp halt_loop
.ah_not_0x83:
    cmp ah, 0x80
    jne .ah_not_0x80
    ; AH is 0x80 = invalid command
    mov eax, .inv_command_err_msg
    call print_string
    jmp halt_loop
.ah_not_0x80:
    cmp ah, 0x86
    jne .ah_not_0x86
    ; AH is 0x86 = function not supported
    mov eax, .func_not_supp_err_msg
    call print_string
    jmp halt_loop
.ah_not_0x86:

.end:
    ret


.inv_command_err_msg:   db "Wait error: Invalid command.",0
.func_not_supp_err_msg: db "Wait error: Function not supported.",0
