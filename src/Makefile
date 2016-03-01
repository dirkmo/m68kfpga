INCS = -I/opt/m68k/m68k-elf/include/
LIBS = -L /opt/m68k/m68k-elf/lib/m68000 -L /opt/m68k/lib/gcc/m68k-elf/5.2.0/m68000
CFLAGS = -m68000 -os -fomit-frame-pointer -fno-builtin
AFLAGS = -m68000

all: bs_crt0.o main.o
	#m68k-elf-ld -Map=main.map $(LIBS) -T lscript.ld bs_crt0.o main.o -o main
	m68k-elf-ld -Map=main.map -nostartfiles -T link.ld bs_crt0.o main.o -o main
#	m68k-elf-gcc -nostartfiles -Wl,-Ttext=0 crt0.o main.o -o main

helloworld: bs_crt0.o helloworld.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c helloworld.c -o helloworld.o
	m68k-elf-ld -Map=main.map -nostartfiles -T link.ld bs_crt0.o helloworld.o -o helloworld
	m68k-elf-objcopy -O binary -S helloworld helloworld.bin
	../host/bin2verilog helloworld.bin > helloworld.v

leds: bs_crt0.o leds.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c leds.c -o leds.o
	m68k-elf-ld -Map=main.map -nostartfiles -T link.ld bs_crt0.o leds.o -o leds
	m68k-elf-objcopy -O binary -S leds leds.bin
	../host/bin2verilog leds.bin > leds.v

bootstrap: bootstrap.c bs_crt0.o uart.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c bootstrap.c -o bootstrap.o
	m68k-elf-ld $(LIBS) -Map=main.map -nostartfiles -T link.ld bs_crt0.o bootstrap.o uart.o -lc -o bootstrap
	m68k-elf-objcopy -O binary -S bootstrap bootstrap.bin
	../host/bin2verilog bootstrap.bin > bootstrap.v

test: test.c bs_crt0.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c test.c -o test.o
	m68k-elf-ld $(LIBS) -nostartfiles -T link.ld bs_crt0.o test.o -o test
	m68k-elf-objcopy -O binary -S test test.bin
	../host/bin2verilog test.bin > test.v

flash.o: flash.c flash.h
	m68k-elf-gcc $(CFLAGS) $(INCS) -c flash.c -o flash.o

userprog: userprog.c uart.o crt0.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c userprog.c -o userprog.o
	m68k-elf-ld $(LIBS) -nostartfiles -T link_userprog.ld crt0.o uart.o userprog.o -lc -o userprog
	m68k-elf-objcopy -O srec -S userprog userprog.hex

	
spitest: spitest.c crt0.o
	m68k-elf-gcc $(CFLAGS) $(INCS) -c spitest.c -o spitest.o
	m68k-elf-ld $(LIBS) -nostartfiles -T link_userprog.ld crt0.o spitest.o -lc -Map=spitest.map -o spitest
	m68k-elf-objcopy -O srec -S spitest spitest.hex


bs_crt0.o: bs_crt0.s
	m68k-elf-as $(AFLAGS) $(INCS) bs_crt0.s -o bs_crt0.o

crt0.o: crt0.s
	m68k-elf-as crt0.s $(AFLAGS) -o crt0.o

uart.o: uart.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c uart.c -o uart.o
	
main.o: main.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c main.c -o main.o

clean:
	rm -f main helloworld bootstrap *.o

bin:
	m68k-elf-objcopy -O srec -S main main.hex
	m68k-elf-objcopy -O binary -S main main.bin
	../host/bin2verilog main.bin > main.v
