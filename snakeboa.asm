bits 16
org 0x100

align 2

.start:
Init:
    mov ax, 3
    int 0x10
    mov ah, 1
    mov ch, 0x20
    int 0x10

    mov ax, 0x1110
    mov bh, 8
    xor bl, bl
    mov cx, 256
    xor dx, dx
    mov bp, font_data
    int 0x10

    jmp MainMenu_Load

font_data:
    incbin "misc/font.dat"

%include "misc.asm"
%include "pcspeaker.asm"
%include "music.asm"
%include "strings.asm"
%include "frames.asm"
%include "status.asm"
%include "mainmenu.asm"
%include "snake.asm"
%include "levels.asm"
%include "hiscores.asm"
