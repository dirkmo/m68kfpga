#include "m68kdefs.h"

int main(void) {
	uint8_t i;
	i = 1;
	while(1) {
		i = (i << 1);
		if( i == 0 ) {
			i = 1;
		}
		LEDS = i;
	}
}

