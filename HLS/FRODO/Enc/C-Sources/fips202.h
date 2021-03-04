#ifndef FIPS202_H
#define FIPS202_H

#include <stdint.h>
#include "ap_cint.h"


#define SHAKE128_RATE 168
#define SHAKE256_RATE 136

void shake128_10240(uint16_t *output, uint16_t *input);
void absorb_block(uint16_t *output, uint16_t *input, uint16_t outlen, 
    uint16_t inlen, uint8_t reset, uint8_t begin);
void shake_gen_S_E(uint16_t *S, uint16_t *E, uint16_t outlen, uint16_t *input,
    uint16_t low1, uint16_t high1, uint16_t low2, uint16_t high2, uint8_t begin);

#endif