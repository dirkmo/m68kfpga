#include "m68kdefs.h"
#include "uart.h"
#include "flash.h"

#define ENTRY_POINT 0x1000

void main(void) {
	uart_puts("m68k system starting.\n");
	flash_read(
		0, // flash address
		(char*)ENTRY_POINT, // memory address
		0x1000 // byte count
	);
	void (*func)() = (void*)ENTRY_POINT;
	func();
}
