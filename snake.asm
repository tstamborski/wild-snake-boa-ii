HEAD_LEFT equ 0x80
HEAD_RIGHT equ 0x82
HEAD_UP equ 0x81
HEAD_DOWN equ 0x83

TAIL_LEFT equ 0x84
TAIL_RIGHT equ 0x86
TAIL_UP equ 0x85
TAIL_DOWN equ 0x87

HBODY equ 0x88
VBODY equ 0x89

TURN0 equ 0x8c
TURN1 equ 0x8d
TURN2 equ 0x8e
TURN3 equ 0x8f

TONGUE_LEFT equ 0x90
TONGUE_RIGHT equ 0x92
TONGUE_UP equ 0x91
TONGUE_DOWN equ 0x93

DIR_LEFT equ 0x00
DIR_RIGHT equ 0x02
DIR_UP equ 0x01
DIR_DOWN equ 0x03

Snake_UpdateHead:
    .overwriteprev:
    mov di, [snake_tongue_prev_addr]
    mov al, [es:di]
    cmp al, TONGUE_LEFT
    jb .nottoungue
    mov ax, 0x0000
    mov [es:di], ax ;nadpisac poprzednia pozycje jezyka
    .nottoungue:
    mov di, [snake_head_prev_addr]
    mov dl, [es:di]
    mov bl, [snake_direction]
    and dl, 0x03
    xor dl, bl ;czy kierunek jest taki sam jak poprzednio
    jnz .s1
    mov al, bl
    add al, HBODY
    mov ah, 0x06
    mov [es:di], ax
    jmp .puthead
    .s1: ;mamy zakręt
    mov dl, [es:di]
    and dl, 0x02
    mov cl, bl
    and cl, 0x02
    xor dl, cl ;czy cos trudne do wyrazenia (bit 1)
    jnz .s2
    mov al, TURN0
    mov cl, [es:di]
    and cl, 0x03
    cmp cl, DIR_UP
    je .clockwise1
    cmp cl, DIR_RIGHT
    je .clockwise1
    .counterclockwise1:
    inc al
    .clockwise1:
    mov ah, 0x06
    mov [es:di], ax
    jmp .puthead
    .s2:
    mov al, TURN2
    mov cl, [es:di]
    and cl, 0x03
    cmp cl, DIR_UP
    je .clockwise2
    cmp cl, DIR_LEFT
    je .clockwise2
    .counterclockwise2:
    inc al
    .clockwise2:
    mov ah, 0x06
    mov [es:di], ax

    .puthead:
    mov di, [snake_head_addr]
    mov al, [snake_direction]
    add al, HEAD_LEFT
    mov ah, 0x06
    mov [es:di], ax

    .puttongue:
    mov di, [snake_tongue_addr]
    mov al, [es:di]
    and al, al
    jnz .fend
    mov al, [snake_direction]
    add al, TONGUE_LEFT
    mov ah, 0x8c
    mov [es:di], ax

    .fend:
    ret

Snake_UpdateTail:
    mov al, TAIL_LEFT
    mov ah, 0x06
    mov di, [snake_tail_addr]
    mov bl, [es:di]
    cmp bl, TURN0
    jae .turn
    and bl, 0x03
    add al, bl
    mov [es:di], ax
    jmp .fend

    .turn:
    mov di, [snake_tail_prev_addr]
    mov dl, [es:di]
    and dl, 0x03
    cmp dl, DIR_UP
    je .hturn
    cmp dl, DIR_DOWN
    je .hturn
    jmp .vturn
    .hturn:
    cmp bl, TURN0
    je .left
    cmp bl, TURN1
    je .right
    cmp bl, TURN2
    je .right
    cmp bl, TURN3
    je .left
        .left:
    mov al, TAIL_LEFT
    mov di, [snake_tail_addr]
    mov [es:di], ax
    jmp .fend
        .right:
    mov al, TAIL_RIGHT
    mov di, [snake_tail_addr]
    mov [es:di], ax
    jmp .fend
    .vturn:
    cmp bl, TURN0
    je .down
    cmp bl, TURN1
    je .up
    cmp bl, TURN2
    je .down
    cmp bl, TURN3
    je .up
        .up:
    mov al, TAIL_UP
    mov di, [snake_tail_addr]
    mov [es:di], ax
    jmp .fend
        .down:
    mov al, TAIL_DOWN
    mov di, [snake_tail_addr]
    mov [es:di], ax
    ;jmp .fend

    .fend:
    mov di, [snake_tail_prev_addr]
    mov ax, 0x0000
    mov [es:di], ax ;nadpisac poprzedni ogon
    ret

Snake_MoveHead:
    .fix:
    mov al, [snake_direction]
    mov di, [snake_head_addr]
    mov bl, [es:di]
    and al, 0x01
    and bl, 0x01
    cmp al, bl
    jne .head
    mov bl, [es:di]
    and bl, 0x03
    mov [snake_direction], bl

    .head:
    mov dl, [snake_direction]
    mov ax, [snake_tongue_addr]
    mov [snake_tongue_prev_addr], ax
    mov ax, [snake_head_addr]
    mov [snake_head_prev_addr], ax
    cmp dl, DIR_UP
    jne .s1
    sub ax, 80*2
    mov [snake_head_addr], ax
    sub ax, 80*2
    mov [snake_tongue_addr], ax
    jmp .fend
    .s1:
    cmp dl, DIR_DOWN
    jne .s2
    add ax, 80*2
    mov [snake_head_addr], ax
    add ax, 80*2
    mov [snake_tongue_addr], ax
    jmp .fend
    .s2:
    cmp dl, DIR_LEFT
    jne .s3
    sub ax, 2
    mov [snake_head_addr], ax
    sub ax, 2
    mov [snake_tongue_addr], ax
    jmp .fend
    .s3:
    cmp dl, DIR_RIGHT
    jne .fend
    add ax, 2
    mov [snake_head_addr], ax
    add ax, 2
    mov [snake_tongue_addr], ax

    .fend:
    ret

Snake_MoveTail:
    mov di, [snake_tail_addr]
    mov ax, di
    mov [snake_tail_prev_addr], ax
    mov dl, [es:di]
    and dl, 0x03
    cmp dl, DIR_UP
    jne .s4
    sub ax, 80*2
    mov [snake_tail_addr], ax
    jmp .fend
    .s4:
    cmp dl, DIR_DOWN
    jne .s5
    add ax, 80*2
    mov [snake_tail_addr], ax
    jmp .fend
    .s5:
    cmp dl, DIR_LEFT
    jne .s6
    sub ax, 2
    mov [snake_tail_addr], ax
    jmp .fend
    .s6:
    cmp dl, DIR_RIGHT
    jne .fend
    add ax, 2
    mov [snake_tail_addr], ax

    .fend:
    ret

Snake_CheckCollision:
    mov di, [snake_head_addr]
    mov al, [es:di]
    cmp al, 0x10
    jae .obstacle
    mov ax, 0
    jmp .fend
    .obstacle:
    cmp al, 0x90
    jb .fend
    mov ax, 0
    .fend:
    ret

Snake_CheckItem:
    mov di, [snake_head_addr]
    xor ah, ah
    mov al, [es:di]
    cmp al, 0x0a
    jbe .item
    .noitem:
    xor ax, ax
    .item:
    ret

snake_direction:
    db DIR_RIGHT
snake_tongue_addr:
    dw 0
snake_tongue_prev_addr:
    dw 0
snake_head_addr:
    dw 0
snake_head_prev_addr:
    dw 0
snake_tail_addr:
    dw 0
snake_tail_prev_addr:
    dw 0
