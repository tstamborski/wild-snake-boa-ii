Speaker_SetFraq:
    ; ax <- czestotliwosc dzwieku
    mov cx, ax
    mov dx, (0x1600 >> 8)
    mov ax, (0x1600 & 0xff)
    div cx

    push ax
    mov dx, 0x43
    mov al, 0xb6
    out dx, al

    pop ax
    mov dx, 0x42
    out dx, al
    shr ax, 8
    out dx, al

    ret

Speaker_Play:
    mov dx, 0x61
    in al, dx
    or al, 0x03
    out dx, al
    ret

Speaker_Mute:
    mov dx, 0x61
    in al, dx
    and al, 0xfc
    out dx, al
    ret
