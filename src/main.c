#include <stdint.h>


//assign status[7:0] = { 6'd0, tx_active, rx_avail };

#define UART_MASK_RXAVAIL 1
#define UART_MASK_TXACTIVE 2

volatile uint8_t *UART_RXTX = (uint8_t*)0x100000;
volatile uint8_t *UART_STAT = (uint8_t*)0x100001;
volatile uint16_t *BOOTMODE = (uint16_t*)0;


int main(void) {
	while(1) {
		if( (*UART_STAT) & UART_MASK_RXAVAIL ) {
			char c = *UART_RXTX;
			*UART_RXTX = c;
		}
	}
	*BOOTMODE = 0xA9A9;
	return 0;
}
