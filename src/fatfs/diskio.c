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
/* Definitions of physical drive number for each drive */
#define FLASH	0
#define MMC		1



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
		//result = MMC_disk_status();
		return STA_NOINIT;

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
	int result;

	switch (pdrv) {
	case FLASH :
		flash_remove_bpl();

		return 0;

	case MMC :
		//result = MMC_disk_initialize();

		// translate the reslut code here

		return STA_NOINIT;

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
        flash_read( sector * 0x1000, buff, count * 0x1000 );

		return RES_OK;

	case MMC :
		//result = MMC_disk_read(buff, sector, count);

		return RES_ERROR;

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
        flash_write_bytes(buff, count * 0x1000, sector * 0x1000 );
		return 0;

	case MMC :
		// translate the arguments here

		//result = MMC_disk_write(buff, sector, count);

		// translate the reslut code here

		return RES_ERROR;

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
                *(DWORD*)buff = 0x400;
                res = RES_OK;
                break;
            case GET_SECTOR_SIZE:
                *(DWORD*)buff = 0x1000;
                res = RES_OK;
                break;
            case GET_BLOCK_SIZE:
                *(DWORD*)buff = 0x10;
                res = RES_OK;
                break;
            case CTRL_TRIM:
				{
					DWORD *dp = (DWORD*)buff;
					DWORD sec = dp[0];
					DWORD last = dp[1];
					while( sec <= last ) {
						flash_erase_sector( sec++ );
					}
				}
                break;
            default: ;
        }
    }


	return res;
}
