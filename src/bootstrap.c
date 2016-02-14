#include "m68kdefs.h"
#include "uart.h"

static char toupper(char c) {
	if(c>='a' && c <= 'z' ) c-='a'+'A';
	return c;
}

static uint8_t nibble_to_uint8( char nibble ) {
	nibble = toupper(nibble) - '0';
	if( nibble > 9 ) {
		nibble -= 'A'-'0'-10;
	}
	return nibble;
}

static void execute(uint32_t address) {
	void (*func)();
	func = (void*)address;
	func();
}

static uint8_t get_record_type( uint8_t *buf ) {
    uint8_t record = buf[1] - '0';
	return record;
}

static uint8_t get_bytecount( uint8_t *buf ) {
	return (nibble_to_uint8( buf[2] ) << 4) | nibble_to_uint8( buf[3] );
}

static uint32_t get_address( uint8_t *buf, uint8_t rectype ) {
	uint32_t address = 0;
	uint8_t count = 4;
	uint8_t i;
	if( rectype == 2 ) count = 6; else
	if( rectype == 3 ) count = 8;
	address = 0;
	i = 4; // Address starts at index 4
	while( count-- ) {
		address = (address << 4) | nibble_to_uint8( buf[i++] );
	}
	return address;
}

static char validate( uint8_t *buf ) {
	uint8_t chksum = 0;
	buf+=2; // skip record type
	while(*buf != '\r' && *buf != '\n' && *buf != '\0' ) {
		chksum += nibble_to_uint8(*buf++)<<4;
		chksum += nibble_to_uint8(*buf++);
	}
	return chksum==0xFF;
}

void main(void) {
	uint32_t start_address = 0xFFFFFFFF;
	uint32_t address;
    char record;
    uint8_t bytecount;
    uint8_t linebuf[60];
	int i;
    char c;
	uint8_t *dst;
	uart_puts("\x1B[2J\x1B[1;1Hm68k fpga bootloader\r\n\n");
   	uart_puts("Waiting for srecord data, (g) to execute > ");
    while( 1 ) {
    	c = uart_getc();
	    if( c == 'g' ) {
	    	execute( start_address );
	    	continue;
	    } else if( c != 'S' ) {
	    	uart_putc('E');
	    	continue;
	    }
		linebuf[0] = 'S';
		uart_readln( linebuf+1, sizeof(linebuf) );

		if ( !validate( linebuf ) ) {
			// Checksum error
			uart_putc('E');
			continue;
		}

		record = get_record_type( linebuf );
		bytecount = get_bytecount( linebuf ) - (record<2 ? 3 : record+2);
		address = get_address( linebuf, record );		
		if( record > 0 && record < 4 ) {
			// copy data to memory
			dst = (uint8_t*)address;
			i = 4 + ( (record==0) ? 4 : record*2+2);
			while( bytecount > 1 ) {
				c = (nibble_to_uint8(linebuf[i++]) << 4);
				c |= nibble_to_uint8(linebuf[i++]);
				bytecount--;
				*dst++ = c;
			}
		} else if( record > 6 && record < 10 ) {
			start_address = address;
		}
		uart_putc('K');
    }
}

