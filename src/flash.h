#ifndef __FLASH_H
#define __FLASH_H

#include <stdbool.h>
#include <stdint.h>

bool flash_is_busy(void);
uint16_t flash_read_id(void);
uint32_t flash_read_jedec(void);
void flash_enable_write(void);
void flash_disable_write(void);
uint8_t flash_read_status(void);
void flash_erase_sector( uint32_t addr );
void flash_remove_bpl(void);

void flash_read( uint32_t addr, char *dst, uint32_t len );
void flash_write_bytes( const uint8_t *bytes, uint32_t byte_count, uint32_t addr );
void flash_write_words( const uint16_t *words, uint32_t word_count, uint32_t addr );


#endif
