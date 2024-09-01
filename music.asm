SEMIQUAVER_NOTE equ 8
QUAVER_NOTE equ SEMIQUAVER_NOTE*2
QUARTER_NOTE equ SEMIQUAVER_NOTE*4
HALF_NOTE equ SEMIQUAVER_NOTE*8
WHOLE_NOTE equ SEMIQUAVER_NOTE*16

NOTE_PAUSE equ 0
NOTE_C4 equ 262
NOTE_CS4 equ 277
NOTE_D4 equ 294
NOTE_DS4 equ 311
NOTE_E4 equ 330
NOTE_F4 equ 349
NOTE_FS4 equ 370
NOTE_G4 equ 392
NOTE_GS4 equ 415
NOTE_A4 equ 440
NOTE_AS4 equ 466
NOTE_B4 equ 494
NOTE_C5 equ 523
NOTE_CS5 equ 554
NOTE_D5 equ 587
NOTE_DS5 equ 622
NOTE_E5 equ 659
NOTE_F5 equ 698
NOTE_FS5 equ 740
NOTE_G5 equ 784
NOTE_GS5 equ 831
NOTE_A5 equ 880
NOTE_AS5 equ 932
NOTE_B5 equ 988
NOTE_C6 equ 1046

Tune_Load:
    ; si <- adres melodyjki
    mov [tune_base_pointer], si
    mov [tune_pointer], si
    mov ax, [ds:si]
    add si, 2
    mov cx, [ds:si]
    and ax, ax
    jz .pause
    call Music_PlayNote
    add si, 2
    mov [tune_pointer], si
    ret
    .pause:
    call Music_PlayPause
    add si, 2
    mov [tune_pointer], si
    ret

Tune_AdvanceOneShot:
    call Music_AdvanceFrame
    jnz .fend
    mov si, [tune_pointer]
    mov ax, [ds:si]
    and ax, ax
    jz .pause
    add si, 2
    mov cx, [ds:si]
    call Music_PlayNote
    add si, 2
    mov [tune_pointer], si
    ret
    .pause:
    add si, 2
    mov cx, [ds:si]
    and cx, cx
    jz .stop
    call Music_PlayPause
    add si, 2
    mov [tune_pointer], si
    ret
    .stop:
    sub si, 4
    mov [tune_pointer], si
    call Speaker_Mute
    .fend:
    ret

Tune_AdvanceLoop:
    call Music_AdvanceFrame
    jnz .fend
    mov si, [tune_pointer]
    mov ax, [ds:si]
    and ax, ax
    jz .pause
    add si, 2
    mov cx, [ds:si]
    call Music_PlayNote
    add si, 2
    mov [tune_pointer], si
    ret
    .pause:
    add si, 2
    mov cx, [ds:si]
    and cx, cx
    jz .rewind
    call Music_PlayPause
    add si, 2
    mov [tune_pointer], si
    ret
    .rewind:
    mov si, [tune_base_pointer]
    jmp Tune_Load
    ;mov [tune_pointer], si
    ;mov ax, [ds:si]
    ;add si, 2
    ;mov cx, [ds:si]
    ;call Music_PlayNote
    ;add si, 2
    ;mov [tune_pointer], si
    .fend:
    ret

Music_Beep2:
Music_Beep:
    ; ax <- czestotliwosc
    mov cx, HALF_NOTE
    .play:
    call Music_PlayNote

    .loop:
    call Wait4VSync
    call Music_AdvanceFrame
    jnz .loop

    call Music_PlayPause
    ret

Music_Beep4:
    mov cx, QUARTER_NOTE
    jmp Music_Beep.play
Music_Beep8:
    mov cx, QUAVER_NOTE
    jmp Music_Beep.play
Music_Beep16:
    mov cx, SEMIQUAVER_NOTE
    jmp Music_Beep.play

Music_PlayNote:
    ; ax <- czestotliwosc nuty (patrz stale)
    ; cx <- czas trwania nuty (w 1/70 sekundy)
    mov [music_frame_timer], cx
    call Speaker_SetFraq
    call Speaker_Play
    ret

