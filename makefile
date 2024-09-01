SNAKEBOA.COM: snakeboa.asm pcspeaker.asm misc.asm music.asm strings.asm status.asm mainmenu.asm frames.asm snake.asm levels.asm hiscores.asm
	nasm -f bin snakeboa.asm -o $@

clean:
	rm *.COM

run:
	dosbox SNAKEBOA.COM -exit

