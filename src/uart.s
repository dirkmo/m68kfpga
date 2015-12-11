	.org 0
	.text
	.long 0x2000
	.long _start
	
	.global _start
	_start:
			moveb #65, 0x100000
			
	loop: jmp loop

	