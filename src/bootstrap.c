#include "m68kdefs.h"
#include "uart.h"
#include "flash.h"

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

static uint8_t hex_prompt( const char *str, uint32_t *number ) {
	uart_puts( str );
	uart_echo_on();
	uint8_t ret = uart_read_hex( number );
	uart_putc('\n');
	uart_echo_off();
	return ret;
}

static void execute(uint32_t address) {
	void (*func)();
	char str[22] = "Address (01234567): ";
	uint2hex(address, str+9, 8);
	str[17]=')';
	hex_prompt( str, &address );
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
	if( hex_prompt( "address: ", &addr ) == 0 ) {
		return;
	}
	if( hex_prompt( "len: ", &len ) == 0 ) {
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
}

static void erase_sector(void) {
	uint32_t addr;
	if( hex_prompt( "address: ", &addr ) == 0 ) {
		return;
	}
	flash_remove_bpl();
	flash_erase_sector(addr);
	uart_write_hex( addr & 0xFFFFF000, 8 );
	uart_puts(" - ");
	uart_write_hex( addr | 0x00000FFF, 8 );
	uart_puts("ok\n");
}

static void write_flash(void) {
	uint32_t mem_addr;
	uint32_t flash_addr;
	uint32_t len;
	uart_puts("mem ");
	if( hex_prompt( "address: ", &mem_addr ) == 0 ) {
		return;
	}
	if( hex_prompt( "count: ", &len ) == 0 ) {
		return;
	}
	uart_puts("flash ");
	if( hex_prompt( "address: ", &flash_addr ) == 0 ) {
		return;
	}
	flash_remove_bpl();
	flash_write_bytes( (char*)mem_addr, len, flash_addr );
	uart_puts("ok\n");
}

static void read_flash(void) {
	uint32_t mem_addr;
	uint32_t flash_addr;
	uint32_t len;
	uart_puts("flash ");
	if( hex_prompt( "address: ", &flash_addr ) == 0 ) {
		return;
	}
	if( hex_prompt( "count: ", &len ) == 0 ) {
		return;
	}
	uart_puts("mem ");
	if( hex_prompt( "address: ", &mem_addr ) ) {
		flash_read(flash_addr, (char*)mem_addr, len);
		uart_puts("ok\n");
	}
}

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
	uart_puts("\x1B[2J\x1B[1;1Hm68k fpga monitor\r\n\n");
   	uart_puts("(d)ump (g)o, (e)rase sector, (w)rite flash, (r)ead flash\n");
    while( 1 ) {
    	c = uart_getc();
	    if( c == 'g' ) {
	    	execute( start_address );
	    	continue;
    	} else if( c == 'h' ) {
    		goto start;
    	} else if( c == 'd' ) {
    		dump();
    		continue;
    	} else if( c == 's' ) {
    		uart_puts("address: ");
    		uart_write_hex( start_address, 8 );
    		uart_putc('\n');
    		continue;
    	} else if( c == 'e' ) {
    		erase_sector();
			continue;
    	} else if( c == 'w' ) {
			write_flash();
    		continue;
    	} else if( c == 'r' ) {
			read_flash();
    		continue;
		} else if( c != 'S' ) {
	    	continue;
	    }
		linebuf[0] = 'S';
		uint8_t line_len = uart_readln( linebuf+1, sizeof(linebuf)-1 );

		if ( ( line_len == sizeof(linebuf)-1 ) || !validate( linebuf ) ) {
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

