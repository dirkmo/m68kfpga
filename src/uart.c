#include "m68kdefs.h"
#include "uart.h"
#include <stdarg.h>
#include <stdbool.h>

static uint8_t echo_on = 0;
static uint8_t overflow = 0;

void uart_echo_on(void) {
    echo_on = 1;
}

void uart_echo_off(void) {
    echo_on = 0;
}

uint8_t uart_rx_overflow(void) {
	uint8_t ov = overflow;
	overflow = 0;
	return ov != 0;
}

int toupper( int c ) {
	if( c >= 'a' && c <= 'z' ) {
		return c - 'a' + 'A';
	}
	return c;
}

uint32_t strlen( const char *str ) {
	uint32_t count = 0;
	while( *str++ ) {
		count++;
	}
	return count;
}

void uint2hex(uint32_t val, unsigned char *str, uint8_t hexchars) {
	uint8_t i;
	uint8_t nibble;
	uint8_t shift = ((hexchars-1)<<2);
	uint32_t mask = 0x0F << shift;
    for(i = 0; i<hexchars; ++i) {
        nibble = (val & mask) >> shift;
        if(nibble < 10) {
            str[i] = nibble + '0';
        } else {
            str[i] = nibble + 'A' - 10;
        }
        val = val << 4;
    }
    str[hexchars] = 0;
}

uint32_t hex2uint(const char *s, uint8_t len) {
    uint32_t val=0;
	uint8_t nibble;
	while(*s && len) {
		val=(val<<4);
		nibble=toupper(*s)-'0';
		if(nibble>9)
			nibble+=10+'0'-'A';
		val |= nibble;
		++s;
		--len;
	}
	return val;
}

uint8_t uart_getc(void) {
    int ch;
    int status = 0;
    while(1) {
        status = UART_STAT;
		overflow |= status & UART_MASK_RXOVERFLOW;
		if( status & UART_MASK_RXAVAIL ) {
			break;
		}
    }
    ch = UART_RXTX;
    if(echo_on) {
        UART_RXTX = ch;
    }
    return ch;
}

uint8_t uart_putc(uint8_t c) {
    UART_RXTX = c;
    return c;
}

uint8_t uart_readln(uint8_t *buf, uint8_t maxlen) {
    uint8_t i=0;
    do {
        if( i < maxlen ) {
            buf[i] = uart_getc();
            ++i;
        } else {
        	break;
        }
    } while(buf[i-1] != CR && buf[i-1] != LF);
    buf[i-1] = 0;
    return i;
}

void uart_puts(const uint8_t *str) {
    while(*str) {
        UART_RXTX = *str;
        ++str;
    }
}

uint8_t uart_read_hex(uint32_t *val) {
    uint8_t buf[10];
    int len;
    uart_readln(buf, sizeof(buf));
    len = strlen((char*)buf);
    if(len==0) {
        return 0;
    }
    *val = hex2uint((char*)buf, len<<1);
    return 1;
}

void uart_write_hex(uint32_t num, uint8_t chars) {
    uint8_t buf[10];
    uint2hex(num, buf, chars);
    uart_puts(buf);
}

void uart_write_dec(uint32_t num) {
	int i;
	int count = 1;
	char s[14] = { 0 };
	s[0] = '0' + (num%10);
	num /= 10;
	while( num ) {
		s[count] = '0' + (num%10);
		num /= 10;
		++count;
	}
	for( i=count-1; i>=0; i-- ) {
		uart_putc( s[i] );
	}
}

void uart_printf( const char *s, ... ) {
	bool sym = false;
	int num_len = 8;
	va_list vl;
	va_start( vl, s );

	for( ; *s ; s++ ) {
		if( *s == '%' && !sym ) {
			sym = true;
			continue;
		}
		if( sym ) {
			switch( *s ) {
				case 'd': /* fall through*/
				case 'i':
					uart_write_dec( va_arg(vl, int) );
					sym = false;
					break;
				case 'u':
					uart_write_dec( va_arg(vl, unsigned int) );
					sym = false;
					break;
				case 's':
					uart_puts( va_arg(vl,uint8_t*) );
					sym = false;
					break;
				case 'X':
				case 'x':
					uart_write_hex( va_arg(vl, unsigned int), num_len );
					num_len = 8;
					sym = false;
					break;
				case '1'...'9':
					num_len = *s - '0';
					break;
				default: ;
			}
		} else {
			uart_putc( *s );
		}
	}
	va_end(vl);
}
