// https://en.wikipedia.org/wiki/Middle-square_method

// #include <stdint.h>
#include <stdlib.h>

// uint64_t x = 0, w = 0, s = 0xb5ad4eceda1ce2a9;

uint32_t msws() {
    // x *= x;
    // x += (w += s);
    // return x = (x >> 32) | (x << 32);
    return rand() % 2;
}
