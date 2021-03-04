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

#include <string.h>
#include <stdint.h>
#include <assert.h>
#include <stdio.h>
#include "ap_cint.h"
#include "fips202.h"
#include "noise.h"
#include "api.h"

#define NROUNDS 24
#define ROL(a, offset) ((a << offset) ^ (a >> (64-offset)))
#define ROL_16(a, offset) ((a << offset) ^ (a >> (16-offset)))

//Different states of SHAKE for the different instances
uint64_t q[25];
uint64_t p[25];
uint64_t s[25];
uint64_t t[25];
uint64_t z[25];

//State Permutation of SHAKE, each round executes in 1 clock cycle
void KeccakF1600_StatePermute()
{
    int round, i, j, x, y;
    uint64_t B[25], D[5], RC;
    #pragma HLS ARRAY_PARTITION variable=B complete dim=1
    #pragma HLS ARRAY_PARTITION variable=D complete dim=1

    Loop: for(round = 0; round < NROUNDS; round++)
    {
        #pragma HLS PIPELINE

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

        Set_B: for(i = 0; i < 5; i++)
        {
            B[i] = s[i] ^ s[i+5] ^ s[i+10] ^ s[i+15] ^ s[i+20];
        }

        Set_D: for(i = 0; i < 5; i++)
        {
            D[i] = B[(i+4) % 5] ^ ROL(B[(i+1) % 5], 1);
        }

        Theta_1: for(x = 0; x < 5; x++)
        {
            Theta_2: for(y = 0; y < 5; y++)
            {
                s[x + 5*y] ^= D[x];
            }
        }

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

        for(x = 0; x < 5; x++)
        {
            for(y = 0; y < 5; y++)
            {
                s[x+5*y] = B[x+5*y] ^ ((~B[(x+1)%5+5*y]) & B[(x+2)%5+5*y]);
            }
        }

        s[0] ^= RC;
    }
    #undef    round
}

void KeccakF1600_StatePermute_2()
{
    int round, i, j, x, y;
    uint64_t B[25], D[5], RC;
    #pragma HLS ARRAY_PARTITION variable=B complete dim=1
    #pragma HLS ARRAY_PARTITION variable=D complete dim=1

    Loop: for(round = 0; round < NROUNDS; round++)
    {
        #pragma HLS PIPELINE

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

        Set_B: for(i = 0; i < 5; i++)
        {
            B[i] = z[i] ^ z[i+5] ^ z[i+10] ^ z[i+15] ^ z[i+20];
        }

        Set_D: for(i = 0; i < 5; i++)
        {
            D[i] = B[(i+4) % 5] ^ ROL(B[(i+1) % 5], 1);
        }

        Theta_1: for(x = 0; x < 5; x++)
        {
            Theta_2: for(y = 0; y < 5; y++)
            {
                z[x + 5*y] ^= D[x];
            }
        }

        B[0] = z[0];
        B[1] = ROL(z[6], 44);
        B[2] = ROL(z[12], 43);
        B[3] = ROL(z[18], 21);
        B[4] = ROL(z[24], 14);        
        B[5] = ROL(z[3], 28);
        B[6] = ROL(z[9], 20);
        B[7] = ROL(z[10],  3);
        B[8] = ROL(z[16], 45);
        B[9] = ROL(z[22], 61);        
        B[10] = ROL(z[1],  1);
        B[11] = ROL(z[7],  6);
        B[12] = ROL(z[13], 25);
        B[13] = ROL(z[19],  8);
        B[14] = ROL(z[20], 18);
        B[15] = ROL(z[4], 27);
        B[16] = ROL(z[5], 36);
        B[17] = ROL(z[11], 10);
        B[18] = ROL(z[17], 15);
        B[19] = ROL(z[23], 56);
        B[20] = ROL(z[2], 62);
        B[21] = ROL(z[8], 55);
        B[22] = ROL(z[14], 39);
        B[23] = ROL(z[15], 41);
        B[24] = ROL(z[21],  2);

        for(x = 0; x < 5; x++)
        {
            for(y = 0; y < 5; y++)
            {
                z[x+5*y] = B[x+5*y] ^ ((~B[(x+1)%5+5*y]) & B[(x+2)%5+5*y]);
            }
        }

        z[0] ^= RC;
    }
    #undef    round
}

