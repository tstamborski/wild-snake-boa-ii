MAX_LEVEL_SLOWER_VALUE equ 7
MAX_STARS equ 0x10

ITEM_COUNTER_FACTOR equ 5

Level_Init:
    mov sp, 0xffff
    mov bp, sp
    mov ax, 0xb800
    mov es, ax
    mov si, no_tune
    call Tune_Load
    xor ax, ax
    mov [level_last_item], al
Level_LoadLevel:
    mov al, [level_number]
    cmp al, 0x00
    jne .s0
    mov si, level0
    jmp .skipall
    .s0:
    cmp al, 0x01
    jne .s1
    mov si, level1
    jmp .skipall
    .s1:
    cmp al, 0x02
    jne .s2
    mov si, level2
    jmp .skipall
    .s2:
    cmp al, 0x03
    jne .s3
    mov si, level3
    jmp .skipall
    .s3:
    mov al, 0x00
    mov [level_number], al
    jmp Level_LoadLevel

    .skipall:
    movzx cx, al
    inc cx
    xor al, al
    .ic_loop:
    add al, ITEM_COUNTER_FACTOR
    loop .ic_loop
    mov [level_item_counter], al

    call Level_LoadRLE
    call Status_Print
    call Level_NextItem

    .wait4key:
    mov ah, 0x01
    int 0x16
    jz .wait4key
    xor ah, ah
    int 0x16
    cmp ah, 0x48
    jnz .n1
    mov al, DIR_UP
    mov [snake_direction], al
    jmp Level_Run
    .n1:
    cmp ah, 0x4b
    jnz .n2
    mov al, DIR_LEFT
    mov [snake_direction], al
    jmp Level_Run
    .n2:
    cmp ah, 0x4d
    jnz .n3
    mov al, DIR_RIGHT
    mov [snake_direction], al
    jmp Level_Run
    .n3:
    cmp ah, 0x50
    jnz .wait4key
    mov al, DIR_DOWN
    mov [snake_direction], al

Level_Run:
    mov al, [level_item_counter]
    and al, al
    jz Level_NextLevel

    mov ah, 0x01
    int 0x16
    jz .process
    xor ah, ah
    int 0x16
    cmp ah, 0x01 ;Esc
    jnz .n0
    mov al, [is_paused]
    xor al, 0xff
    call Status_SetPaused
    jmp .process
    .n0:
    cmp ah, 0x48
    jnz .n1
    mov al, DIR_UP
    mov [snake_direction], al
    jmp .process
    .n1:
    cmp ah, 0x4b
    jnz .n2
    mov al, DIR_LEFT
    mov [snake_direction], al
    jmp .process
    .n2:
    cmp ah, 0x4d
    jnz .n3
    mov al, DIR_RIGHT
    mov [snake_direction], al
    jmp .process
    .n3:
    cmp ah, 0x50
    jnz .process
    mov al, DIR_DOWN
    mov [snake_direction], al

    .process:
    mov al, [is_paused]
    and al, al
    jz .process1
    call Wait4VSync
    call Tune_AdvanceOneShot
    jmp Level_Run

    .process1:
    mov ax, [level_slower]
    dec ax
    mov [level_slower], ax
    jz .process2
    call Wait4VSync
    call Tune_AdvanceOneShot
    jmp Level_Run

    .process2:
    mov ax, MAX_LEVEL_SLOWER_VALUE
    mov [level_slower], ax

    call Snake_MoveHead

    call Snake_CheckCollision
    and ax, ax
    jz .nocollision
    jmp Level_Hit
    .nocollision:

    call Snake_CheckItem
    mov [level_score_flag], al
    and ax, ax
    jz .noitem
    call Level_AddScore
    jmp .process3
    .noitem:

    call Snake_MoveTail

    .process3:
    call Wait4VSync
    call Tune_AdvanceOneShot
    call Snake_UpdateHead
    mov al, [level_score_flag]
    and al, al
    jz .process4
    call Status_Print
    call Level_NextItem
    jmp Level_Run
    .process4:
    call Snake_UpdateTail
    jmp Level_Run

Level_Hit:
    mov al, [player_lives]
    clc
    sbb al, 1
    das
    mov [player_lives], al
    and al, al
    jz Level_GameOver

    mov ax, NOTE_C4
    call Music_Beep4
    jmp Level_LoadLevel

Level_GameOver:
    call Status_PrintGameOver
    mov ax, NOTE_D4
    call Music_Beep4
    mov ax, NOTE_CS4
    call Music_Beep8
    mov ax, NOTE_C4
    call Music_Beep8

    mov ah, 0x08
    int 0x21

    mov al, 0x03
    mov [player_lives], al
    xor al, al
    mov [player_stars], al

    call Hiscore_IsHiscore
    and ax, ax
    jz MainMenu_Load
    call Hiscore_AddScore
    call Hiscore_Save
    jmp HiscoreRoom_Load

Level_LoadRLE:
    ;es == 0xb800
    ;si <- adres spakowanych (rle) danych levelu
    xor di, di
    inc si
    .majorloop:
    mov al, [ds:si]
    cmp al, 0xff
    je .minorloop
    call Level_PutChar
    mov bx, ax
    add di, 2
    inc si
    jmp .majorloop

    .minorloop:
    inc si
    movzx cx, [ds:si]
    and cx, cx
    jz .fend
    mov ax, bx
    rep stosw
    inc si
    jmp .majorloop

    .fend:
    ret

