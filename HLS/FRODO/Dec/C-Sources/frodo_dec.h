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

void frodo_dec(uint16_t ss[8], uint16_t ct[4860], uint16_t sk[9944]);
uint8_t compare(uint16_t *in_1, uint16_t *in_2, uint16_t n, uint8_t begin);
void read_input(uint16_t *out, uint16_t *in, uint16_t n, uint8_t begin);
void vector_matrix_mul(uint16_t *output_vec, uint16_t *S, uint16_t *A_1, 
    uint16_t *A_2, uint16_t *E, uint16_t *sk, uint16_t *seed_A_separated, 
    uint16_t *pk, uint8_t pregen, uint16_t n, uint8_t use_A, uint8_t begin);
void read_S(uint16_t *out, uint16_t *in, uint16_t offset);
void scalar_vector_mul(uint16_t *output_vec, uint16_t *input_vec, 
    uint16_t scalar, uint16_t n, uint16_t index, uint16_t *E);
uint16_t reg(uint16_t in);
void reset_vector(uint16_t *in, uint16_t n, uint8_t begin);
void encode(uint16_t *out, uint16_t *in, uint16_t mu, uint8_t begin);