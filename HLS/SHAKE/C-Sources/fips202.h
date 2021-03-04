#ifndef FIPS202_H
#define FIPS202_H

#include <stdint.h>


#define SHAKE128_RATE 168
#define SHAKE256_RATE 136

#define SET_RANGE(a, b, c, d) apint_set_range(a, b, c, d)
#define GET_RANGE(a, b, c) apint_get_range(a, b, c)

void shake128(uint16_t output[21000], uint16_t outlen, const uint16_t input[10000],  uint16_t inlen);
void shake(uint16_t output[21000], uint16_t outlen, uint16_t input[10000], uint16_t inlen);
#endif
