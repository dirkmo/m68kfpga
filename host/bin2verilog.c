#include <stdio.h>
#include <stdint.h>

int main(int argc, char **argv) {
    if( argc < 2 ) {
        printf("bin2verilog infile [outfile]\n");
        return 1;
    }
    FILE *datei = fopen( argv[1], "r" );
    if( datei == NULL ) {
        printf("Datei nicht gefunden.\n");
        return 2;
    }
    uint32_t pos = 0;
    unsigned char vals[2];
    while( !feof(datei) ) {
        fread( vals, sizeof( vals ), 1, datei );
        printf("24'h%06X: boot_read[15:0] = 16'h%02X%02X;\n", pos, vals[0], vals[1]);
        pos+=sizeof( vals );
    }
    return 0;
}
