INCS = -I/opt/m68k/m68k-elf/include/
LIBS = -L/opt/m68k/m68k-elf/lib/ -L/opt/m68k/lib/gcc/m68k-elf/5.2.0/m68000
CFLAGS = -m68000 -o0 -fomit-frame-pointer
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

bs_crt0.o: bs_crt0.s
	m68k-elf-as $(AFLAGS) $(INCS) bs_crt0.s -o bs_crt0.o

crt0.o: crt0.s
	m68k-elf-as crt0.s $(AFLAGS) -o crt0.o

	
main.o: main.c
	m68k-elf-gcc $(CFLAGS) $(INCS) -c main.c -o main.o

clean:
	rm -f main main.o bs_crt0.o crt0.o helloworld.o helloworld

bin:
	m68k-elf-objcopy -O srec -S main main.hex
	m68k-elf-objcopy -O binary -S main main.bin
	../host/bin2verilog main.bin > main.v
