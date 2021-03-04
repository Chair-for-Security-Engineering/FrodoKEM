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


//Pack in into out. Both have to be 16 bit arrays
void frodo_pack_16(uint16_t *out, uint16_t *in, uint16_t inlen, uint8_t begin)
{
    uint16_t temp, k = 14, i = 0, j, index;

    if(begin)
    {
        W1: while(inlen > 0)
        {
            #pragma HLS LOOP_TRIPCOUNT min=4 max=40
            k = 14;
            L1: for(j = 0; j < 15; j++)
            {
                #pragma HLS LOOP_FLATTEN off
                #pragma HLS PIPELINE
                index = 15*i+j;
                temp = (GET_RANGE(in[16*i+j], k, 0) << (15-k)) | (GET_RANGE(in[16*i+j+1], 14, k));
                out[index] = temp;
                k--;
            }
            inlen -= 16;
            i++;
        }
    }
}

//Unpacks exactly 8 elements from in
void frodo_unpack_8(uint16_t *out, uint16_t *in, uint16_t rest_len)
{
    uint16_t j = (16-rest_len), k;
    static uint16_t rest;
    uint32_t temp = ((uint32_t) rest << 16);

    L1: for(k = 0; k < 8; k++)
    {
        #pragma HLS PIPELINE
        if((rest_len == 16) || ((rest_len == 8) && (k < 7)))
            temp |= (uint32_t) in[k] << (16-j);
        out[k] = GET_RANGE(temp, 31, 17);
        temp <<= 15;
        rest = GET_RANGE(temp, 31, 16);
        j++;
    }
}