void KeccakF1600_StatePermute_3()
{
    int round, i, j, x, y;
    uint64_t B[25], D[5], RC;
    #pragma HLS ARRAY_PARTITION variable=B complete dim=1
    #pragma HLS ARRAY_PARTITION variable=D complete dim=1

    Loop: for(round = 0; round < NROUNDS; round++)
    {
        #pragma HLS PIPELINE
        //printf("%016llX\n", p[0]);

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

        Set_B: for(i = 0; i < 5; i++)
        {
            B[i] = p[i] ^ p[i+5] ^ p[i+10] ^ p[i+15] ^ p[i+20];
        }

        Set_D: for(i = 0; i < 5; i++)
        {
            D[i] = B[(i+4) % 5] ^ ROL(B[(i+1) % 5], 1);
        }

        Theta_1: for(x = 0; x < 5; x++)
        {
            Theta_2: for(y = 0; y < 5; y++)
            {
                p[x + 5*y] ^= D[x];
            }
        }

        B[0] = p[0];
        B[1] = ROL(p[6], 44);
        B[2] = ROL(p[12], 43);
        B[3] = ROL(p[18], 21);
        B[4] = ROL(p[24], 14);        
        B[5] = ROL(p[3], 28);
        B[6] = ROL(p[9], 20);
        B[7] = ROL(p[10],  3);
        B[8] = ROL(p[16], 45);
        B[9] = ROL(p[22], 61);        
        B[10] = ROL(p[1],  1);
        B[11] = ROL(p[7],  6);
        B[12] = ROL(p[13], 25);
        B[13] = ROL(p[19],  8);
        B[14] = ROL(p[20], 18);
        B[15] = ROL(p[4], 27);
        B[16] = ROL(p[5], 36);
        B[17] = ROL(p[11], 10);
        B[18] = ROL(p[17], 15);
        B[19] = ROL(p[23], 56);
        B[20] = ROL(p[2], 62);
        B[21] = ROL(p[8], 55);
        B[22] = ROL(p[14], 39);
        B[23] = ROL(p[15], 41);
        B[24] = ROL(p[21],  2);

        for(x = 0; x < 5; x++)
        {
            for(y = 0; y < 5; y++)
            {
                p[x+5*y] = B[x+5*y] ^ ((~B[(x+1)%5+5*y]) & B[(x+2)%5+5*y]);
            }
        }

        p[0] ^= RC;
    }
    #undef    round
}


/********** SHAKE128 ***********/
/*
    Function that absorbs a full block (1344 bit), permutes the state, and 
    squeezes the full output
    Inputs:  uint16_t *input: input array
             unsigned int outlen: length of the output 
             unsigned int inlen: input length (in full 64-bit words)
             unsigned int reset: indicates if the state should be zeroed at the start
             unsigned int squeeze: indicates if output should be generated
    Output:  uint8_t *output: output array
*/
void absorb_block(uint16_t *output, uint16_t *input, uint16_t outlen, 
    uint16_t inlen, uint8_t reset, uint8_t begin)
{
	#pragma HLS ARRAY_PARTITION variable=p complete dim=1
    uint8_t i, j;
    uint16_t end, ret_end, sum;
    uint64_t r;
    static uint8_t start;

    if(begin)
    {
        //Reset state if needed
        if(reset == 0x1)
        {
            start = 0;
            Reset_1: for(i = 0; i < 25; i++)
            {
                #pragma HLS PIPELINE
                p[i] = 0;
            }
        }

        //Absorb the input and XOR it to the state
        Absorb: while(inlen > 0)
        {
            #pragma HLS LOOP_TRIPCOUNT min=0 max=8

            sum = inlen + start;
            if(sum >= SHAKE128_RATE >> 3)
                end = SHAKE128_RATE >> 3;
            else
                end = sum;

            Absorb_1: for(i = start; i < end; i++)
            {
                #pragma HLS LOOP_TRIPCOUNT min=1 max=21
                #pragma HLS PIPELINE
                r = SET_RANGE(r, 15,  0, ROL_16(input[0], 8));
                r = SET_RANGE(r, 31, 16, ROL_16(input[1], 8));
                r = SET_RANGE(r, 47, 32, ROL_16(input[2], 8));
                r = SET_RANGE(r, 63, 48, ROL_16(input[3], 8));
                p[i] ^= r;
                input += 4;
            }

            if(end == (SHAKE128_RATE >> 3))
            {
                if((sum != (SHAKE128_RATE >> 3)) || ((inlen == (SHAKE128_RATE >> 3)) && (outlen == 0)))
                {
                    KeccakF1600_StatePermute_3();
                }
            }

            inlen -= (end-start);
            if(end == (SHAKE128_RATE >> 3))
                start = 0;
            else
                start = end;
        }        

        //Generate output if needed
        if(outlen > 0)
        {
            //Finish padding
            p[20] = SET_RANGE(p[20], 63, 63, (0x1 ^ GET_RANGE(p[20], 63, 63)));
            KeccakF1600_StatePermute_3();
            end = outlen >> 3;
            L1: for(i = 0; i < end; i++)
            {
                r = p[i];
                for(j = 0; j < 4; j++)
                {
                    output[4*i+j] = ROL_16((r & 0xFFFF), 8);
                    r >>= 16;
                }
            }
        }
    }
}

