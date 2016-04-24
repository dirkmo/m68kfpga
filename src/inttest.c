#include "m68kdefs.h"
#include "fifo.h"

static char rxbuf[16];
static char txbuf[16];

static FIFO fifo_rx = {
	.first = 0,
	.count = 0,
	.len = sizeof(rxbuf),
	.buf = rxbuf
};

static FIFO fifo_tx = {
	.first = 0,
	.count = 0,
	.len = sizeof(txbuf),
	.buf = txbuf
};


void __attribute__ ((interrupt)) interrupt2(void)
{
	// potentiell müssen noch d0/d1, a0/a1 gepusht und ge-pop't werden.
	if( INT_STATUS & INT_UART_RX ) {
		while( UART_STAT & UART_MASK_RXAVAIL ) {
			//char ch = UART_RXTX;
			fifo_push( &fifo_rx, UART_RXTX );
		}
	}
	if( INT_STATUS & INT_UART_TX ) {
		if( !fifo_is_empty(&fifo_tx) ) {
			char ch;
			fifo_pop( &fifo_tx, &ch );
			UART_RXTX = ch;
		}
		//UART_RXTX = '0' + INT_STATUS;
	}
	INT_STATUS &= ~INT_UART_RX & ~INT_UART_TX;
}


typedef enum intvector_t {
	INTVEC_SSP = 0,
	INTVEC_RESET = 1,
	INTVEC_BERR = 2,
	INTVEC_AERR = 3,
	INTVEC_ILLINSTR = 4,
	INTVEC_ZERODIV = 5,
	INTVEC_CHKINSTR = 6,
	INTVEC_TRAPV = 7,
	INTVEC_PRIVIOL = 8,
	INTVEC_TRACE = 9,
	INTVEC_UNINIT = 15,
	
	INTVEC_AUTO1 = 25,
	INTVEC_AUTO2 = 26,
	INTVEC_AUTO3 = 27,
	INTVEC_AUTO4 = 28,
	INTVEC_AUTO5 = 29,
	INTVEC_AUTO6 = 30,
	INTVEC_AUTO7 = 31,
	
	INTVEC_TRAP0 = 32,
	INTVEC_TRAP1 = 33,
	INTVEC_TRAP2 = 34,
	INTVEC_TRAP3 = 35,
	INTVEC_TRAP4 = 36,
	INTVEC_TRAP5 = 37,
	INTVEC_TRAP6 = 38,
	INTVEC_TRAP7 = 39,
	INTVEC_TRAP8 = 40,
	INTVEC_TRAP9 = 41,
	INTVEC_TRAP10 = 42,
	INTVEC_TRAP11 = 43,
	INTVEC_TRAP12 = 44,
	INTVEC_TRAP13 = 45,
	INTVEC_TRAP14 = 46,
	INTVEC_TRAP15 = 47
} intvector_t;

void register_int( intvector_t idx, void (*int_func)(void) ) {
	uint32_t *vector = 0;
	vector[idx] = (uint32_t)int_func;
}

void delay(uint32_t t) {
	while(t--) {
		__asm__("nop");
	}
}

void print_int( const char *s ) {
	char first = *s++;
	while( *s ) {
		fifo_push( &fifo_tx, *s++ );
	}
	UART_RXTX = first;
}

int main(void) {
	BOOTMODE_END();
	INT_STATUS = 0;
	register_int( INTVEC_AUTO1, interrupt2 );
	INT_CTRL = INT_CTRL_ENABLE;
	INT_ENABLE = INT_UART_RX | INT_UART_TX;
	__asm__("ORI.W  #0xF000, %SR"); // Put in new IPL bits
	__asm__("ANDI.W #0xF000, %SR"); // Mask off old IPL bits
	
	print_int("Hallo Welt!\n");
	
	while( !fifo_is_empty( &fifo_tx) );
	INT_ENABLE = INT_UART_RX;
	char ch;
	while(1) {
		if( !fifo_is_empty( &fifo_rx ) ) {
			fifo_pop( &fifo_rx, &ch );
			UART_RXTX = ch;
		}
	}
}
