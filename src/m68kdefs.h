#ifndef __M68KDEFS_H
#define __M68KDEFS_H

#include <stdint.h>

#define UART_RXTX (*((volatile uint8_t*)0x100000))

#define UART_STAT (*((volatile uint8_t*)0x100001))

#define UART_MASK_RXAVAIL 1
#define UART_MASK_TXACTIVE 2

#define BOOTMODE  (*((volatile uint16_t*)0x0))
#define BOOTMODE_CMD_END 0xA9A9

#define BOOTMODE_END() {BOOTMODE=BOOTMODE_CMD_END;}

#define LEDS (*((volatile uint8_t*)0x100100))

#define SPI_RXTX (*((volatile uint8_t*)0x100200))
#define SPI_CTRL (*((volatile uint8_t*)0x100201))

#define SPI_CTRL_MASK_BUSY 1

#define SPI_CTRL_MASK_CS1 (1<<4)
#define SPI_CTRL_MASK_CS2 (2<<4)
#define SPI_CTRL_MASK_CS3 (3<<4)

#endif

