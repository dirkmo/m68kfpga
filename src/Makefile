INCS = -I/opt/m68k/m68k-elf/include/
LIBS = -L /opt/m68k/m68k-elf/lib/m68000 -L /opt/m68k/lib/gcc/m68k-elf/5.2.0/m68000
CFLAGS = -m68000 -os -fomit-frame-pointer -fno-builtin
AFLAGS = -m68000

bootstrap: bootstrap.c bs_crt0.o uart.o flash.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c bootstrap.c -o bootstrap.o
	m68k-elf-ld $(LIBS) -Map=main.map -nostartfiles -T link.ld bs_crt0.o bootstrap.o uart.o flash.o -lc -o bootstrap
	m68k-elf-objcopy -O binary -S bootstrap bootstrap.bin
	../host/bin2verilog bootstrap.bin > bootstrap.v

test: test.c crt0.o uart.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c test.c -o test.o
	m68k-elf-ld $(LIBS) -nostartfiles -T link_userprog.ld crt0.o uart.o -lc test.o -o test
	m68k-elf-objcopy -O srec -S test test.hex

userprog: userprog.c uart.o crt0.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c userprog.c -o userprog.o
	m68k-elf-ld $(LIBS) -nostartfiles -T link_userprog.ld crt0.o uart.o userprog.o -lc -o userprog
	m68k-elf-objcopy -O srec -S userprog userprog.hex

crt0.o: crt0.s
	m68k-elf-as $(AFLAGS) crt0.s -o crt0.o

bs_crt0.o: bs_crt0.s
	m68k-elf-as $(AFLAGS) bs_crt0.s -o bs_crt0.o
	
%.o: %.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c $< -o $@
	
clean:
	rm -f bootstrap *.o

bin:
	m68k-elf-objcopy -O srec -S main main.hex
	m68k-elf-objcopy -O binary -S main main.bin