Level_PutChar:
    ;al <- znak
    ;di <- adres na ekranie
    mov ah, 0x0f ;domyslny atrybut
    cmp al, 0x80
    jb .s10
    mov ah, 0x06
    mov [es:di], ax
    cmp al, 0x84
    jae .s01
    mov [ds:snake_head_addr], di
    ret
    .s01:
    cmp al, 0x88
    jae .s02
    mov [ds:snake_tail_addr], di
    .s02:
    ret

    .s10:
    cmp al, 0x10
    jne .s20
    mov ah, 0x74
    jmp .fend
    .s20:
    cmp al, 0x11
    jne .s30
    mov ah, 0x07
    jmp .fend
    .s30:
    cmp al, 0x12
    jb .fend
    cmp al, 0x20
    jae .fend
    mov ah, 0x4f
    .fend:
    mov [es:di], ax
    ret

Level_AddScore:
    ;al <- kod powerup'a do zebrania
    mov bl, al
    mov dl, [player_score]
    add al, dl
    daa
    mov [player_score], al
    jnc .chkbestscore
    mov al, [player_score+1]
    adc al, 0
    daa
    mov [player_score+1], al
    jnc .chkbestscore
    mov al, [player_score+2]
    adc al, 0
    daa
    mov [player_score+2], al

    .chkbestscore:
    mov al, [player_score+2]
    mov dl, [best_score+2]
    cmp al, dl
    jb .chkstar
    ja .updatebestscore
    mov al, [player_score+1]
    mov dl, [best_score+1]
    cmp al, dl
    jb .chkstar
    ja .updatebestscore
    mov al, [player_score]
    mov dl, [best_score]
    cmp al, dl
    jb .chkstar
    je .chkstar
    .updatebestscore:
    mov al, [player_score+2]
    mov [best_score+2], al
    mov al, [player_score+1]
    mov [best_score+1], al
    mov al, [player_score]
    mov [best_score], al

    .chkstar:
    cmp bl, 0x09
    jne .chklive
    mov al, [player_stars]
    add al, 1
    daa
    mov [player_stars], al
    cmp al, MAX_STARS
    jb .fend
    xor al, al
    mov [player_stars], al
    jmp .fend

    .chklive:
    cmp bl, 0x0a
    jne .fend
    mov al, [player_lives]
    add al, 1
    daa
    mov [player_lives], al

    .fend:
    mov [level_last_item], bl
    dec byte [level_item_counter]
    mov si, score_tune
    call Tune_Load
    ret

Level_NextLevel:
    mov ax, NOTE_C5
    call Music_Beep8
    mov ax, NOTE_CS5
    call Music_Beep16
    mov ax, NOTE_F5
    call Music_Beep16
    mov ax, NOTE_FS5
    call Music_Beep16

    inc byte [level_number]
    jmp Level_Init

Level_NextItem:
    call SRand

    .loop:
    call Rand
    xor dx, dx
    mov cx, 80*46
    div cx
    mov ax, dx
    add ax, ax
    add ax, 80*4*2
    mov di, ax
    mov ax, [es:di]
    and al, al
    jnz .loop

    mov al, [level_last_item]
    cmp al, 0x09
    jne .notheart
    mov al, [player_stars]
    and al, al
    jnz .notheart
    mov al, 0x0a
    jmp Level_PutItem

    .notheart:
    call Rand
    xor dx, dx
    mov cx, 0x09
    div cx
    mov ax, dx
    inc ax

Level_PutItem:
    ;di <- adres na ekranie
    ;al <- item
    cmp al, 0x01
    je .drop
    cmp al, 0x02
    je .pear
    cmp al, 0x03
    je .apple
    cmp al, 0x04
    je .lemon
    cmp al, 0x05
    je .plum
    cmp al, 0x06
    je .orange
    cmp al, 0x07
    je .cherry
    cmp al, 0x08
    je .candy
    cmp al, 0x09
    je .star
    cmp al, 0x0a
    je .heart
    jmp .fend

    .drop:
    mov ah, 0x83
    jmp .fend
    .pear:
    mov ah, 0x8a
    jmp .fend
    .apple:
    mov ah, 0x82
    jmp .fend
    .lemon:
    .star:
    mov ah, 0x8e
    jmp .fend
    .plum:
    mov ah, 0x81
    jmp .fend
    .orange:
    mov ah, 0x86
    jmp .fend
    .cherry:
    .heart:
    mov ah, 0x84
    jmp .fend
    .candy:
    mov ah, 0x85

    .fend:
    mov [es:di], ax
    ret

level_slower:
    dw MAX_LEVEL_SLOWER_VALUE

level_score_flag:
    db 0x00
level_last_item:
    db 0x00
level_item_counter:
    db 0x00
level_number:
    db 0x00

level0:
    incbin "level00.rle"
    db 0xff, 0x00
level1:
    incbin "level01.rle"
    db 0xff, 0x00
level2:
    incbin "level02.rle"
    db 0xff, 0x00
level3:
    incbin "level03.rle"
    db 0xff, 0x00