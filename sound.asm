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
;***********************************************;
play_bouncing_sound:
    mov al, 0b10110110      ; Set up the PIT
    out 0x43, al

    mov al, 0x00            ; Amplitude low byte
    out 0x42, al
    mov al, 0x90            ; Amplitude high byte
    out 0x42, al

    in al, 0x61
    or al, 3
    out 0x61, al            ; Enable the speaker
    ret


;***********************************************;
;***********************************************;
play_game_over_sound:
    mov al, 0b10110110      ; Set up the PIT
    out 0x43, al

    mov al, 0x00            ; Amplitude low byte
    out 0x42, al
    mov al, 0x40            ; Amplitude high byte
    out 0x42, al

    in al, 0x61
    or al, 3
    out 0x61, al            ; Enable the speaker
    ret


;***********************************************;
;***********************************************;
stop_playing_sound:
    in al, 0x61
    and al, ~3
    out 0x61, al
    ret
