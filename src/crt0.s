.global _start
.text

.extern __bss_start
.extern __bss_end

_start:
		
			#clear bss
			moveal	#__bss_start, %a0
			moveal	#__bss_end, %a1
		1:
			move.l	#0, (%a0)+
			cmpal	%a0, %a1
			bne	1b


			jsr main

			rts
