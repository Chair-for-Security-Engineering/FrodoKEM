#include "fips202.h"
#include "noise.h"
#include "util.h"
#include "api.h"
#include "ap_cint.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define PARAMS_N 640
#define PARAMS_NBAR 8
#define BYTES_SEED_A 16
#define PARAMS_EXTRACTED_BITS 2
#define CRYPTO_SECRETKEYBYTES  19888
#define CRYPTO_PUBLICKEYBYTES   9616
#define CRYPTO_BYTES              16
#define CRYPTO_CIPHERTEXTBYTES  9720
#define PARAMS_LOGQ 15
#define BYTES_MU (2*PARAMS_NBAR*PARAMS_NBAR)/8
#define BYTES_PKHASH CRYPTO_BYTES
#define ROL(bitlength, input, offset) ((input << offset) ^ (input >> (bitlength - offset)))

void frodo_keygen(uint16_t pk[4812], uint16_t sk[9944], uint16_t randomness[24]);
void add_E(uint16_t *out, uint16_t *in1, uint16_t *in2, uint8_t begin);
void write_sk_16(uint16_t *sk, uint16_t *S, uint8_t begin);
void vector_matrix_mul(uint16_t *B, uint16_t *A_1, uint16_t *A_2, uint16_t *S, 
    uint16_t *seed_A, uint8_t offset, uint8_t pregen, uint8_t begin);
uint16_t vector_vector_mul(uint16_t *a, uint16_t *s);