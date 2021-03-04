#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "ap_cint.h"

#define min(x, y) (((x) < (y)) ? (x) : (y))

void frodo_unpack(uint16_t *out, uint16_t *in, uint16_t outlen);
void frodo_unpack_8(uint16_t *out, uint16_t *in, uint16_t rest_len);