	.text
	.global _start

	_start:
			    move.b #'H', 0x100000
				move.b #'a', 0x100000
				move.b #'l', 0x100000
				move.b #'l', 0x100000
				move.b #'o', 0x100000

				rts
