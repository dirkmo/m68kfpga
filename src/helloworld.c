#include "m68kdefs.h"

//static const uint8_t str[] = "Hello, world!\n";

int main(void) {
	uint8_t i = 'A';

	UART_RXTX = i;
	
	i++;
	UART_RXTX = i;
	
	i++;
	UART_RXTX = i;
	
	BOOTMODE_END();
}