Music_PlayPause:
    ; cx <- czas trwania pauzy (w 1/70 sekundy)
    mov [music_frame_timer], cx
    call Speaker_Mute
    ret

Music_AdvanceFrame:
    ; ZF -> biezaca nuta sie skonczyla (czy nie)
    mov cx, [music_frame_timer]
    dec cx
    mov [music_frame_timer], cx
    ret

music_frame_timer:
    dw 0x0000

tune_base_pointer:
    dw 0x0000
tune_pointer:
    dw 0x0000

no_tune:
    dw 0, 0, 0, 0

sto_lat:
    dw NOTE_PAUSE, HALF_NOTE

    dw NOTE_G4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_G4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE
    dw NOTE_G4, QUARTER_NOTE, NOTE_A4, QUAVER_NOTE, NOTE_G4, QUAVER_NOTE, NOTE_F4, QUAVER_NOTE, NOTE_E4, QUAVER_NOTE, NOTE_F4, QUARTER_NOTE
    dw NOTE_F4, HALF_NOTE, NOTE_PAUSE, QUARTER_NOTE
    dw NOTE_F4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE
    dw NOTE_F4, QUARTER_NOTE, NOTE_G4, QUAVER_NOTE, NOTE_F4, QUAVER_NOTE, NOTE_E4, QUAVER_NOTE, NOTE_D4, QUAVER_NOTE, NOTE_E4, QUARTER_NOTE
    dw NOTE_E4, HALF_NOTE, NOTE_PAUSE, QUARTER_NOTE
    dw NOTE_G4, QUAVER_NOTE, NOTE_G4, QUAVER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_G4, QUAVER_NOTE, NOTE_G4, QUAVER_NOTE, NOTE_E4, QUARTER_NOTE
    dw NOTE_G4, QUARTER_NOTE, NOTE_C5, QUAVER_NOTE, NOTE_B4, QUAVER_NOTE, NOTE_A4, QUAVER_NOTE, NOTE_GS4, QUARTER_NOTE, NOTE_A4, QUARTER_NOTE
    dw NOTE_A4, HALF_NOTE, NOTE_PAUSE, QUAVER_NOTE
    dw NOTE_B4, HALF_NOTE, NOTE_B4, QUARTER_NOTE, NOTE_B4, QUARTER_NOTE, NOTE_C5, HALF_NOTE, NOTE_C5, HALF_NOTE

    dw 0, 0

ode_to_joy:
    dw NOTE_PAUSE, QUAVER_NOTE

    dw NOTE_E4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_G4, QUARTER_NOTE
    dw NOTE_G4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE
    dw NOTE_C4, QUARTER_NOTE, NOTE_C4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE
    dw NOTE_E4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_D4, HALF_NOTE

    dw NOTE_E4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_G4, QUARTER_NOTE
    dw NOTE_G4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE
    dw NOTE_C4, QUARTER_NOTE, NOTE_C4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE
    dw NOTE_E4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_D4, HALF_NOTE

    dw NOTE_D4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_C4, QUARTER_NOTE
    dw NOTE_D4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_C4, QUARTER_NOTE
    dw NOTE_D4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE
    dw NOTE_C4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_G4, HALF_NOTE

    dw NOTE_E4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_G4, QUARTER_NOTE
    dw NOTE_G4, QUARTER_NOTE, NOTE_F4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE
    dw NOTE_C4, QUARTER_NOTE, NOTE_C4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_E4, QUARTER_NOTE
    dw NOTE_E4, QUARTER_NOTE, NOTE_D4, QUARTER_NOTE, NOTE_D4, HALF_NOTE

    dw 0, 0

score_tune:
    dw NOTE_C5, SEMIQUAVER_NOTE, NOTE_CS5, SEMIQUAVER_NOTE, NOTE_E5, SEMIQUAVER_NOTE
    dw 0, 0
