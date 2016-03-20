/*-----------------------------------------------------------------------*/
/* Low level disk I/O module skeleton for FatFs     (C)ChaN, 2014        */
/*-----------------------------------------------------------------------*/
/* If a working storage control module is available, it should be        */
/* attached to the FatFs via a glue function rather than modifying it.   */
/* This is an example of glue functions to attach various exsisting      */
/* storage control modules to the FatFs module with a defined API.       */
/*-----------------------------------------------------------------------*/

#include "diskio.h"		/* FatFs lower layer API */
#include "flash.h"
#include "sdcard.h"

/* Definitions of physical drive number for each drive */
#define FLASH	0
#define MMC		1

// Die ersten 16 Sektoren für Bootloader reservieren
#define SECTOR_OFFSET 0x10


/*-----------------------------------------------------------------------*/
/* Get Drive Status                                                      */
/*-----------------------------------------------------------------------*/

DSTATUS disk_status (
	BYTE pdrv		/* Physical drive number to identify the drive */
)
{
	DSTATUS stat;
    uint8_t flash_status;

	switch (pdrv) {
		case FLASH :
			flash_status = flash_read_status();
			if( flash_status & 0x3C) {
				return STA_NOINIT | STA_PROTECT;
			}
			return 0;

		case MMC :
		{
			stat = sdcard_disk_status(0 1);
			return stat;
		}
	}
	return STA_NOINIT;
}



/*-----------------------------------------------------------------------*/
/* Inidialize a Drive                                                    */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (
	BYTE pdrv				/* Physical drive nmuber to identify the drive */
)
{
	DSTATUS stat;

	switch (pdrv) {
		case FLASH :
			flash_remove_bpl();
			return 0;

		case MMC :
		{
			stat = sdcard_disk_initialize(0 1);
			uart_printf("disk init ret: %d\r\n", stat);
			return stat;
		}
	}
	return STA_NOINIT;
}



/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/

DRESULT disk_read (
	BYTE pdrv,		/* Physical drive nmuber to identify the drive */
	BYTE *buff,		/* Data buffer to store read data */
	DWORD sector,	/* Sector address in LBA */
	UINT count		/* Number of sectors to read */
)
{
	DRESULT res;
	int result;

	switch (pdrv) {
	case FLASH :
        flash_read( (SECTOR_OFFSET + sector) * 0x1000, buff, count * 0x1000 );
		return RES_OK;

	case MMC :
		uart_printf("disk_read\r\n");
		return sdcard_disk_read(0 1, buff, sector, count);
	}

	return RES_PARERR;
}



/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/

DRESULT disk_write (
	BYTE pdrv,			/* Physical drive nmuber to identify the drive */
	const BYTE *buff,	/* Data to be written */
	DWORD sector,		/* Sector address in LBA */
	UINT count			/* Number of sectors to write */
)
{
	DRESULT res;
	int result;

	switch (pdrv) {
	case FLASH :
		flash_erase_sector( (SECTOR_OFFSET + sector) * 0x1000 );
        flash_write_words((uint16_t*)buff, count * 0x1000 / 2, (SECTOR_OFFSET + sector) * 0x1000 );
		return 0;

	case MMC :
		uart_printf("disk_write\r\n");
		return sdcard_disk_write(0 1, buff, sector, count);
	}

	return RES_PARERR;
}


/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

DRESULT disk_ioctl (
	BYTE pdrv,		/* Physical drive nmuber (0..) */
	BYTE cmd,		/* Control code */
	void *buff		/* Buffer to send/receive control data */
)
{
	DRESULT res = RES_PARERR;

    if( pdrv == FLASH ) {
        switch( cmd ) {
            case CTRL_SYNC:
                res = RES_OK;
                break;
            case GET_SECTOR_COUNT:
                *(DWORD*)buff = 0x400 - SECTOR_OFFSET;
                res = RES_OK;
                break;
            case GET_SECTOR_SIZE:
                *(WORD*)buff = 0x1000;
                res = RES_OK;
                break;
            case GET_BLOCK_SIZE:
                *(DWORD*)buff = 0x10;
                res = RES_OK;
                break;
            case CTRL_TRIM:
				{
					DWORD *dp = (DWORD*)buff;
					DWORD sec = dp[0] + SECTOR_OFFSET;
					DWORD last = dp[1] + SECTOR_OFFSET;
					while( sec <= last ) {
						if( sec % 0x10 == 0 && (last-sec) >= 0x0F ) {
							// 16 Blöcke auf einmal
							flash_erase_64k_block(sec*0x1000 );
							sec += 0x10;
							continue;
						}
						if( sec % 0x08 == 0 && (last-sec) >= 0x07 ) {
							// 8 Blöcke auf einmal
							flash_erase_32k_block( sec*0x1000 );
							sec += 0x08;
							continue;
						}
						flash_erase_sector( (SECTOR_OFFSET + sec)*0x1000 );
						sec++;
					}
					res = RES_OK;
				}
                break;
            default: ;
        }
    } else
	if( pdrv == MMC ) {
		res = sdcard_disk_ioctl(0 1, cmd, buff);
		uart_printf("disk_ioctl ret: %d\r\n",res);
		return res;
	}


	return res;
}
