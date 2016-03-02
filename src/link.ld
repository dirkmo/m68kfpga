/* Bootstrap program linker script */

ENTRY(_start)

MEMORY
{
	rom (rx) : ORIGIN = 0x0, LENGTH = 0x1A00
	ram (rwx) : ORIGIN = 0x1A00, LENGTH = 0x100000 - 0x1A00
}

SECTIONS
{
	. = 0x0;
	.text : {
		*(.text .text.*)
		. = ALIGN(0x4);
		*(.rodata .rodata.*)
		. = ALIGN(0x4);
		_etext = .;
		*(.lit)
	} > rom

  .data :
  {
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.*)
    _edata = .;
  } > rom

  .bss :
  {
    . = ALIGN(0x4);
    __bss_start = . ;
    *(.shbss)
    *(.bss .bss.*)
    *(COMMON)
    . = . + 4;
    __bss_end = ALIGN (0x8);
  } > ram

}
