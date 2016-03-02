INCS = -I/opt/m68k/m68k-elf/include/
LIBS = -L /opt/m68k/m68k-elf/lib/m68000 -L /opt/m68k/lib/gcc/m68k-elf/5.2.0/m68000
CFLAGS = -m68000 -os -fomit-frame-pointer -fno-builtin
AFLAGS = -m68000

bootstrap: bootstrap.c bs_crt0.o uart.o flash.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c bootstrap.c -o bootstrap.o
	m68k-elf-ld $(LIBS) -Map=bootstrap.map -nostartfiles -T bootstrap.ld bs_crt0.o bootstrap.o uart.o flash.o -o bootstrap
	m68k-elf-objcopy -O binary -S bootstrap bootstrap.bin
	../host/bin2verilog bootstrap.bin > bootstrap.v

bootstage1: bootstage1.c bs_crt0.o uart.o flash.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c bootstage1.c -o bootstage1.o
	m68k-elf-ld $(LIBS) -Map=bootstage1.map -nostartfiles -T bootstage1.ld bs_crt0.o bootstage1.o uart.o flash.o -o bootstage1
	m68k-elf-objcopy -O binary -S bootstage1 bootstage1.bin
	../host/bin2verilog bootstage1.bin > bootstage1.v

userprog: userprog.c uart.o crt0.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c userprog.c -o userprog.o
	m68k-elf-ld $(LIBS) -Map=userprog.map -nostartfiles -T link_0x1000.ld crt0.o uart.o userprog.o  -o userprog
	m68k-elf-objcopy -O srec -S userprog userprog.hex

crt0.o: crt0.s
	m68k-elf-as $(AFLAGS) crt0.s -o crt0.o

bs_crt0.o: bs_crt0.s
	m68k-elf-as $(AFLAGS) bs_crt0.s -o bs_crt0.o
	
%.o: %.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c $< -o $@
	
clean:
	rm -f bootstrap bootstage1 *.o *.bin
