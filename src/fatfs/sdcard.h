#ifndef __SDCARD_H
#define __SDCARD_H

#include "ff.h"

DSTATUS sdcard_disk_status( BYTE pdrv );
DSTATUS sdcard_disk_initialize( BYTE pdrv );
DRESULT sdcard_disk_read( BYTE pdrv, BYTE *buff, DWORD sector, UINT count );
DRESULT sdcard_disk_write( BYTE pdrv, const BYTE *buff, DWORD sector, UINT count );
DRESULT sdcard_disk_ioctl( BYTE pdrv, BYTE cmd, void *buff );

#endif
