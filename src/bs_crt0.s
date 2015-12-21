	.org 0
#	.global _main
	.global _start
	.text
	.long 0x2000
	.long _start

.extern __bss_start
.extern __bss_end

	_start:
	
				movel %a7, %fp
				
				#clear bss
				moveal	#__bss_start, %a0
				moveal	#__bss_end, %a1
			1:
				movel	#0, (%a0)
				leal	4(%a0), %a0
				cmpal	%a0, %a1
				bne	1b

	
				jsr main
			
	loop:		jmp loop
