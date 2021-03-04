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
    Unpacks *in into *out.
    Inputs :  uint16_t *in      : input vector
              uint16_t outlen   : number of elements to unpack
    Outputs : uint16_t *out     : output vector
*/
void frodo_unpack(uint16_t *out, uint16_t *in, uint16_t outlen)
{
    uint32_t temp = 0;
    uint16_t j = 0, in_index = 0, out_index = 0, k;

    W1: while(outlen > 0)
    {
        #pragma HLS PIPELINE
        //Take an input element and write it into temp. First element goes all the way
        //to the left, second one position to the right, and so on
        if(j < 15)
        {
            temp |= (uint32_t) in[in_index] << (16-j);
            in_index++;
        }
        //Take leftmost 15 bits of temp as output, shift temp 15 positions to the left
        //After 15 iterations, no new input is taken, but 15 bits remain from the old
        //inputs
        out[out_index] = GET_RANGE(temp, 31, 17);
        temp <<= 15;
        j++;
        outlen--;
        out_index++;
        //Once 16 outputs have been written, the whole operation starts again with j reset
        if(j == 16)
        {
            temp = 0;
            j = 0;
        }
    }
}

/*
    Unpacks exactly 8 elements from *in. 
    Inputs :  uint16_t *in          : input vector
              uint16_t rest_len     : defines how many bits of previous inputs are 
                remaining in temp (is either 16 (0 bits remain) or 8 (8 bits remain))
    Outputs : uint16_t *out          : output vector
*/
void frodo_unpack_8(uint16_t *out, uint16_t *in, uint16_t rest_len)
{
    uint16_t j = (16-rest_len), k;
    static uint16_t rest;
    uint32_t temp = ((uint32_t) rest << 16);

    L1: for(k = 0; k < 8; k++)
    {
        #pragma HLS PIPELINE
        //If no remaining bits are in temp, 8 new inputs can be taken
        //If 8 bits are remaining, only 7 new inputs can be taken, as 8+7 new bits 
        //are enough for an 8th output
        if((rest_len == 16) || ((rest_len == 8) && (k < 7)))
            temp |= (uint32_t) in[k] << (16-j);
        out[k] = GET_RANGE(temp, 31, 17);
        temp <<= 15;
        rest = GET_RANGE(temp, 31, 16);
        j++;
    }
}
