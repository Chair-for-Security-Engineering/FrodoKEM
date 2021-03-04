/********************************************************************************************
* FrodoKEM: Learning with Errors Key Encapsulation
*
* Abstract: noise sampling functions
*********************************************************************************************/

#include "noise.h"
#include "fips202.h"
#include "ap_cint.h"

/*
    Discrete Gaussian sampler. Instead of implementing the CDF-table in an array and 
    going loopting over it, a large amount of comparators is used to instantly 
    compute the output
    Input : uint16_t in : pseudorandom value
    Returns : uint16_t sample : sampled value
*/

uint16_t frodo_sample(uint16_t in) 
{
    unsigned int i;

    uint1 sign = in & 0x1;
    uint15 prnd = in >> 1;
    uint16_t sample = 0;

    //Calculate sample based on direct comparison with values in CDF-table
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

    //Negate sample if sign is 1
    if(sign == 1)
        sample = -sample;
    
    return sample;
}