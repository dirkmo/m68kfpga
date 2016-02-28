#include "m68kdefs.h"
#include "uart.h"
#include <stdbool.h>

typedef enum flash_cmd_t {
	FLASH_CMD_READ			= 0x03,
	FLASH_CMD_4K_ERASE		= 0x20,
	FLASH_CMD_32K_ERASE		= 0x52,
	FLASH_CMD_64K_ERASE		= 0xD8,
	FLASH_CMD_CHIP_ERASE	= 0x60,
	FLASH_CMD_BYTE_PRG		= 0x02,
	FLASH_CMD_AAI_PRG		= 0xAD,
	FLASH_CMD_RDSR			= 0x05,
	FLASH_CMD_EWSR			= 0x50,
	FLASH_CMD_WRSR			= 0x01,
	FLASH_CMD_WREN			= 0x06,
	FLASH_CMD_WRDI			= 0x04,
	FLASH_CMD_RDID			= 0x90,
	FLASH_CMD_JEDECID		= 0x9F,
	FLASH_CMD_EBSY			= 0x70,
	FLASH_CMD_DBSY			= 0x80,
} flash_cmd_t;

bool flash_is_busy(void) {
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_RDSR;
	SPI_RXTX = 0; // clk erzeugen
	uint8_t status = SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
	return status & 0x01;
}

uint16_t flash_read_id(void) {
	while(flash_is_busy());
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_RDID;
	// 24 bit Address
	SPI_RXTX = 0;
	SPI_RXTX = 0;
	SPI_RXTX = 0;
	// read id
	SPI_RXTX = 0;
	uint16_t readid = SPI_RXTX << 8;
	SPI_RXTX = 0;
	readid |= SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
	return readid;
}

uint32_t flash_read_jedec(void) {
	while(flash_is_busy());
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Jedec ID
	SPI_RXTX = FLASH_CMD_JEDECID;
	SPI_RXTX = 0;
	uint32_t jedecid = SPI_RXTX << 16;
	SPI_RXTX = 0;
	jedecid |= SPI_RXTX << 8;
	SPI_RXTX = 0;
	jedecid |= SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
	return jedecid;
}

void flash_enable_write(void) {
	while(flash_is_busy());
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_WREN;
	SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
}

void flash_read( uint32_t addr, char *dst, uint32_t len ) {
	while(flash_is_busy());
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_READ;
	// 24 bit Address
	SPI_RXTX = (addr>>16) & 0xFF;
	SPI_RXTX = (addr>>8) & 0xFF;
	SPI_RXTX = addr & 0xFF;
	while( len-- ) {
		SPI_RXTX = 0; // clk erzeugen
		*dst++ = SPI_RXTX;
	}
	SPI_CTRL = 0; // Deselect flash
}

void flash_disable_write(void) {
	while(flash_is_busy());
	flash_enable_write();
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_WRDI;
	SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
}

void flash_write_bytes( uint32_t addr, uint8_t *bytes, uint32_t byte_count ) {
	while(flash_is_busy());
	flash_enable_write();
	while(byte_count--) {
		// select slave 1, clkdiv=1
		SPI_CTRL = SPI_CTRL_MASK_CS1;
		// Command
		SPI_RXTX = FLASH_CMD_BYTE_PRG;
		// 24 bit Address
		SPI_RXTX = (addr>>16) & 0xFF;
		SPI_RXTX = (addr>>8) & 0xFF;
		SPI_RXTX = addr & 0xFF;
		SPI_RXTX = *bytes++;
		SPI_RXTX;
		SPI_CTRL = 0;
		while(flash_is_busy());
	}
}

void flash_write_words( uint32_t addr, uint16_t *words, uint32_t word_count ) {
	while(flash_is_busy());
	flash_enable_write();
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_AAI_PRG;
	// 24 bit Address
	SPI_RXTX = (addr>>16) & 0xFF;
	SPI_RXTX = (addr>>8) & 0xFF;
	SPI_RXTX = addr & 0xFF;
	uint8_t *ch =(uint8_t*)words;
	// first word
	word_count--;
	SPI_RXTX = *ch++;
	SPI_RXTX = *ch++;
	SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
	while(flash_is_busy());
	while( word_count-- ) {
		SPI_CTRL = SPI_CTRL_MASK_CS1;
		SPI_RXTX = FLASH_CMD_AAI_PRG;
		SPI_RXTX = *ch++;
		SPI_RXTX = *ch++;
		SPI_RXTX;
		SPI_CTRL = 0; // Deselect flash
		while(flash_is_busy());
	}
	flash_disable_write();
}

uint8_t flash_read_status(void) {
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_RDSR;
	SPI_RXTX = 0; // clk erzeugen
	uint8_t status = SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
	return status;
}

void flash_erase_sector( uint32_t addr ) {
	while(flash_is_busy());
	flash_enable_write();
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	// Command
	SPI_RXTX = FLASH_CMD_4K_ERASE;
	SPI_RXTX = ( addr >> 16 ) & 0xFF;
	SPI_RXTX = ( addr >> 8 ) & 0xFF;
	SPI_RXTX = addr & 0xFF;
	SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash
}

void flash_remove_bpl(void) {
	while(flash_is_busy());
	flash_enable_write();
	// select slave 1, clkdiv=1
	SPI_CTRL = SPI_CTRL_MASK_CS1;
	SPI_RXTX = FLASH_CMD_EWSR; // enable write to status register
	SPI_RXTX;
	SPI_CTRL = 0; // Deselect flash

	SPI_CTRL = SPI_CTRL_MASK_CS1;
	SPI_RXTX = FLASH_CMD_WRSR;
	SPI_RXTX = 0; // disable BPL bits
	SPI_CTRL = 0; // Deselect flash
}

int main(void) {
	uart_puts("Flash test\n");
	
	uart_puts("ReadID: 0x");
	uart_write_hex( flash_read_id(), 4 );
	
	uart_puts("\nJedecID: 0x");
	uart_write_hex( flash_read_jedec(), 6 );
	
	uart_puts("\nStatus: ");
	uart_write_hex( flash_read_status(), 2 );
	uart_puts("\n");
	
	flash_remove_bpl();
	
	uart_puts("\nStatus: ");
	uart_write_hex( flash_read_status(), 2 );
	uart_puts("\n");
	
	char buf[16];
	flash_read( 0, buf, sizeof(buf) );
	int i;
	for( i=0;i<sizeof(buf); i++) {
		uart_write_hex( buf[i], 2 );
		uart_putc(' ');
	}
	uart_puts("\n");
	flash_erase_sector(1000);
	while(flash_is_busy());
	
	
	flash_read( 1000, buf, 6 );
	uart_puts("Gelesen: ");
	for( i=0;i<sizeof(buf); i++) {
		uart_write_hex( buf[i], 2 );
		uart_putc(' ');
	}
	uart_puts("\n");


	flash_disable_write();
	return 0;
}

