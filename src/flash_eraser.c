#include "m68kdefs.h"
#include "uart.h"
#include "flash.h"

void main(void) {
	uint32_t start;
	uint32_t ende;
	uart_printf("Flash eraser\n\n");
	uart_printf("Enter start address: ");
	uart_echo_on();
	uart_read_hex( &start );
	uart_printf("\nEnter end address: ");
	uart_read_hex( &ende );
	uart_echo_off();
	start &= 0xFFFFF000;
	ende |= 0xFFF;
	uart_printf( "\nWill erase from %08X to %08X\n", start, ende );
	uart_puts("Press y to delete flash");
	if( uart_getc() == 'y' ) {
		uart_puts("\n");
		while( start < ende ) {
			uart_printf("\rerase sector at %08X", start);
			flash_erase_sector( start );
			start += 0x1000;
		}
		uart_puts("\ndone.\n");
	} else {
		uart_puts("\ncanceled.\n");
	}
}