/*
    Generates one row of S (and later E). The function keeps its state and allows
    the generation of the 2nd, 3rd... row of S without absorbing the input again
    or generating the previous rows again
    Inputs  : uin16_t *input    : 24 byte input
              uint16_t outlen   : number of elements in one row of S
              uint8_t reset     : decides if the state is reset, starting the function
                completely over again
    Outputs : uint16_t *output  : output array
*/
void shake_gen_S(uint16_t *output, uint16_t *input, uint16_t outlen, uint8_t reset)
{
    #pragma HLS ARRAY_PARTITION variable=z complete dim=1
    uint16_t i, j, end, ret_end, temp, sum;
    uint64_t r;
    static uint8_t start;

    //Only reset the state and absorb the input if reset is one, else directly generate output
    if(reset)
    {
        start = 0;
        for(i = 0; i < 25; i++)
        {
            #pragma HLS PIPELINE
            z[i] = 0;
        }

        z[0] = SET_RANGE(z[0], 15,  0, ROL_16(input[0], 8));
        z[0] = SET_RANGE(z[0], 31, 16, ROL_16(input[1], 8));
        z[0] = SET_RANGE(z[0], 47, 32, ROL_16(input[2], 8));
        z[0] = SET_RANGE(z[0], 63, 48, ROL_16(input[3], 8));
        z[1] = SET_RANGE(z[1], 15,  0, ROL_16(input[4], 8));
        z[1] = SET_RANGE(z[1], 31, 16, ROL_16(input[5], 8));
        z[1] = SET_RANGE(z[1], 47, 32, ROL_16(input[6], 8));
        z[1] = SET_RANGE(z[1], 63, 48, ROL_16(input[7], 8));
        z[2] = SET_RANGE(z[2], 15,  0, ROL_16(input[8], 8));
        z[2] = SET_RANGE(z[2], 31, 16, ROL_16(input[9], 8));
        z[2] = SET_RANGE(z[2], 47, 32, ROL_16(input[10], 8));
        z[2] = SET_RANGE(z[2], 63, 48, ROL_16(input[11], 8));

        //Finish padding
        z[20] = SET_RANGE(z[20], 63, 63, (0x1 ^ GET_RANGE(z[20], 63, 63)));
    }

    while(outlen > 0)
    {
        if(start == 0)
            KeccakF1600_StatePermute_2();

        //Decide how many more words of the current state can be used for the output
        //Generation of output can start in the middle of a block or might not need
        //to go until the end of a block
        sum = start + outlen;
        if(sum >= SHAKE128_RATE >> 3)
            end = SHAKE128_RATE >> 3;
        else
            end = sum;

        for(i = start; i < end; i++)
        {
            r = z[i];
            L1: for(j = 0; j < 4; j++)
            {
                #pragma HLS PIPELINE
                //Take the 16 lsb as input to the Gaussian sampler, write the sampled
                //value into the output
                temp = r & 0xFFFF;
                output[j] = frodo_sample(temp);
                r >>= 16;
            }
            output += 4;
        }

        outlen -= (end-start);
        start = 0;

        if(end == (SHAKE128_RATE >> 3))
            start = 0;
        else
            start = end;
    }
}

/*
    Function that generates one row of A
    Input:  uint16_t *input: input array
    Output: uint16_t *output: output array
*/
void shake128_10240(uint16_t *output, uint16_t *input)
{
	#pragma HLS ARRAY_PARTITION variable=s complete dim=1
    unsigned char i, j;

    //Reset state
    Reset: for(i = 0; i < 25; i++)
    {
		#pragma HLS UNROLL
        s[i] = 0;
    }

    //Absorb the 18 Byte input and apply the padding
    s[0]  = SET_RANGE( s[0], 15,  0, input[0]);
    s[0]  = SET_RANGE( s[0], 31, 16, input[1]);
    s[0]  = SET_RANGE( s[0], 47, 32, input[2]);
    s[0]  = SET_RANGE( s[0], 63, 48, input[3]);
    s[1]  = SET_RANGE( s[1], 15,  0, input[4]);
    s[1]  = SET_RANGE( s[1], 31, 16, input[5]);
    s[1]  = SET_RANGE( s[1], 47, 32, input[6]);
    s[1]  = SET_RANGE( s[1], 63, 48, input[7]);
    s[2]  = SET_RANGE( s[2], 15,  0, input[8]);
    s[2]  = SET_RANGE( s[2], 23, 16, 0x1F);
    s[20] = SET_RANGE(s[20], 63, 63, 1);

    //Squeeze 8 full blocks
    Squeeze: for(i = 0; i < 8; i++)
    {
        KeccakF1600_StatePermute();
        Squeeze_1: for(j = 0; j < 21; j++)
        {
            output[4*j+0] = GET_RANGE(s[j], 15,  0);
            output[4*j+1] = GET_RANGE(s[j], 31, 16);
            output[4*j+2] = GET_RANGE(s[j], 47, 32);
            output[4*j+3] = GET_RANGE(s[j], 63, 48);
        }
        output += (21 << 2);
    }
}