#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "ap_cint.h"

#define min(x, y) (((x) < (y)) ? (x) : (y))

void frodo_pack_16(uint16_t *out, uint16_t *in, uint16_t inlen, uint8_t begin);
void frodo_unpack_8(uint16_t *out, uint16_t *in, uint16_t rest_len);
