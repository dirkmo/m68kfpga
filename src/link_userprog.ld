/* application linker script */

ENTRY(_start)

MEMORY
{
	ram (rwx) : ORIGIN = 0x4000, LENGTH = 0x100000-0x4000
}

SECTIONS
{
	.text : {
		*(.text)
	} > ram

	.data :
	{
		. = ALIGN(0x4);
		*(.rodata)
		. = ALIGN(0x4);
		*(.data)
	} > ram

	.bss :
	{
		. = ALIGN(0x4);
		__bss_start = . ;
		*(.bss)
		. = . + 4;
		__bss_end = ALIGN (0x4);
	} > ram
}
