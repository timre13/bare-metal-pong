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

;***********************************************;
; Returns a random 8-bit number.
;
; Returns:
;   AL = random number
;***********************************************;
get_random8:
    xor ah, ah
    int 0x1a                        ; Get the clock ticks since midnight
    add byte [.random_index], dl    ; Use the time for better randomization
    inc byte [.random_index]

    mov ecx, .random_nums
    add cl, [.random_index]
    mov al, [ecx]
    ret

.random_index: db 0
.random_nums:
db 85, 61, 140, 109, 133, 232, 47, 122, 111, 216, 191, 99, 178, 78, 87, 185,
db 88, 13, 130, 180, 43, 142, 69, 238, 22, 156, 15, 96, 9, 19, 131, 161,
db 167, 34, 137, 105, 170, 158, 55, 151, 225, 132, 72, 37, 68, 195, 233,
db 162, 120, 173, 11, 197, 153, 219, 210, 155, 212, 213, 29, 176, 70, 32,
db 245, 58, 223, 92, 201, 31, 250, 12, 244, 77, 208, 46, 98, 48, 141, 73, 100,
db 134, 76, 95, 203, 6, 60, 81, 230, 187, 240, 3, 57, 107, 44, 83, 113, 136,
db 39, 117, 246, 227, 190, 108, 33, 121, 174, 119, 252, 71, 189, 200, 65, 184,
db 101, 27, 243, 149, 199, 20, 209, 67, 165, 241, 106, 118, 30, 236, 103, 84,
db 198, 42, 26, 94, 193, 10, 63, 154, 206, 129, 254, 56, 82, 204, 211, 124,
db 139, 160, 192, 218, 163, 196, 186, 255, 205, 247, 194, 35, 147, 80, 17,
db 166, 224, 38, 18, 234, 0, 188, 114, 226, 207, 175, 177, 8, 249, 135,
db 253, 179, 21, 123, 143, 144, 229, 25, 62, 102, 221, 116, 54, 115, 168,
db 150, 239, 50, 228, 169, 128, 59, 90, 138, 86, 2, 24, 91, 79, 172, 231,
db 16, 171, 214, 41, 237, 51, 164, 40, 64, 4, 181, 251, 110, 242, 220,
db 112, 23, 152, 49, 53, 235, 1, 66, 126, 36, 125, 104, 157, 93, 217, 148,
db 215, 28, 182, 248, 89, 222, 146, 5, 159, 74, 14, 202, 145, 7, 52, 97, 75,
db 45, 127, 183

;***********************************************;
; Returns a random 16-bit number.
;
; Returns:
;   AX = random number
;***********************************************;
get_random16:
    call get_random8
    mov al, ah
    call get_random8

    ret
