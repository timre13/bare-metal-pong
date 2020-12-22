run: pong.img
	qemu-system-i386 -drive file=pong.img,format=raw -soundhw pcspk

pong.img: main.asm video.asm string.asm timer.asm gamelogics.asm keyboard.asm random.asm sound.asm
	nasm -fbin main.asm -o pong.img

clean:
	rm -f *.img
	rm -f bochslog.txt
