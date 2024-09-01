Status_Print:
    mov si, score_str
    mov di, 81*2
    call PrintString
    mov si, player_score
    mov cx, 3
    call PrintBCDNumber

    mov si, hiscore_str
    mov di, (80+32)*2
    call PrintString
    mov si, best_score
    mov cx, 3
    call PrintBCDNumber

    mov si, stars_str
    mov di, (80+80-14)*2
    call PrintString
    mov si, player_stars
    mov cx, 1
    call PrintBCDNumber

    mov si, lives_str
    mov di, (80+80-7)*2
    call PrintString
    mov si, player_lives
    mov cx, 1
    call PrintBCDNumber

    ret

Status_PrintPaused:
    mov ah, 0x0f
    mov al, ' '
    mov di, 81*2
    mov cx, 80-2
    rep stosw

    mov ah, 0x8f
    mov [default_attributes], ah
    mov si, pause_str
    mov di, (80+37)*2
    call PrintString
    mov ah, 0x0f
    mov [default_attributes], ah

    ret

Status_PrintGameOver:
    mov ah, 0x0f
    mov al, ' '
    mov di, 81*2
    mov cx, 80-2
    rep stosw

    mov si, gameover_str
    mov di, (80+36)*2
    call PrintString

    ret

Status_SetPaused:
    ;al <- czy jest pauza 0 albo inna liczba
    mov [is_paused], al
    and al, al
    jz .ch0
    jmp Status_PrintPaused
    .ch0:
    jmp Status_Print

player_score:
    db 0x00, 0x00, 0x00
best_score:
    db 0x00, 0x00, 0x00
player_lives:
    db 0x03
player_stars:
    db 0x00

is_paused:
    db 0x00

gameover_str:
    db "GAME OVER", 0x00
pause_str:
    db "PAUSED", 0x00
score_str:
    db "SCORE: ", 0x00
hiscore_str:
    db "HISCORE: ", 0x00
stars_str:
    db 0x09, " x ", 0x00
lives_str:
    db 0x0a, " x ", 0x00
