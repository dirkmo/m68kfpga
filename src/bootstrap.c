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
	uart_puts("\nCalling 0x");
	uart_write_hex(address, 8);
	uart_puts("\n");
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

static void dump(void) {
	uint32_t addr;
	uint32_t len;
	uart_echo_on();
	uart_puts("\ndump address: ");
	if ( uart_read_hex( &addr ) == 0 ) {
		uart_echo_off();
		return;
	}
	uart_puts("\nlen: ");
	if ( uart_read_hex( &len ) == 0 ) {
		len = 256;
	}
	uart_putc('\n');
	int i;
	for( i=0; i<len; i++ ) {
		if( i % 16 == 0 ) {
			uart_putc('\n');
			uart_write_hex(addr, 8);
			uart_puts(": ");
		}
		uart_write_hex( *( (uint8_t*)addr ), 2 );
		uart_putc(' ');
		addr++;
	}
	uart_puts("\n\n");
	uart_echo_off();
}

/*
void mem_test(void) {
	int count = 0;
	uart_puts("Mem test start.\n");
	uint8_t *mem = (uint8_t*)0x2000;
	while(mem < (uint8_t*)0x100000) {
		if( (uint32_t)mem%0x1000 == 0 ) {
			uart_puts("\rWriting ");
			uart_write_hex( (uint32_t)mem, 8 );
		}
		*mem = ((uint32_t)mem)&255;
		mem++;
	}
	uart_puts("\n");
	mem = (uint8_t*)0x2000;
	while( mem < (uint8_t*)0x100000 ) {
		if( (uint32_t)mem%0x1000 == 0 ) {
			uart_puts("\rReading ");
			uart_write_hex( (uint32_t)mem, 8 );
		}
		if( ((uint8_t)(*mem)) != (uint8_t)( ((uint32_t)mem)&255 ) ){
			count++;
			uart_puts("\nError at 0x");
			uart_write_hex((uint32_t)mem,8);
			uart_puts(": 0x");
			uart_write_hex((uint8_t)(*mem),8);
			uart_puts("\n");
		}
		mem++;
		if(count > 50) {
			break;
		}
	}
}
*/
void main(void) {
	uint32_t start_address = 0xFFFFFFFF;
	uint32_t address;
    char record;
    int8_t bytecount;
    uint8_t linebuf[60];
	int i;
    char c;
	uint8_t *dst;
	start:
	uart_puts("\x1B[2J\x1B[1;1Hm68k fpga bootloader\r\n\n");
   	uart_puts("Waiting for srecord data, (d) for dump, (g) to execute > ");
    while( 1 ) {
    	c = uart_getc();
	    if( c == 'g' ) {
	    	execute( start_address );
	    	continue;
    	} else if( c == 'h' ) {
    		goto start;
    	} else if( c == 'm' ) {
    		//mem_test();
    		continue;
    	} else if( c == 'd' ) {
    		dump();
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
			while( bytecount > 0 ) {
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

