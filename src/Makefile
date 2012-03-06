

all:boot_loader.o first_process.o second_process.o

clean:
	rm *.o
.s.o:
	nasm -f bin -o $@ $<

#bootloader:
#	nasm -f bin -o bootloader boot_loader.s
#firstprocess:
#	nasm -f bin -o firstprocess first_process.s
#secondprocess:
#	nasm -f bin -o secondprocess second_process.s
