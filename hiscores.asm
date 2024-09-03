Hiscore_Save:
    mov ah, 0x3d
    mov al, 1
    mov dx, file_name
    int 0x21
    jc .fend
    mov [file_handle], ax

    mov bx, ax
    mov ah, 0x42
    mov al, 2
    mov cx, 0xffff
    mov dx, -(hiscores_end-hiscores_begin)
    int 0x21

    mov ah, 0x40
    mov bx, [file_handle]
    mov cx, hiscores_end-hiscores_begin
    mov dx, hiscores_begin
    int 0x21

    mov ah, 0x3e
    mov bx, [file_handle]
    int 0x21

    .fend:
    ret

Hiscore_AddScore:
    mov di, hiscore_score0-16
    .loop:
    add di, 16
    push di
    call Hiscore_IsBetterThan
    pop di
    and ax, ax
    jz .loop

    sub di, 13
    mov dx, di
    mov di, hiscores_end
    mov si, di
    sub si, 16
    .loop2:
    mov al, [ds:si]
    mov [ds:di], al
    dec si
    dec di
    cmp si, dx
    jae .loop2

    mov di, dx
    mov si, player_name
    .loop3:
    mov al, [ds:si]
    mov [ds:di], al
    inc si
    inc di
    and al, al
    jnz .loop3

    mov di, dx
    add di, 13
    mov si, player_score
    mov cx, 3
    .loop4:
    mov al, [ds:si]
    mov [ds:di], al
    inc si
    inc di
    loop .loop4

    ret

Hiscore_IsHiscore:
    mov di, hiscore_score9
Hiscore_IsBetterThan:
    ;player_score <- wynik do spr
    ;di <- adres poprzedniego wyniku do porownania
    ;ax -> 0 | 1 czy [player_score] jest lepszym wynikiem
    mov si, player_score+2
    add di, 2
    mov al, [ds:si]
    mov bl, [ds:di]
    cmp al, bl
    ja .yes
    jb .no
    dec si
    dec di
    mov al, [ds:si]
    mov bl, [ds:di]
    cmp al, bl
    ja .yes
    jb .no
    dec si
    dec di
    mov al, [ds:si]
    mov bl, [ds:di]
    cmp al, bl
    ja .yes

    .no:
    xor ax, ax
    ret

    .yes:
    mov ax, 1
    ret

Hiscore_GetPlayerName:
    call ClearScreen
    call ClearKeyboardBuffer

    mov si, enter_name_str
    mov di, 80*25*2+23*2
    call PrintString
    mov ah, 0x8a
    mov al, 0xdb
    mov [es:di], ax

    mov si, player_name
    xor cx, cx
    .getkey:
    xor ax, ax
    int 0x16

    cmp ah, 0x02
    jb .getkey
    cmp ah, 0x0b
    jbe .pushchar

    cmp ah, 0x0e
    je .back

    cmp ah, 0x10
    jb .getkey
    cmp ah, 0x19
    jbe .pushchar

    cmp ah, 0x1c
    je .accept

    cmp ah, 0x1e
    jb .getkey
    cmp ah, 0x26
    jbe .pushchar

    cmp ah, 0x2c
    jb .getkey
    cmp ah, 0x34
    jbe .pushchar

    cmp ah, 0x32
    je .pushchar

    jmp .getkey

    .pushchar:
    cmp cx, 12
    jae .getkey
    inc cx
    mov ah, 0x0a
    mov [es:di], ax
    mov [ds:si], al
    inc si
    add di, 2
    mov ah, 0x8a
    mov al, 0xdb
    mov [es:di], ax
    jmp .getkey

    .back:
    and cx, cx
    jz .getkey
    dec cx
    mov ax, 0x0f00
    mov [es:di], ax
    dec si
    sub di, 2
    mov ax, 0x8adb
    mov [es:di], ax
    jmp .getkey

    .accept:
    mov al, 0x00
    mov [ds:si], al
    mov [player_name_len], cl
    call Hiscore_AddScore
    call Hiscore_Save

HiscoreRoom_Load:
    mov sp, 0xffff
    mov bp, sp
    mov ax, 0xb800
    mov es, ax
    mov si, sto_lat
    call Tune_Load
    call ClearScreen
    call ClearKeyboardBuffer

    mov al, 0x09
    mov [default_attributes], al
    mov si, hall_of_fame_str
    mov di, 80*2*2+34*2
    call PrintString
    mov al, 0x0f
    mov [default_attributes], al

    mov di, 80*6*2+10*2
    mov ah, 0x0f
    mov al, '.'
    mov cx, 10
    .loop1:
    push cx
    push di

    mov cx, 54
    rep stosw

    pop di
    add di, 80*4*2
    pop cx
    loop .loop1

    mov si, hiscore_name0
    mov dx, 80*6*2+64*2
    mov di, 80*6*2+10*2
    mov cx, 10
    .loop2:
    push di
    push si
    call PrintString
    pop si
    pop di
    add si, 13

    push di
    push si
    push cx
    mov cx, 3
    mov di, dx
    call PrintBCDNumber
    pop cx
    pop si
    pop di
    add si, 3

    add di, 80*4*2
    add dx, 80*4*2
    loop .loop2

HiscoreRoom_Run:
    mov ah, 0x01
    int 0x16
    jz .next
    xor ah, ah
    int 0x16
    cmp ah, 0x01 ;Esc
    je MainMenu_Load
    cmp ah, 0x1c ;Enter
    je MainMenu_Load
    cmp ah, 0x39 ;Spacebar
    je MainMenu_Load

    .next:
    call Wait4VSync
    call Tune_AdvanceLoop
    jmp HiscoreRoom_Run

player_name:
    db "Player"
    times 7 db 0x00
player_name_len:
    db 0x00

file_handle:
    dw 0
file_name:
    db "SNAKEBOA.COM", 0x00
enter_name_str:
    db "Enter your name: ", 0x00
hall_of_fame_str:
    db "HALL OF FAME", 0x00

hiscores_begin:
hiscore_max_level:
    db 0x00

hiscore_name0:
    db "NOBODY"
    times 7 db 0x00
hiscore_score0:
    times 3 db 0x00
hiscore_name1:
    db "NOBODY"
    times 7 db 0x00
hiscore_score1:
    times 3 db 0x00
hiscore_name2:
    db "NOBODY"
    times 7 db 0x00
hiscore_score2:
    times 3 db 0x00
hiscore_name3:
    db "NOBODY"
    times 7 db 0x00
hiscore_score3:
    times 3 db 0x00
hiscore_name4:
    db "NOBODY"
    times 7 db 0x00
hiscore_score4:
    times 3 db 0x00
hiscore_name5:
    db "NOBODY"
    times 7 db 0x00
hiscore_score5:
    times 3 db 0x00
hiscore_name6:
    db "NOBODY"
    times 7 db 0x00
hiscore_score6:
    times 3 db 0x00
hiscore_name7:
    db "NOBODY"
    times 7 db 0x00
hiscore_score7:
    times 3 db 0x00
hiscore_name8:
    db "NOBODY"
    times 7 db 0x00
hiscore_score8:
    times 3 db 0x00
hiscore_name9:
    db "NOBODY"
    times 7 db 0x00
hiscore_score9:
    times 3 db 0x00
hiscores_end:
