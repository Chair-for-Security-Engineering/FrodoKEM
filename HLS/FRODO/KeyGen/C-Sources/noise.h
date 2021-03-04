#include "fips202.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "ap_cint.h"

void gen_S_sample_write(uint16_t *S, uint16_t *seed, uint16_t outlen,
    uint8_t reset, uint16_t *sk, uint8_t begin_write);
uint16_t frodo_sample(uint16_t in);