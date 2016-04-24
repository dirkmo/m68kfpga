#ifndef __FIFO_H
#define __FIFO_H

#include <stdint.h>
#include <stdbool.h>

typedef struct {
  uint8_t first; // erstes Item
  uint8_t count; // aktuelle Anzahl in FIFO
  uint8_t len; // max. Anzahl in FIFO

  char *buf; // Buffer
} FIFO;


void fifo_init(FIFO *fifo, uint8_t len, char *buf, uint8_t item_size);

// fifo_push
// returns: true when item pushed into fifo
//          false when not pushed because fifo is full
bool fifo_push(FIFO *fifo, const char item);

// fifo_pop
// returns: true when an item was popped out of the fifo
//          false when no item was popped out of the fifo because it was empty
bool fifo_pop(FIFO *fifo, char *item);

// fifo_is_empty:
// returns: true when fifo is empty, otherwise false
bool fifo_is_empty(const FIFO *fifo);

// fifo_is_full:
// returns: true when fifo is full
bool fifo_is_full(const FIFO *fifo);

#endif
