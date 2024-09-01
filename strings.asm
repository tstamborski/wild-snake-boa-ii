PrintString:
    ; es == 0xb800
    ; si <- adres stringa ZT
    ; di <- adres/miejsce na ekranie
    ; di -> adres na ekranie znaku zaraz po stringu
    mov ah, [default_attributes]
    .loop:
    mov al, [ds:si]
    and al, al
    jz .fend
    mov [es:di], ax
    inc si
    inc di
    inc di
    jmp .loop
    .fend:
    ret

PrintBCDNumber:
    ; es == 0xb800
    ; si <- adres liczby
    ; cx <- ile bajtow ma liczba
    ; di <- adres/miejsce na ekranie
    add si, cx
    mov ah, [default_attributes]
    .loop:
    dec si
    mov bl, [si]

    mov al, bl
    shr al, 4
    add al, '0'
    mov [es:di], ax
    add di, 2

    mov al, bl
    and al, 0x0f
    add al, '0'
    mov [es:di], ax
    add di, 2

    loop .loop
    ret

PrintScroll80:
    ; es == 0xb800
    ; si <- adres tekstu scroll'a ZT
    ; cx <- aktualna wartorsc scroll'a
    ; di <- adres poczatku linii (!)
    mov dx, di
    add dx, 80*2

    push cx
    push di
    mov cx, 80
    mov ah, [default_attributes]
    mov al, ' '
    rep stosw
    pop di
    pop cx

    cmp cx, 0
    jge .cutfromright
    .cutfromleft:
    inc si
    inc cx
    jnz .cutfromleft
    .loop1:
    mov al, [ds:si]
    and al, al
    jz .fend
    mov [es:di],ax
    inc si
    add di, 2
    cmp di, dx
    jb .loop1

    .cutfromright:
    add di, cx
    add di, cx
    .loop2:
    mov al, [ds:si]
    and al, al
    jz .fend
    mov [es:di], ax
    inc si
    add di, 2
    cmp di, dx
    jb .loop2
    .fend:
    ret

default_attributes:
    db 0x0f
