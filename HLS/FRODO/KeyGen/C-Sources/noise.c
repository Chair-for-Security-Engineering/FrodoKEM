/********************************************************************************************
* FrodoKEM: Learning with Errors Key Encapsulation
*
* Abstract: noise sampling functions
*********************************************************************************************/

#include "noise.h"
#include "fips202.h"
#include "ap_cint.h"
//#include "frodo_keygen.h"

/*
    Generates one row of S (or E later on) and samples according to a discrete 
    Gaussian distribution, then writes the sampled values into S
*/
void gen_S_sample_write(uint16_t *S, uint16_t *seed, uint16_t outlen,
    uint8_t reset, uint16_t *sk, uint8_t begin_write)
{
    #pragma HLS INLINE off
    shake_gen_S(S, seed, outlen, reset);
    write_sk_16(sk, S, begin_write);
}

/*
    Samples one element using a discrete Gaussian sampler
    Input  : uint16_t in        : 16 pseudorandom bits as input to the sampler
    Return : uint16_t sample    : sampled value
*/
uint16_t frodo_sample(uint16_t in) 
{
    uint1 sign = in & 0x1;
    uint15 prnd = in >> 1;
    uint16_t sample = 0;

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

    if(sign == 1)
        sample = -sample;
    
    return sample;
}