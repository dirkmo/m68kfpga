		.text

		.org 0
		.global _start
		.long 0x2000
		.long _start

_start:
			moveal #msg, %a0
			
loop:		move.b (%a0)+, %d0
			
			beq.s ende
			
			move.b %d0, UART_RXTX
			
			bra.s loop
			
			
ende:
			move.w #0xA9A9, 0

		.data

msg:		.asciz "Hallo"

		.equ UART_RXTX, 0x100000
