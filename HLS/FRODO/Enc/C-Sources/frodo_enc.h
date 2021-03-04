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
#define CRYPTO_SECRETKEYBYTES  19888     // sizeof(s) + CRYPTO_PUBLICKEYBYTES + 2*PARAMS_N*PARAMS_NBAR + BYTES_PKHASH
#define CRYPTO_PUBLICKEYBYTES   9616     // sizeof(seed_A) + (PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8
#define CRYPTO_BYTES              16
#define CRYPTO_CIPHERTEXTBYTES  9720
#define PARAMS_LOGQ 15
#define PARAMS_Q (1 << PARAMS_LOGQ)
#define BYTES_MU (2*PARAMS_NBAR*PARAMS_NBAR)/8
#define BYTES_PKHASH CRYPTO_BYTES
#define ROL(bitlength, input, offset) ((input << offset) ^ (input >> (bitlength - offset)))

void frodo_enc(uint16_t ct[4860], uint16_t ss[8], uint16_t mu_in[8], uint16_t pk[4808]);
void scalar_vector_mul(uint16_t *output_vec, uint16_t *input_vec, 
    uint16_t scalar, uint16_t n, uint16_t index, uint16_t *E);
void reset(uint16_t *B, uint16_t n);
void vector_matrix_mul(uint16_t *output_vec, uint16_t *S, uint16_t *A_1, 
	uint16_t* A_2, uint16_t *E, uint16_t *seed_A_separated, uint16_t *pk, uint8_t pregen, 
	uint16_t n, uint8_t use_A, uint8_t begin);
void read_input(uint16_t *out, uint16_t *in, uint16_t len, uint8_t begin);
void write_reset_mod(uint16_t *out, uint16_t *in, uint16_t n, uint8_t begin);
void reset_vector(uint16_t *vec, uint16_t n, uint8_t begin);
void pack_reset(uint16_t *out, uint16_t *in, uint16_t inlen, uint8_t begin_pack, 
    uint16_t n, uint8_t begin_reset);
void absorb_block_write(uint16_t *output, uint16_t *input, uint16_t outlen,
    uint16_t inlen, uint8_t reset, uint8_t begin_absorb,
    uint16_t *ct, uint16_t write_len, uint8_t begin_write);
uint16_t reg(uint16_t in);
void encode_add(uint16_t *out, uint16_t *in, uint16_t mu, uint8_t begin);