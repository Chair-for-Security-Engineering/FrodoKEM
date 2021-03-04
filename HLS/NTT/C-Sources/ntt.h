#ifndef NTT_H
#define NTT_H

#include "inttypes.h"

#define NEWHOPE_N 1024
#define NEWHOPE_Q 12289 

extern uint16_t omegas_inv_bitrev_montgomery[];
extern uint16_t gammas_bitrev_montgomery[];
extern uint16_t gammas_inv_montgomery[];

typedef struct{
	uint16_t coeffs[NEWHOPE_N];
} poly __attribute__ ((aligned (32)));

void ntt(poly *a, const poly *omega);
uint32_t mul(uint32_t a, uint32_t b);

#endif
