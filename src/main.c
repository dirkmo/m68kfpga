#include "m68kdefs.h"

void putstr(const char *str) {
	while(*str) {
		UART_RXTX = *str++;	
	}
}

int main(void) {
	putstr("\x1B[2J\x1B[1;1Hm68kfpga system\n");
	char buf[100];
	int i = 0;
	char c;
	while(1) {
		putstr("Text eingeben: ");
		c=0;
		while( c != '\r' ) {
			if( UART_STAT & UART_MASK_RXAVAIL ) {
				c = buf[i] = UART_RXTX;
				i++;
			}
		}
		buf[i+1] = '\n';
		buf[i+2] = '\0';
		i = 0;
		putstr("\nEs wurde eingegeben: ");
		putstr( buf );
	}
	return 0;
}

