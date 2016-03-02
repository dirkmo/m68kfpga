#include "uart.h"

void main(void) {
	uart_puts("Userprogramm 2\n");
	uart_puts("Hier kommt jetzt viel Text, um den Speicher zu füllen.\n");
	uart_puts("Denn wir wollen ja das vor im Speicher liegende Programm\n");
	uart_puts("überschreiben. Das klappt natürlich nur, wenn genügend\n");
	uart_puts("Text ausgegeben wird. Das sollte nun auch reichen :-)\n");
}
