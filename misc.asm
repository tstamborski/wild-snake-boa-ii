ClearScreen:
	mov cx, 80*50
	mov ax, 0x0000
	xor di, di
	rep stosw
	ret

Wait4VSync:
	mov dx, 0x3da
	.loop1:
	in al, dx
	and al, 0x08
	jnz .loop1

	.loop2:
	in al, dx
	and al, 0x08
	jz .loop2
	ret

SRand:
	xor ax, ax
	int 0x1a
	mov [prn], dx
	ret

Rand:
	mov ax, 25173
	mul word [prn]
	add ax, 13849
	mov [prn], ax
	ret

Exit:
	mov dx, 0x61
    in al, dx
    and al, 0xfc
    out dx, al

    mov ah, 1
    mov ch, 0xe
    mov cl, 0xf
    int 0x10
    mov ax, 0x03
    int 0x10

    mov ax, 0x4c00
    int 0x21

prn:
	dw 0
