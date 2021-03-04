/********************************************************************************************
* SHA3-derived functions: SHAKE
*
* Based on the public domain implementation in crypto_hash/keccakc512/simple/ 
* from http://bench.cr.yp.to/supercop.html by Ronny Van Keer 
* and the public domain "TweetFips202" implementation from https://twitter.com/tweetfips202 
* by Gilles Van Assche, Daniel J. Bernstein, and Peter Schwabe
*
* See NIST Special Publication 800-185 for more information:
* http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-185.pdf
*
*********************************************************************************************/  

#include <stdint.h>
#include <assert.h>
#include <string.h>
#include "fips202.h"
#include "ap_cint.h"

#define NROUNDS 24
#define ROL(a, offset) ((a << offset) ^ (a >> (64-offset)))
#define ROL_16(a, offset) ((a << offset) ^ (a >> (16-offset)))

//Internal state
uint64_t s[25];

//Round Permutation
void KeccakF1600_StatePermute()
{
 	int round, i, j, x, y;
 	uint64_t B[25], D[5], RC;
    #pragma HLS ARRAY_PARTITION variable=B complete dim=1
    #pragma HLS ARRAY_PARTITION variable=D complete dim=1

    L1: for(round = 0; round < NROUNDS; round++)
    {
    	#pragma HLS PIPELINE

        //Round constants
    	switch(round)
        {
            case  0: RC = 0x0000000000000001ULL; break;
            case  1: RC = 0x0000000000008082ULL; break;
            case  2: RC = 0x800000000000808AULL; break;
            case  3: RC = 0x8000000080008000ULL; break;
            case  4: RC = 0x000000000000808BULL; break;
            case  5: RC = 0x0000000080000001ULL; break;
            case  6: RC = 0x8000000080008081ULL; break;
            case  7: RC = 0x8000000000008009ULL; break;
            case  8: RC = 0x000000000000008AULL; break;
            case  9: RC = 0x0000000000000088ULL; break;
            case 10: RC = 0x0000000080008009ULL; break;
            case 11: RC = 0x000000008000000AULL; break;
            case 12: RC = 0x000000008000808BULL; break;
            case 13: RC = 0x800000000000008BULL; break;
            case 14: RC = 0x8000000000008089ULL; break;
            case 15: RC = 0x8000000000008003ULL; break;
            case 16: RC = 0x8000000000008002ULL; break;
            case 17: RC = 0x8000000000000080ULL; break;
            case 18: RC = 0x000000000000800AULL; break;
            case 19: RC = 0x800000008000000AULL; break;
            case 20: RC = 0x8000000080008081ULL; break;
            case 21: RC = 0x8000000000008080ULL; break;
            case 22: RC = 0x0000000080000001ULL; break;
            case 23: RC = 0x8000000080008008ULL; break;
            default: RC = 0x0000000000000000ULL; break;
        }

        //Theta step
    	for(i = 0; i < 5; i++)
        {
            B[i] = s[i] ^ s[i+5] ^ s[i+10] ^ s[i+15] ^ s[i+20];
        }

        for(i = 0; i < 5; i++)
        {
            D[i] = B[(i+4) % 5] ^ ROL(B[(i+1) % 5], 1);
        }

        for(x = 0; x < 5; x++)
        {
            for(y = 0; y < 5; y++)
            {
                s[x + 5*y] ^= D[x];
            }
        }

        //Rho and Pi steps
        B[0] = s[0];
        B[1] = ROL(s[6], 44);
        B[2] = ROL(s[12], 43);
        B[3] = ROL(s[18], 21);
        B[4] = ROL(s[24], 14);        
        B[5] = ROL(s[3], 28);
        B[6] = ROL(s[9], 20);
        B[7] = ROL(s[10],  3);
        B[8] = ROL(s[16], 45);
        B[9] = ROL(s[22], 61);        
        B[10] = ROL(s[1],  1);
        B[11] = ROL(s[7],  6);
        B[12] = ROL(s[13], 25);
        B[13] = ROL(s[19],  8);
        B[14] = ROL(s[20], 18);
        B[15] = ROL(s[4], 27);
        B[16] = ROL(s[5], 36);
        B[17] = ROL(s[11], 10);
        B[18] = ROL(s[17], 15);
        B[19] = ROL(s[23], 56);
        B[20] = ROL(s[2], 62);
        B[21] = ROL(s[8], 55);
        B[22] = ROL(s[14], 39);
        B[23] = ROL(s[15], 41);
        B[24] = ROL(s[21],  2);

        //Chi step
        for(x = 0; x < 5; x++)
        {
            for(y = 0; y < 5; y++)
            {
                s[x+5*y] = B[x+5*y] ^ ((~B[(x+1)%5+5*y]) & B[(x+2)%5+5*y]);
            }
        }

        //Iota
        s[0] ^= RC;
    }
    #undef    round
}


