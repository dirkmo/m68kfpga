INCS = -I/opt/m68k/m68k-elf/include/ -I . -I ..
LIBS = -L /opt/m68k/m68k-elf/lib/m68000 -L /opt/m68k/lib/gcc/m68k-elf/5.2.0/m68000 -L fatfs/
CFLAGS = -m68000 -os -fomit-frame-pointer -fno-builtin -g -Wall
AFLAGS = -m68000

bootstrap: bootstrap.c bs_crt0.o uart.o flash.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c bootstrap.c -o bootstrap.o
	m68k-elf-ld $(LIBS) -Map=bootstrap.map -nostartfiles -T bootstrap.ld bs_crt0.o bootstrap.o uart.o flash.o -lc -lgcc -o bootstrap
	m68k-elf-objcopy -O binary -S bootstrap bootstrap.bin
	../host/bin2verilog bootstrap.bin > bootstrap.v

bootstage1: bootstage1.c bs_crt0.o uart.o flash.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c bootstage1.c -o bootstage1.o
	m68k-elf-ld $(LIBS) -Map=bootstage1.map -nostartfiles -T bootstage1.ld bs_crt0.o bootstage1.o uart.o flash.o -lc -lgcc -o bootstage1
	m68k-elf-objcopy -O binary -S bootstage1 bootstage1.bin
	../host/bin2verilog bootstage1.bin > bootstage1.v

userprog: userprog.c uart.o crt0.o flash.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c userprog.c -o userprog.o
	m68k-elf-ld $(LIBS) -Map=userprog.map -nostartfiles -T userprog.ld crt0.o uart.o flash.o userprog.o -o userprog
	m68k-elf-objcopy -O srec -S userprog userprog.hex

timertest: timertest.c uart.o crt0.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c timertest.c -o timertest.o
	m68k-elf-ld $(LIBS) -Map=timertest.map -nostartfiles -T userprog.ld crt0.o uart.o timertest.o  -o timertest
	m68k-elf-objcopy -O srec -S timertest timertest.hex

spitest: spitest.c uart.o crt0.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c spitest.c -o spitest.o
	m68k-elf-ld $(LIBS) -Map=spitest.map -nostartfiles -T userprog.ld crt0.o uart.o spitest.o  -o spitest
	m68k-elf-objcopy -O srec -S spitest spitest.hex

inttest: inttest.o crt0.o uart.o fifo.o
	m68k-elf-ld $(LIBS) -Map=inttest.map -nostartfiles -T userprog.ld crt0.o uart.o fifo.o inttest.o -lgcc -o inttest
	m68k-elf-objcopy -O srec -S inttest inttest.hex

flash_eraser: flash_eraser.o uart.o crt0.o flash.o
	m68k-elf-ld $(LIBS) -Map=flash_eraser.map -nostartfiles -T userprog.ld crt0.o uart.o flash.o flash_eraser.o  -o flash_eraser
	m68k-elf-objcopy -O srec -S flash_eraser flash_eraser.hex

fattest: libfatfs.a crt0.o flash.o uart.o fattest.o
	m68k-elf-ld $(LIBS) -Map=fatfs.map -nostartfiles -T userprog.ld crt0.o uart.o flash.o fattest.o -lfatfs -lgcc -o fattest
	m68k-elf-objcopy -O srec -S fattest fattest.hex

test: test.c bs_crt0_intvec.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c test.c -o test.o
	m68k-elf-ld $(LIBS) -Map=test.map -nostartfiles -T bootstrap.ld bs_crt0_intvec.o test.o -lc -lgcc -o test
	m68k-elf-objcopy -O binary -S test test.bin
	../host/bin2verilog test.bin > test.v

libfatfs.a: fatfs/diskio.o fatfs/ff.o fatfs/sdcard.o fatfs/sdcard.o
	rm -f fatfs/libfatfs.a
	m68k-elf-ar cr fatfs/libfatfs.a fatfs/diskio.o fatfs/ff.o fatfs/sdcard.o

crt0.o: crt0.s
	m68k-elf-as $(AFLAGS) crt0.s -o crt0.o

bs_crt0.o: bs_crt0.s
	m68k-elf-as $(AFLAGS) bs_crt0.s -o bs_crt0.o

bs_crt0_intvec.o: bs_crt0_intvec.s
	m68k-elf-as $(AFLAGS) bs_crt0_intvec.s -o bs_crt0_intvec.o

%.o: %.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c $< -o $@
	
clean:
	rm -f bootstrap bootstage1 *.o *.bin
