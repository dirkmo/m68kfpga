#include "fatfs/ff.h"
#include "uart.h"
#include <stdio.h>

static FATFS fs; /* File system object (volume work area) */
static FIL fil;  /* File object */

void create_fs(void) {
    /* Register work area (do not care about error) */
    f_mount(&fs, "1:", 0);
	/* Create FAT volume with default cluster size */
    FRESULT res = f_mkfs("1:", 1/*sfd*/, 0);
	uart_printf("mkfs result = %d\r\n", res );
}

void mount(void) {
	FRESULT res = f_mount(&fs, "1:", 1);
	uart_printf("mount result = %d\r\n", res);
}

void create_file(void) {
    FRESULT res = f_open(&fil, "1:/hello.txt", FA_CREATE_NEW | FA_WRITE);
	UINT bw;
    uart_printf("create result = %d\r\n", res);

    /* Write a message */
    res = f_write(&fil, "Hello, World!\r\n", 15, &bw);
	uart_printf("write result = %d\r\n", res);
	
	f_close(&fil);
}

void open_file(void) {
	char line[82];
    FRESULT res = f_open(&fil, "1:/hello.txt", FA_READ);
	uart_printf("open result = %d\r\n", res);
    /* Read all lines and display it */
    while (f_gets(line, sizeof line, &fil))
        uart_printf(line);

    /* Close the file */
    f_close(&fil);
}

void menu(void) {
	uart_printf("Menu:\r\n");
	uart_printf("(f)mkfs  (m)ount fs  (d)ir (c)reate file (o)pen file\r\n");
	while(1) {
		char ch = uart_getc();
		if( ch == 'f' ) {
			create_fs();
		} else
		if( ch == 'm' ) {
			mount();
		} else
		if( ch == 'd' ) {
		} else
		if( ch == 'c' ) {
			create_file();
		} else
		if( ch == 'o' ) {
			open_file();
		} else
		if( ch == 27 ) {
			break;
		}
	}
	f_mount( 0, "", 0 );
}

void main(void) {
    uart_printf("FatFS test\n");
	menu();
}
