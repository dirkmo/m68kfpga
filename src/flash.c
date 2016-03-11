#include "m68kdefs.h"
#include "flash.h"

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

#define FLASH_SELECT 		SPI_CTRL = SPI_CTRL_MASK_CS1
#define FLASH_DESELECT		SPI_CTRL = 0
#define FLASH_SEND(byte)	SPI_RXTX = byte
#define FLASH_RECEIVE()		SPI_RXTX

#define LED_ON	LEDS |= 0x01
#define LED_OFF	LEDS &= 0xFE

bool flash_is_busy(void) {
	// select slave 1, clkdiv=1
	FLASH_SELECT;
	// Command
	FLASH_SEND( FLASH_CMD_RDSR );
	FLASH_SEND( 0 ); // clk erzeugen
	uint8_t status = FLASH_RECEIVE();
	FLASH_DESELECT; // Deselect flash
	return status & 0x01;
}

uint16_t flash_read_id(void) {
	while(flash_is_busy());
	// select slave 1, clkdiv=1
	FLASH_SELECT;
	// Command
	FLASH_SEND( FLASH_CMD_RDID );
	// 24 bit Address
	FLASH_SEND( 0 );
	FLASH_SEND( 0 );
	FLASH_SEND( 0 );
	// read id
	FLASH_SEND( 0 );
	uint16_t readid = FLASH_RECEIVE() << 8;
	FLASH_SEND( 0 );
	readid |= FLASH_RECEIVE();
	FLASH_DESELECT; // Deselect flash
	return readid;
}

uint32_t flash_read_jedec(void) {
	while(flash_is_busy());
	FLASH_SELECT;
	// Jedec ID
	FLASH_SEND( FLASH_CMD_JEDECID );
	FLASH_SEND( 0 );
	uint32_t jedecid = FLASH_RECEIVE() << 16;
	FLASH_SEND( 0 );
	jedecid |= FLASH_RECEIVE() << 8;
	FLASH_SEND( 0 );
	jedecid |= FLASH_RECEIVE();
	FLASH_DESELECT; // Deselect flash
	return jedecid;
}

void flash_enable_write(void) {
	while(flash_is_busy());
	FLASH_SELECT;
	FLASH_SEND( FLASH_CMD_WREN );
	FLASH_DESELECT; // Deselect flash
}

void flash_read( uint32_t addr, char *dst, uint32_t len ) {
	while(flash_is_busy());
	LED_ON;
	FLASH_SELECT;
	// Command
	FLASH_SEND( FLASH_CMD_READ );
	// 24 bit Address
	FLASH_SEND( (addr>>16) & 0xFF );
	FLASH_SEND( (addr>>8) & 0xFF );
	FLASH_SEND( addr & 0xFF );
	while( len-- ) {
		FLASH_SEND( 0 ); // clk erzeugen
		*dst++ = FLASH_RECEIVE();
	}
	FLASH_DESELECT; // Deselect flash
	LED_OFF;
}

void flash_disable_write(void) {
	while(flash_is_busy());
	flash_enable_write();
	// select slave 1, clkdiv=1
	FLASH_SELECT;
	// Command
	FLASH_SEND( FLASH_CMD_WRDI );
	FLASH_DESELECT; // Deselect flash
}

void flash_write_bytes( const uint8_t *bytes, uint32_t byte_count, uint32_t addr ) {
	while(flash_is_busy());
	LED_ON;
	while(byte_count--) {
		flash_enable_write();
		// select slave 1, clkdiv=1
		FLASH_SELECT;
		// Command
		FLASH_SEND( FLASH_CMD_BYTE_PRG );
		// 24 bit Address
		FLASH_SEND( (addr>>16) & 0xFF );
		FLASH_SEND( (addr>>8) & 0xFF );
		FLASH_SEND( addr & 0xFF );
		FLASH_SEND( *bytes++ );
		FLASH_DESELECT;
		addr++;
		while(flash_is_busy());
	}
	flash_disable_write();
	LED_OFF;
}

void flash_write_words( const uint16_t *words, uint32_t word_count, uint32_t addr ) {
	while(flash_is_busy());
	LED_ON;
	flash_enable_write();
	// select slave 1, clkdiv=1
	FLASH_SELECT;
	// Command
	FLASH_SEND( FLASH_CMD_AAI_PRG );
	// 24 bit Address
	FLASH_SEND( (addr>>16) & 0xFF );
	FLASH_SEND( (addr>>8) & 0xFF );
	FLASH_SEND( addr & 0xFF );
	uint8_t *ch =(uint8_t*)words;
	// first word
	word_count--;
	FLASH_SEND( *ch++ );
	FLASH_SEND( *ch++ );
	FLASH_DESELECT; // Deselect flash
	while(flash_is_busy());
	while( word_count-- ) {
		FLASH_SELECT;
		FLASH_SEND( FLASH_CMD_AAI_PRG );
		FLASH_SEND( *ch++ );
		FLASH_SEND( *ch++ );
		FLASH_DESELECT; // Deselect flash
		while(flash_is_busy());
	}
	flash_disable_write();
	LED_OFF;
}

uint8_t flash_read_status(void) {
	// select slave 1, clkdiv=1
	FLASH_SELECT;
	// Command
	FLASH_SEND( FLASH_CMD_RDSR );
	FLASH_SEND( 0 ); // clk erzeugen
	uint8_t status = FLASH_RECEIVE();
	FLASH_DESELECT; // Deselect flash
	return status;
}

void flash_erase_sector( uint32_t addr ) {
	while(flash_is_busy());
	LED_ON;
	flash_enable_write();
	FLASH_SELECT;
	FLASH_SEND( FLASH_CMD_4K_ERASE );
	FLASH_SEND( ( addr >> 16 ) & 0xFF );
	FLASH_SEND( ( addr >> 8 ) & 0xFF );
	FLASH_SEND( addr & 0xFF );
	FLASH_DESELECT; // Deselect flash
	LED_OFF;
}

void flash_erase_32k_block( uint32_t addr ) {
	while(flash_is_busy());
	LED_ON;
	flash_enable_write();
	FLASH_SELECT;
	FLASH_SEND( FLASH_CMD_32K_ERASE );
	FLASH_SEND( ( addr >> 16 ) & 0xFF );
	FLASH_SEND( ( addr >> 8 ) & 0xFF );
	FLASH_SEND( addr & 0xFF );
	FLASH_DESELECT; // Deselect flash
	LED_OFF;
}

void flash_erase_64k_block( uint32_t addr ) {
	while(flash_is_busy());
	LED_ON;
	flash_enable_write();
	FLASH_SELECT;
	FLASH_SEND( FLASH_CMD_64K_ERASE );
	FLASH_SEND( ( addr >> 16 ) & 0xFF );
	FLASH_SEND( ( addr >> 8 ) & 0xFF );
	FLASH_SEND( addr & 0xFF );
	FLASH_DESELECT; // Deselect flash
	LED_OFF;
}

void flash_remove_bpl(void) {
	while(flash_is_busy());
	flash_enable_write();
	FLASH_SELECT;
	FLASH_SEND( FLASH_CMD_EWSR ); // enable write to status register
	FLASH_DESELECT;
	FLASH_SELECT;
	FLASH_SEND( FLASH_CMD_WRSR );
	FLASH_SEND( 0 ); // reset BPL bits
	FLASH_DESELECT;
}

