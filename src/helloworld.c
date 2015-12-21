#include "m68kdefs.h"

static const uint8_t str[] = "Hello, world!\n";

int main(void) {
	uint16_t i;

	for( i = 0; i<sizeof(str)-1; i++) {
		UART_RXTX = str[i];	
	}
	
	BOOTMODE_END();
}

