/********************************************************************************************
* FrodoKEM: Learning with Errors Key Encapsulation
*
* Abstract: additional functions for FrodoKEM
*********************************************************************************************/

#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include "api.h"
#include "util.h"
#include "ap_cint.h"

/*
    Performs the packing of exactly 640 input values into 600 output values. Packed
    values are written into the public key, secret key, and a local array for the hashing
    Inputs  : uint16_t *in      : input vector with 640 elements to be packed
              uint16_t inlen    : input length
              uint8_t begin     : decides if function is executed
    Outputs : uint16_t *pk      : public key
              uint16_t *sk      : secret key
              uint16_t *out     : local array for hashing
*/
void frodo_pack_16(uint16_t *pk, uint16_t *sk, uint16_t *out, uint16_t *in, 
    uint16_t inlen, uint8_t begin)
{
    uint16_t temp, k = 14, i = 0, j, index;

    if(begin)
    {
        for(i = 0; i < 40; i++)
        {
            #pragma HLS LOOP_TRIPCOUNT min=4 max=40
            k = 14;
            L1: for(j = 0; j < 15; j++)
            {
                #pragma HLS LOOP_FLATTEN off
                #pragma HLS PIPELINE
                index = 15*i+j;
                temp = (GET_RANGE(in[16*i+j], k, 0) << (15-k)) | (GET_RANGE(in[16*i+j+1], 14, k));
                pk[index] = temp;
                sk[index] = temp;
                out[index] = temp;
                k--;
            }            
            inlen -= 16;
        }
    }
}