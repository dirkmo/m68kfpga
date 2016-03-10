#include "uart.h"
#include "flash.h"

void main(void) {
	BOOTMODE_END();
	uart_puts("Hallo aus dem Userland :-)\n");
	uart_printf("read-id: %04X\n", flash_read_id() );
	uart_printf("jedec-id: %08X\n", flash_read_jedec() );
	while(1);
}
