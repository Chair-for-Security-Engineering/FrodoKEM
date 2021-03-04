#include "sample.h"
#include "ap_cint.h"

/********************************************************************************************
* FrodoKEM: Learning with Errors Key Encapsulation
*
* Abstract: noise sampling functions
*********************************************************************************************/
uint16_t CDF_TABLE[13] = {4643, 13363, 20579, 25843, 29227, 31145, 32103, 32525, 32689, 32745, 32762, 32766, 32767};
uint16_t CDF_TABLE_LEN = 13;

/*
    Discrete Gaussian sampler, samples n elements.
    Inputs:  uint13 n               : number of elements to be sampled
             uint16_t s[5120]       : pseudorandom input, maximum of 5120 elements
    Outputs: uint16_t out[5120]     : sampled values, maximum of 5120 elements
*/
void frodo_sample_n(uint16_t out[5120], uint16_t s[5120], uint13 n) 
{
    #pragma HLS INTERFACE ap_memory depth=5120 port=s
    #pragma HLS INTERFACE ap_memory depth=5120 port=out
    
    unsigned int i;

    //Loop over the n inputs
    L1: for (i = 0; i < n; ++i)
    {
        #pragma HLS PIPELINE
        uint16_t sample = 0;
        uint15 prnd = s[i] >> 1;        //15 msb of the input element
        uint1 sign = s[i] & 0x1;        //lsb of the input element

        //Calculate sample based on comparison with the entries from the CDF-table
        if(prnd > 32525)
        {
            if(prnd > 32762)
            {
                if(prnd > 32766)
                    sample = 12;
                else
                    sample = 11;
            }
            else if(prnd > 32689)
            {
                if(prnd > 32745)
                    sample = 10;
                else
                    sample = 9;
            }
            else
                sample = 8;
        }
        else if(prnd > 25843)
        {
            if(prnd > 31145)
            {
                if(prnd > 32103)
                    sample = 7;
                else
                    sample = 6;
            }
            else
            {
                if(prnd > 29227)
                    sample = 5;
                else 
                    sample = 4;
            }
        }
        else
        {
            if(prnd > 13363)
            {
                if(prnd > 20579)
                    sample = 3;
                else
                    sample = 2;
            }
            else
            {
                if(prnd > 4643)
                    sample = 1;
                else
                    sample = 0;
            }
        }

        //Negate sample if sign is 1, and write sample to the output
        if(sign == 1)
            sample = -sample;
        
        out[i] = sample;
    }
}
