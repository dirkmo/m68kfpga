#include "uart.h"

void main(void) {
	BOOTMODE_END();
	uart_puts("Hallo aus dem Userland :-)\n");
	while(1);
}
