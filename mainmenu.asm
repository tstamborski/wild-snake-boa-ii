MAX_SCROLL_SLOWER_VALUE equ 0x06

MainMenu_Load:
    mov sp, 0xffff
    mov bp, sp
    mov ax, 0xb800
    mov es, ax
    call ClearScreen

    mov al, [hiscore_score0]
    mov [best_score], al
    mov al, [hiscore_score0+1]
    mov [best_score+1], al
    mov al, [hiscore_score0+2]
    mov [best_score+2], al

    call MainMenu_LoadTitleLogo
    call Status_Print
    push byte 33
    push byte 30
    push byte 46
    push byte 42
    call Frame_New
    mov [menu_frame_seg], ax
    mov bl, 0x01
    mov [default_attributes], bl
    call Frame_Draw

    mov ah, 0x09
    mov [default_attributes], ah
    mov si, newgame_menu_str
    mov di, (80*32+35)*2
    call PrintString
    mov si, hiscores_menu_str
    mov di, (80*36+35)*2
    call PrintString
    mov si, exit_menu_str
    mov di, (80*40+35)*2
    call PrintString
    mov ah, 0x0f
    mov [default_attributes], ah

    call MainMenu_PutMenuChar

MainMenu_Loop:
    mov si, ode_to_joy
    call Tune_Load

    .loop:
    mov ah, 0x01
    int 0x16
    jz .skipall
    xor ah, ah
    int 0x16
    cmp ah, 0x01 ;Esc
    jz Exit
    cmp ah, 0x1c ;Enter
    jnz .s0
    call MainMenu_Accept
    .s0:
    cmp ah, 0x39 ;Spacebar
    jnz .s1
    call MainMenu_Accept
    .s1:
    cmp ah, 0x48 ;UpArrow
    jnz .s2
    call MainMenu_Up ;Menu w gore
    .s2:
    cmp ah, 0x50 ;DownArrow
    jnz .skipall
    call MainMenu_Down ;Menu w dol
    .skipall:

    call Wait4VSync

    call Tune_AdvanceLoop

    mov al, [scroll_slower_value]
    dec al
    mov [scroll_slower_value], al
    jnz .loop
    mov al, MAX_SCROLL_SLOWER_VALUE
    mov [scroll_slower_value], al
    call MainMenu_ScrollUpdate
    jmp .loop

MainMenu_Up:
    mov bl, [menu_choice]
    dec bl
    cmp bl, 0
    jge .fend
    xor bl, bl
    .fend:
    mov [menu_choice], bl
    call MainMenu_PutMenuChar
    ret

MainMenu_Down:
    mov bl, [menu_choice]
    inc bl
    cmp bl, 3
    jl .fend
    mov bl, 2
    .fend:
    mov [menu_choice], bl
    call MainMenu_PutMenuChar
    ret

MainMenu_Accept:
    mov al, [menu_choice]

    cmp al, 0
    jnz .s1
    jmp MainMenu_NewGame
    .s1:

    cmp al, 1
    jnz .s2
    jmp HiscoreRoom_Load
    .s2:

    cmp al, 2
    jnz .fend
    jmp Exit

    .fend:
    ret

MainMenu_NewGame:
    xor ax, ax
    mov [player_score], al
    mov [player_score+1], al
    mov [player_score+2], al
    mov [player_stars], al
    mov [level_number], al

    mov al, 0x03
    mov [player_lives], al

    jmp Level_Init

MainMenu_PutMenuChar:
    mov ah, 0x8e
    mov al, ' '
    mov di, (80*32+35+(hiscores_menu_str-newgame_menu_str-1))*2
    mov [es:di], ax
    mov di, (80*36+35+(exit_menu_str-hiscores_menu_str-1))*2
    mov [es:di], ax
    mov di, (80*40+35+(end_menu_label-exit_menu_str-1))*2
    mov [es:di], ax

    mov al, 0x1f
    mov bl, [menu_choice]
    cmp bl, 0
    jne .l1
    mov di, (80*32+35+(hiscores_menu_str-newgame_menu_str-1))*2
    mov [es:di], ax
    ret
    .l1:
    cmp bl, 1
    jne .l2
    mov di, (80*36+35+(exit_menu_str-hiscores_menu_str-1))*2
    mov [es:di], ax
    ret
    .l2:
    mov di, (80*40+35+(end_menu_label-exit_menu_str-1))*2
    mov [es:di], ax
    ret

MainMenu_LoadTitleLogo:
    mov si, logo_data
    mov di, (80*2*4 + 20*2)
    mov cx, 25
    .loop:
    push cx
    mov cx, 40
    rep movsw
    pop cx
    add di, 80*2-40*2
    loop .loop
    ret

MainMenu_ScrollUpdate:
    mov cx, [scroll_value]
    dec cx
    cmp cx, (scroll_text - scroll_value)
    jne .skip
    mov cx, 80
    .skip:
    mov [scroll_value], cx

    mov si, scroll_text
    mov di, 8000-80*2
    call PrintScroll80
    ret

newgame_menu_str:
    db "NEW GAME ", 0
hiscores_menu_str:
    db "HISCORES ", 0
exit_menu_str:
    db "EXIT ", 0
end_menu_label:

menu_choice:
    db 0x00
menu_frame_seg:
    dw 0x0000

scroll_text:
    db 0x09, " A GAME BY TELEX OPERATOR ", 0x09
    db " ONE OF THE BEST SNAKE GAMES FOR OLD TRUSTY MS-DOS ", 0x09
    db " GREETINGS TO ALL PEOPLE FROM MS-DOS COMMUNITY DISCORD SERVER AND NASM FORUM ", 0x09
    db " GREETINGS ALSO TO YOU WHOEVER PLAYS THIS GAME ", 0x09
    db " WHO STILL USE MS-DOS IN 2024? ", 0x09, 0x00
scroll_value:
    dw 80
scroll_slower_value:
    db MAX_SCROLL_SLOWER_VALUE

logo_data:
    incbin "logo2.bin", 0, 2000
