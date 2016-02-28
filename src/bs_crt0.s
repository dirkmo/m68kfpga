	.org 0
	.global _start
	.text
	.long 0x100000
	.long _start

.extern __bss_start
.extern __bss_end

	_start:
	
				movel %a7, %fp
				moveal #0, %a5
				moveal #0, %a4
				moveal #0, %a3
				moveal #0, %a2
				moveal #0, %a1
				moveal #0, %a0

				movel #0, %d7
				movel #0, %d6
				movel #0, %d5
				movel #0, %d4
				movel #0, %d3
				movel #0, %d2
				movel #0, %d1
				movel #0, %d0
				
				#clear bss
				moveal	#__bss_start, %a0
				moveal	#__bss_end, %a1
			1:
				move.l	#0, (%a0)+
				cmpal	%a0, %a1
				bne	1b

	
				jsr main
				
			    move.b #'H', 0x100000
				move.b #'a', 0x100000
				move.b #'l', 0x100000
				move.b #'t', 0x100000
				move.b #'.', 0x100000
				
	loop:		jmp loop
