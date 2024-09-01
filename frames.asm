struc Frame
    .x0: resb 1
    .y0: resb 1
    .x1: resb 1
    .y1: resb 1
endstruc

Frame_New:
    ;arg0 <- x lewy gorny (byte)
    ;arg1 <- y lewy gorny (byte)
    ;arg2 <- x prawy dolny (byte)
    ;arg3 <- y prawy dolny (byte)
    ;ax -> segment nowej struktury Frame
    push bp
    mov bp, sp

    mov ah, 0x48
    mov bx, 1
    int 0x21

    mov fs, bx
    mov al, [bp+10]
    mov [fs:Frame.x0], al
    mov al, [bp+8]
    mov [fs:Frame.y0], al
    mov al, [bp+6]
    mov [fs:Frame.x1], al
    mov al, [bp+4]
    mov [fs:Frame.y1], al

    mov ax, fs
    mov sp, bp
    pop bp
    ret 8

Frame_Draw:
    ;es == 0xb800
    ;ax <- segment struktury Frame
    mov fs, ax

    mov dl, [fs:Frame.x0]
    mov al, [fs:Frame.x1]
    sub al, dl
    inc al
    mov [frame_line_len], al

    mov dl, [fs:Frame.y0]
    mov al, [fs:Frame.y1]
    sub al, dl
    inc al
    mov [frame_line_count], al

    movzx dx, [fs:Frame.x0]
    mov cl, 80*2
    mov al, [fs:Frame.y0]
    mul cl
    add ax, dx
    add ax, dx
    mov di, ax ;di = addr poczatku ramki na ekranie

    mov al, ' '
    mov ah, [ds:default_attributes]
    mov [es:di], ax
    add di, 2
    movzx cx, [frame_line_len]
    sub cx, 2
    mov al, '*'
    rep stosw
    mov al, ' '
    mov [es:di], ax
    add di, 2

    movzx dx, [frame_line_len]
    add di, 80*2
    sub di, dx
    sub di, dx
    movzx cx, [frame_line_count]
    sub cx, 2
    .majorloop:
    push cx

    mov al, '*'
    mov [es:di], ax
    add di, 2
    movzx cx, [frame_line_len]
    sub cx, 2
    mov al, ' '
    rep stosw
    mov al, '*'
    mov [es:di], ax
    add di, 2

    add di, 80*2
    sub di, dx
    sub di, dx
    pop cx
    loop .majorloop

    mov al, ' '
    mov [es:di], ax
    add di, 2
    movzx cx, [frame_line_len]
    sub cx, 2
    mov al, '*'
    rep stosw
    mov al, ' '
    mov [es:di], ax

    ret

Frame_Clear:
    ;es == 0xb800
    ;ax <- segment struktury Frame
    mov fs, ax

    mov dl, [fs:Frame.x0]
    mov al, [fs:Frame.x1]
    sub al, dl
    inc al
    mov [frame_line_len], al

    mov dl, [fs:Frame.y0]
    mov al, [fs:Frame.y1]
    sub al, dl
    inc al
    mov [frame_line_count], al

    movzx dx, [fs:Frame.x0]
    mov cl, 80*2
    mov al, [fs:Frame.y0]
    mul cl
    add ax, dx
    add ax, dx
    mov di, ax ;di = addr poczatku ramki na ekranie

    mov al, ' '
    mov ah, [default_attributes]
    mov cx, [frame_line_count]
    .loop:
    push cx
    mov cx, [frame_line_len]
    rep stosw
    pop cx
    loop .loop

    ret

frame_line_len:
    db 0x00
frame_line_count:
    db 0x00

Frame_Delete:
    ;ax <- segment struktury Frame
    mov dx, es
    push dx

    mov es, ax
    mov ah, 0x49
    int 0x21

    pop dx
    mov es, dx
    ret

