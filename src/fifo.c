#include "fifo.h"
#include "m68kdefs.h"

void fifo_init(FIFO *fifo, uint8_t len, char *buf, uint8_t item_size) {
	fifo->first = 0;
	fifo->count = 0;
	fifo->len = len;
	fifo->buf = buf;
}

// Nachricht in FIFO schieben
bool fifo_push(FIFO *fifo, const char item) {
	IRQ_DISABLE();

	bool res = false;

	if(fifo->count < fifo->len) {
		
		res = true;

		uint8_t idx = (fifo->first + fifo->count) % fifo->len;
		fifo->buf[idx] = item;

		++fifo->count;
	}

	IRQ_ENALBE();

	return res;
}

// Erste Nachricht aus FIFO entnehmen
bool fifo_pop(FIFO *fifo, char *item) {
	IRQ_DISABLE();

	bool res = false;
	if(fifo->count > 0) {

		res = true;

		*item = fifo->buf[fifo->first];

		--fifo->count;

		fifo->first = (fifo->first + 1) % fifo->len;
	}

	IRQ_ENALBE();

	return res;
}

bool fifo_is_empty(const FIFO *fifo) {
	bool empty;
	IRQ_DISABLE();

	empty = fifo->count == 0;

	IRQ_ENALBE();
	return empty;
}

bool fifo_is_full(const FIFO *fifo) {
	bool full;
	IRQ_DISABLE();


	full = fifo->count == fifo->len;

	IRQ_ENALBE();
	return full;
}
