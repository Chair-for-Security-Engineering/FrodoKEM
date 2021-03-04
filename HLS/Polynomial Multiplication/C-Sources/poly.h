#ifndef POLY_H
#define POLY_H

#include <stdint.h>
#include "ap_cint.h"

#define NTRU_N 509
#define NTRU_LOGQ 11
#define NTRU_Q (1 << NTRU_LOGQ)

typedef struct{
	uint11 coeffs[NTRU_N];
} poly;

uint11 r[NTRU_N], b[NTRU_N];
void poly_mul_test(poly *R, poly *a, poly *B);
void poly_mul(poly *a);

#endif
