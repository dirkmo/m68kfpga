/* Bootstrap program linker script */

ENTRY(_start)

MEMORY
{
	ram (rwx) : ORIGIN = 0x4000, LENGTH = 0x100000-0x4000
}

SECTIONS
{
	. = 0x4000;
	.text : {
		*(.text .text.*)
		. = ALIGN(0x4);
		*(.rodata .rodata.*)
		. = ALIGN(0x4);
		_etext = .;
		*(.lit)
	} > ram

  .data :
  {
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.*)
    _edata = .;
  } > ram

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
