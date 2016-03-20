#ifndef __M68KDEFS_H
#define __M68KDEFS_H

#include <stdint.h>

//-------------------------------------------------------
// UART

#define UART_RXTX (*((volatile uint8_t*)0x100003))
#define UART_STAT (*((volatile uint8_t*)0x100007))

#define UART_MASK_RXAVAIL		1
#define UART_MASK_TXACTIVE		2
#define UART_MASK_RXOVERFLOW	4

//-------------------------------------------------------
// Boot mode 

#define BOOTMODE  (*((volatile uint16_t*)0x0))
#define BOOTMODE_CMD_END 0xA9A9

#define BOOTMODE_END() {BOOTMODE=BOOTMODE_CMD_END;}

//-------------------------------------------------------
// LEDs

#define LEDS (*((volatile uint8_t*)0x100100))

//-------------------------------------------------------
// SPI

#define SPI_RXTX (*((volatile uint8_t*)0x100203))
#define SPI_CTRL (*((volatile uint8_t*)0x100207))

// CTRL: { spi_cs_reg[2:0], clk_div[2:0], active };
#define SPI_CTRL_MASK_BUSY 1

#define SPI_CTRL_MASK_CLKDIV2 (0<<1) // CLK = Sysclk/2
#define SPI_CTRL_MASK_CLKDIV4 (1<<1) // CLK = Sysclk/4
#define SPI_CTRL_MASK_CLKDIV8 (2<<1) // CLK = Sysclk/8

#define SPI_CTRL_MASK_CS1 (1<<4)
#define SPI_CTRL_MASK_CS2 (2<<4)
#define SPI_CTRL_MASK_CS3 (3<<4)

//-------------------------------------------------------
// Timer

#define TIMER_CNT  (*((volatile uint32_t*)0x100300))
#define TIMER_CMP  (*((volatile uint32_t*)0x100304))
#define TIMER_CTRL (*((volatile uint32_t*)0x100308))
//#define TIMER_CTRL (*((volatile uint8_t*) 0x10030B))
// wire [31:0] ctrl = { 8'd0, 8'd0, 8'd0, { 2'b00, clk_div[4:0], enable } };
#define TIMER_CTRL_MASK_ENABLE 0x0001
// timer_clk = clk / ( 2^(clk_div+1)

//-------------------------------------------------------
// Interrupt Controller
#define INT_CTRL    (*((volatile uint32_t*)0x100400))
#define INT_ENABLE  (*((volatile uint32_t*)0x100404))
#define INT_MASK    (*((volatile uint32_t*)0x100408))

#endif

