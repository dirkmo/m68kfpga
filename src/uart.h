#ifndef __UART_H
#define __UART_H

#include "m68kdefs.h"

#define CR 0x0D
#define LF 0x0A

uint8_t uart_getc(void);
uint8_t uart_putc(uint8_t c);

void uart_echo_on(void);
void uart_echo_off(void);

void uint2hex(uint32_t val, unsigned char *str, uint8_t hexchars);
uint32_t hex2uint(const char *s, uint8_t len);

void uart_readln(uint8_t *buf, uint8_t maxlen);
void uart_puts(uint8_t *str);

uint8_t uart_read_hex(uint32_t *val);
void uart_write_hex(uint32_t num, uint8_t chars);

#endif