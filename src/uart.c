#include "m68kdefs.h"
#include "uart.h"
#include <string.h>
#include <ctype.h>

static uint8_t echo_on = 0;

void uart_echo_on(void) {
    echo_on = 1;
}

void uart_echo_off(void) {
    echo_on = 0;
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
    while(status == 0) {
        status = UART_STAT & UART_MASK_RXAVAIL;
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

void uart_readln(uint8_t *buf, uint8_t maxlen) {
    int i=0;
    do {
        buf[i] = uart_getc();
        if( i < maxlen ) {
            ++i;
        }
    } while(buf[i-1] != CR && buf[i-1] != LF);
    buf[i-1] = 0;
}

void uart_puts(uint8_t *str) {
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
    *val = hex2uint(buf, len<<1);
    return 1;
}

void uart_write_hex(uint32_t num, uint8_t chars) {
    uint8_t buf[10];
    uint2hex(num, buf, chars);
    uart_puts(buf);
}