/********** SHAKE128 ***********/
//Helping function that simply calls shake128, as otherwise the verification of the
//generated VHDL code fails for some reason
//Extra function has little to no influence on total hardware usage ot latency
void shake(uint16_t output[21000], uint16_t outlen, uint16_t input[10000], uint16_t inlen)
{
    shake128(output, outlen, input, inlen);
}

void shake128(uint16_t output[21000], uint16_t outlen, const uint16_t input[10000],  uint16_t inlen)
{
    #pragma HLS INLINE off
	#pragma HLS ARRAY_PARTITION variable=s complete dim=1
	#pragma HLS INTERFACE ap_memory depth=21000 port=output
	#pragma HLS INTERFACE ap_memory depth=10000 port=input
    #pragma HLS RESOURCE variable=input core=RAM_T2P_BRAM
    #pragma HLS RESOURCE variable=output core=RAM_T2P_BRAM

	size_t i, j;
	uint16_t end;
	uint64_t r;

	/* Reset internal state */
	Reset: for(i = 0; i < 25; i++)
	{
		#pragma HLS UNROLL
		s[i] = 0;
	}

    //Absorbing phase
	Absorb: while(inlen > 0) 
	{
        //Check if a full block can be absorbed (-> read and xor 21 words of the state)
        //or if the remaining input is less than a block
		if(inlen >= SHAKE128_RATE)
			end = SHAKE128_RATE >> 3;
		else
			end = inlen >> 3;

        //Read 4 16 bit input elements, xor them to the current word of the state
		L1: for(i = 0; i < end; i++)
		{
            #pragma HLS PIPELINE
			r = 0;
            r = SET_RANGE(r, 15,  0, ROL_16(input[0], 8));
            r = SET_RANGE(r, 31, 16, ROL_16(input[1], 8));
            r = SET_RANGE(r, 47, 32, ROL_16(input[2], 8));
            r = SET_RANGE(r, 63, 48, ROL_16(input[3], 8));
			s[i] ^= r;
			input += 4;
		}

        //If a full block was absorbed: permute the state, else finish the padding,
        //but do not call the permutation (done at the start of the squeezing)
		if(end == (SHAKE128_RATE >> 3))
			KeccakF1600_StatePermute();
        else
            s[20] ^= 0x8000000000000000;

        //Decrease the remaining input length by the number of input elements absorbed
		inlen -= (end << 3);
	}	

	//Squeezing phase
	Squeeze: while(outlen > 0) 
	{
        //Permute the state at least once
		KeccakF1600_StatePermute();

        //Determine how many output words are to be generated:
        //Either a full block, or less than a block
		if(outlen >= SHAKE128_RATE)
			end = SHAKE128_RATE >> 3;
		else
			end = outlen >> 3;

        //Generate the outputs from the state
		L2: for (i = 0; i < end; i++)
		{
			r = s[i];
			L2_2: for(j = 0; j < 4; j++)
			{
                #pragma HLS PIPELINE
				output[4*i+j] = ROL_16((r & 0xFFFF), 8);
				r >>= 16;
			}
		}

        //Decrease output length
		output += (end << 2);
		outlen -= (end << 3);
	}
}