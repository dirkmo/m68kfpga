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
	while(1) {
		if ( i == 0 ) {
			putstr("Text eingeben: ");
		}
		if( UART_STAT & UART_MASK_RXAVAIL ) {
			if( i < 98 ) {
				buf[i] = UART_RXTX;
				UART_RXTX = buf[i];
				if( buf[i] == '\r' ) {
					buf[i+1] = '\n';
					buf[i+2] = '\0';
					i = 0;
					putstr("\nEs wurde eingegeben: ");
					putstr( buf );
				} else {
					i++;
				}
			}
			
		}
	}
	return 0;
}

