#include "frodo_dec.h"

void frodo_dec(uint16_t ss[8], uint16_t ct[4860], uint16_t sk[9944])
{
    #pragma HLS INTERFACE ap_memory depth=8 port=ss
    #pragma HLS INTERFACE ap_memory depth=4860 port=ct
    #pragma HLS INTERFACE ap_memory depth=9944 port=sk

    uint16_t *ct_c1 = &ct[0];
    uint16_t *ct_c2 = &ct[(PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/16];
    uint16_t *sk_s = &sk[0];
    uint16_t *sk_S = &sk[(CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES)/2];
    uint16_t *sk_pk = &sk[CRYPTO_BYTES/2];
    uint16_t *sk_pkh = &sk[(CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES + 2*PARAMS_N*PARAMS_NBAR)/2];
    uint16_t *pk_seedA = &sk_pk[0];
    uint16_t *pk_b = &sk_pk[BYTES_SEED_A/2];

    uint16_t seed_SE_prime[9];

    uint16_t G2out[16];
    #pragma HLS INTERFACE ap_bus depth=16 port=G2out
    uint16_t *seedSEprime = &G2out[0];
    uint16_t *kprime = &G2out[8];

    uint16_t shake_input_1[PARAMS_N], shake_input_2[PARAMS_N];

    uint16_t mu_prime[16];
    #pragma HLS INTERFACE ap_bus depth=16 port=mu_prime

    uint16_t B_1[PARAMS_N], B_2[PARAMS_N];
    #pragma HLS INTERFACE ap_bus depth=640 port=B_1
    #pragma HLS INTERFACE ap_bus depth=640 port=B_2

    uint16_t W_1[PARAMS_N], W_2[PARAMS_N];
    #pragma HLS INTERFACE ap_bus depth=640 port=W_1
    #pragma HLS INTERFACE ap_bus depth=640 port=W_2

    uint16_t S_1[PARAMS_N], S_2[PARAMS_N];
    #pragma HLS INTERFACE ap_bus depth=640 port=S_1
    #pragma HLS INTERFACE ap_bus depth=640 port=S_2

    uint16_t E_1[PARAMS_N], E_2[PARAMS_N];
    #pragma HLS INTERFACE ap_bus depth=640 port=E_1
    #pragma HLS INTERFACE ap_bus depth=640 port=E_2

    uint16_t A_1[672], A_2[672];
    #pragma HLS INTERFACE ap_bus depth=672 port=A_1
    #pragma HLS INTERFACE ap_bus depth=672 port=A_2
    #pragma HLS RESOURCE variable=A_1 core=RAM_T2P_BRAM
    #pragma HLS RESOURCE variable=A_2 core=RAM_T2P_BRAM

    uint16_t seed_A_separated[9];

    uint8_t pregen_S, begin_vec_mat_mul, pregen_A, begin_add_write_reset, pregen_B, 
        reset, begin_absorb, begin_read_input, begin_compare, check1 = 0, check2 = 0;
    uint16_t unpack_rest, ct_offset, start_word = 0, start1, end1, start2, end2,
        inlen_read_input, temp, templong, inter, maskq = ((uint16_t)1 << PARAMS_LOGQ) -1,
        outlen, k;
    uint8_t i, j;

    //Reset 8 elements in the arrays for later
    Reset: for(i = 0; i < PARAMS_NBAR; i++)
    {
        W_2[i] = 0;
        E_1[i] = 0;
    }

    //First Matrix multiplication
    //In the first iteration, the first row of B' is unpacked into S_1
    //Starting from the second iteration, one row of B' is multiplied with S and the 
    //next row is unpacked in parallel. The result of the multiplication is 
    //subtracted from the unpacked C (in E_2) and decoded into mu_prime
    Mat_Mul_1: for(i = 0; i < PARAMS_NBAR+1; i++)
    {
        if(i == 0)
            begin_vec_mat_mul = 0;
        else
            begin_vec_mat_mul = 1;

        if(i == 1)
            pregen_S = 1;
        else
            pregen_S = 0;

        if(i == PARAMS_NBAR)
            ct_offset = 0;
        else
            ct_offset = 600*i;

        if((i & 0x1) == 0)
        {
            frodo_unpack(S_1, ct_c1+ct_offset, 640);
            vector_matrix_mul(W_2, S_2, A_1, A_2, E_1, sk_S, seed_A_separated, pk_b, 
                pregen_S, PARAMS_NBAR, 0, begin_vec_mat_mul);
        }
        else
        {
            frodo_unpack(S_2, ct_c1+ct_offset, 640);
            vector_matrix_mul(W_2, S_1, A_1, A_2, E_1, sk_S, seed_A_separated, pk_b, 
                pregen_S, PARAMS_NBAR, 0, begin_vec_mat_mul);
        }

        //Unpack C into E_2
        frodo_unpack(E_2, ct_c2, 64);

        //Subtraction and decoding
        if(i > 0)
        {
            Write_W: for(j = 0; j < PARAMS_NBAR; j++)
            {
                inter = E_2[(i-1)*PARAMS_NBAR+j] - (W_2[j] & ((1 << PARAMS_LOGQ)-1));
                temp = ((inter & maskq) >> 13);
                if((inter >> 12) & 0x1)
                    temp += 1;

                templong = SET_RANGE(templong, 1, 0, (temp & 0x3));
                templong = ROL(16, templong, 14);
                W_2[j] = 0;
            }
            mu_prime[i-1] = templong;
        }
    }

    //Prepare shake_input for hashing by writing pkh and mu' into it
    Write_mu: for(i = 0; i < 8; i++)
    {
        #pragma HLS PIPELINE
        shake_input_1[i] = sk_pkh[i];
        shake_input_1[8+i] = ROL(16, mu_prime[i], 8);
    }

    //Finish the padding
    shake_input_1[16] = 0x1F00;
    shake_input_1[17] = 0x0000;
    shake_input_1[18] = 0x0000;
    shake_input_1[19] = 0x0000;
    
    //Hash pkh||mu'
    absorb_block(G2out, shake_input_1, 2*CRYPTO_BYTES, 5, 1, 1);

    //Calculate seedA and seedSE'
    seed_A_separated[0] = 0;

    Set_seedA: for(i = 0; i < 8; i++)
    {     
        seed_A_separated[i+1] = ROL(16, pk_seedA[i], 8);
    }

    seed_SE_prime[0] = (0x96 << 8) | ((seedSEprime[0] >> 8) & 0xFF);
    for(i = 0; i < 7; i++)
    {
        seed_SE_prime[i+1] = ((seedSEprime[i] & 0xFF) << 8) | ((seedSEprime[i+1] >> 8) & 0xFF);
    }
    seed_SE_prime[8] = ((seedSEprime[7] & 0xFF) << 8) | 0x1F;

    //Generate the first rows of S' and E' into S_2 and E_2, reset W_2 for the matrix multiplication
    shake_gen_S_E(S_2, E_2, 2560, seed_SE_prime, 0, 160, 1280, 1440, 1);
    reset_vector(W_2, PARAMS_N, 1);

    //Second matrix multiplication, calculating S'*A + E'
    //The resulting matrix B'' is calculated row-wise, the next entries of S' and E'
    //are calculated in parallel
    //Also in parallel, B' is unpacked again from c_1
    //Starting from the second iteration, the unpacked row of B' and the result of the 
    //multiplication are compared. If both matrices are identical, check1 is 0 at the
    //end of the loop.
    //In the final iteration, S' and E'' are pregenerated for the third multiplication
    Mat_Mul_2: for(i = 0; i < PARAMS_NBAR; i++)
    {
        if(i == 0)
            pregen_A = 1;
        else
            pregen_A = 0;

        if(i == PARAMS_NBAR-1)
        {
            start1 = 0;
            end1 = 160;
            start2 = 2560;
            end2 = 2576;
            outlen = 1408;
        }
        else
        {
            start1 = 160*(i+1);
            end1 = 160*(i+2);
            start2 = 1280+160*(i+1);
            end2 = 1280+160*(i+2);
            outlen = 2560;
        }

        if(i == 1)
            check1 = 0;

        ct_offset = 600*i;
        begin_vec_mat_mul = 1;
        begin_compare = 1;

        if((i & 0x1) == 0)
        {
            shake_gen_S_E(S_1, E_1, outlen, seed_SE_prime, start1, end1, start2, end2, 1);
            vector_matrix_mul(W_2, S_2, A_1, A_2, E_2, sk_S, seed_A_separated, 
                pk_b, pregen_A, PARAMS_N, 1, begin_vec_mat_mul);
            frodo_unpack(B_2, ct_c1+ct_offset, 640);
            check1 |= compare(B_1, W_1, PARAMS_N, begin_compare);
        }
        else
        {
            shake_gen_S_E(S_2, E_2, outlen, seed_SE_prime, start1, end1, start2, end2, 1);
            vector_matrix_mul(W_1, S_1, A_1, A_2, E_1, sk_S, seed_A_separated, 
                pk_b, pregen_A, PARAMS_N, 1, begin_vec_mat_mul);
            frodo_unpack(B_1, ct_c1+ct_offset, 640);
            check1 |= compare(B_2, W_2, PARAMS_N, begin_compare);
        }
    }


    //Final comparison, C is unpacked again
    check1 |= compare(B_1, W_1, PARAMS_N, 1);
    frodo_unpack(B_2, ct_c2, 64);

    /*
        Third matrix mulitplication: V = S'*B + E'', calculated row-wise
        The rows are added to the encoded version of mu' using the function encode()
        In parallel, ct is hashed by loading it into shake_input in packs of 640
        and then hashing it from there
    */
    
    Mat_Mul_3: for(i = 0; i < PARAMS_NBAR; i++)
    {
        if(i == 0)
        {
            pregen_B = 1;
            begin_absorb = 0;
        }
        else
        {
            pregen_B = 0;
            begin_absorb = 1;
        }

        if(i == 1)
            reset = 1;
        else
            reset = 0;

        if(i == 7)
            inlen_read_input = 380;
        else
            inlen_read_input = 640;

        begin_vec_mat_mul = 1;
        start1 = 160*(i+1);
        end1 = 160*(i+2);
        start2 = 2560+2*(i+1);
        end2 = 2576+2*(i+1);
        ct_offset = 640*i;
        temp = mu_prime[i];

        if((i & 0x1) == 0)
        {
            shake_gen_S_E(S_1, E_1, 1408, seed_SE_prime, start1, end1, start2, end2, 1);
            vector_matrix_mul(W_1, S_2, A_1, A_2, E_2, sk_S, seed_A_separated, pk_b, 
                pregen_B, PARAMS_NBAR, 2, begin_vec_mat_mul);
            read_input(shake_input_2, ct+ct_offset, inlen_read_input, 1);
            absorb_block(mu_prime, shake_input_1, 0, 160, reset, begin_absorb);
            encode(B_1+8*i, W_1, temp, 1);
        }
        else
        {
            shake_gen_S_E(S_2, E_2, 1408, seed_SE_prime, start1, end1, start2, end2, 1);
            vector_matrix_mul(W_1, S_1, A_1, A_2, E_1, sk_S, seed_A_separated, pk_b, 
                pregen_B, PARAMS_NBAR, 2, begin_vec_mat_mul);
            read_input(shake_input_1, ct+ct_offset, inlen_read_input, 1);
            absorb_block(mu_prime, shake_input_2, 0, 160, reset, begin_absorb);
            encode(B_1+8*i, W_1, temp, 1);
        }
    }

    //Comparison of C and C', check2 is 0 if matrices are identical
    check2 = compare(B_2, B_1, PARAMS_NBAR*PARAMS_NBAR, 1);

    //Either write k' or s into shake_input, finish padding...
    for(i = 0; i < 8; i++)
    {
        if((check1 == 0) && (check2 == 0))
            temp = kprime[i];
        else
            temp = sk_s[i];

        shake_input_1[380+i] = temp;
    }
    shake_input_1[388] = 0x1F00;
    shake_input_1[389] = 0x0000;
    shake_input_1[390] = 0x0000;
    shake_input_1[391] = 0x0000;

    //...and finish the hash of ct
    absorb_block(mu_prime, shake_input_1, CRYPTO_BYTES, 98, 0, 1);

    //Write the result of the hash into ss
    Set_ss: for(i = 0; i < 8; i++)
    {
        #pragma HLS PIPELINE
        ss[i] = mu_prime[i];
    }
}

/*
    Calculates one row of C = V + Encode(mu'), resets the row of V
    Inputs :  uint16_t *in      : one row of V
              uint16_t mu       : one element of mu
              uint8_t begin     : decides if the function is executed
    Outputs : uint16_t *out     : resulting row of C
*/
void encode(uint16_t *out, uint16_t *in, uint16_t mu, uint8_t begin)
{
    #pragma HLS INLINE off
    uint8_t i;
    L1: for(i = 0; i < 8; i++)
    {
        #pragma HLS PIPELINE
        out[i] = (in[i] + ((mu & 0x3) << 13)) & ((1 << PARAMS_LOGQ)-1);
        mu >>= 2;
        in[i] = 0;
    }
}

/*
    Resets n elements of the vector
    Inputs : uint16_t in    : vector to be reset
             uint16_t n     : number of elements to be reset
             uint8_t begin  : decides if function is executed
*/
void reset_vector(uint16_t *in, uint16_t n, uint8_t begin)
{
    #pragma HLS INLINE off
    uint16_t i;
    L1: for(i = 0; i < n; i++)
    {
        #pragma HLS PIPELINE
        in[i] = 0;
    }
}

/*
    Compares n elements of the vectors in_1 and in_2, returns 0 if they are identical
    Inputs : uint16_t *in_1 : 1st input vector
             uint16_t *in_2 : 2nd input vector
             uint16_t n     : number of elements to be compared
             uint8_t begin  : decides if function is executed
    Return : uint16_t check : 0 if vectors are identical, 1 else
*/
uint8_t compare(uint16_t *in_1, uint16_t *in_2, uint16_t n, uint8_t begin)
{
    uint16_t i, check = 0;
    if(begin)
    {
        L1: for(i = 0; i < n; i++)
        {
            #pragma HLS PIPELINE
            if(in_1[i] != in_2[i])
                check = 1;
            in_2[i] = 0;
        }
    }
    return check;
}

/*
    Help function that writes n elements from in into out
    Inputs :  uint16_t *in      : input vector
              uint16_t n        : number of elements to be written
              uint8_t begin     : decides if function is executed
    Outputs : uint16_t *out     : output vector
*/
void read_input(uint16_t *out, uint16_t *in, uint16_t n, uint8_t begin)
{
    uint16_t i;
    if(begin)
    {
        L1: for(i = 0; i < n; i++)
        {
            #pragma HLS PIPELINE
            out[i] = in[i];
        }
    }
}

/*
    Serves as a register for HLS
*/
uint16_t reg(uint16_t in)
{
    #pragma HLS PIPELINE II=1
    #pragma HLS INTERFACE ap_ctrl_none register port=return
    #pragma HLS INLINE off
    return in;
}

/*
    Performs the multiplication of a scalar with a vector, adds error terms if
    the function is called the first time
    Inputs :  uint16_t *input_vec   : input vector
              uint16_t scalar       : scalar for multiplication
              uint16_t n            : number of elements in the vector
              uint16_t index        : indicates how often the function has been called
              uint16_t *E           : contains error terms
    Outputs : uint16_t *output_vec  : output vector
*/
void scalar_vector_mul(uint16_t *output_vec, uint16_t *input_vec, 
    uint16_t scalar, uint16_t n, uint16_t index, uint16_t *E)
{
    #pragma HLS INLINE off
    uint16_t i, temp, e;
    L1: for(i = 0; i < n; i++)
    {
        #pragma HLS PIPELINE
        //In the first iteration, add error terms, in the others add 0
        if(index == 0)
            e = E[i];
        else
            e = 0;

        //Multiply scalar with the input element and add e, store result in 
        //a register
        temp = scalar*input_vec[i] + e;
        temp = reg(temp);
        //In the next clock cycle add result to output vector
        output_vec[i] = (output_vec[i] + temp) & ((1 << PARAMS_LOGQ)-1);
    }
}

/*
    Multiplies vector S on the left with matrix on the right, generated internally
    into A_1 and A_2
    Inputs :  uint16_t *S           : vector on the left
              uint16_t *A_1         : 1st array for matrix on the right
              uint16_t *A_2         : 2nd array for matrix on the right
              uint16_t *E           : error term vector
              uint16_t *sk          : secret key for 1st matrix mult.
              uint16_t *seed_A_separated : seedA for 2nd matrix mult
              uint16_t *pk          : public key for 3rd matrix mult
              uint8_t pregen        : pregeneration only happens if pregen is 1
              uint16_t n            : number of columns of matrix on the right
              uint8_t use_A         : controls which matrix mult. is executed 
                (0 for 1st, 1 for 2nd, 2 for 3rd)
              uint8_t begin         : decides if function is executed
    Ouptuts : uint16_t *output_vec  : output vector
*/
void vector_matrix_mul(uint16_t *output_vec, uint16_t *S, uint16_t *A_1, 
    uint16_t *A_2, uint16_t *E, uint16_t *sk, uint16_t *seed_A_separated, 
    uint16_t *pk, uint8_t pregen, uint16_t n, uint8_t use_A, uint8_t begin)
{
    uint16_t i, temp, offset_S, offset_B = 0, j;
    static uint16_t unpack_rest;

    if(begin)
    {
        /*
            Pregeneration phase if necessary
            Either read a row from sk, generate a row using SHAKE, or by unpacking
            from pk
        */
        if(pregen)
        {
            if(use_A == 0)
            {
                read_S(A_2, sk, 0);
            }
            else if(use_A == 1)
            {
                shake128_10240(A_2, seed_A_separated);
            }
            else
            {
                frodo_unpack_8(A_2, pk+offset_B, 16);
            }
        }

        /*
            Multiplication. One row is generated as in the pregeneration, and the
            previous row is multiplied with S and the results added to the 
            output vector
        */
        for(i = 0; i < PARAMS_N; i++)
        {
            temp = S[i];
            if(i == PARAMS_N-1)
            {
                offset_S = 0;
                seed_A_separated[0] = 0;
            }
            else
            {
                offset_S = i+1;
                seed_A_separated[0] = i+1;
            }

            if((i & 0x1) == 0)
            {
                if(use_A == 0)
                {
                    read_S(A_1, sk, offset_S);
                    scalar_vector_mul(output_vec, A_2, temp, n, i, E);
                }
                else if(use_A == 1)
                {
                    shake128_10240(A_1, seed_A_separated);
                    scalar_vector_mul(output_vec, A_2, temp, n, i, E);
                }
                else
                {
                    frodo_unpack_8(A_1, pk+offset_B+8, 8);
                    scalar_vector_mul(output_vec, A_2, temp, n, i, E);
                    offset_B += 15;
                }
            }
            else
            {
                if(use_A == 0)
                {
                    read_S(A_2, sk, offset_S);
                    scalar_vector_mul(output_vec, A_1, temp, n, i, E);
                }
                else if(use_A == 1)
                {
                    shake128_10240(A_2, seed_A_separated);
                    scalar_vector_mul(output_vec, A_1, temp, n, i, E);
                }
                else
                {
                    frodo_unpack_8(A_2, pk+offset_B, 16);
                    scalar_vector_mul(output_vec, A_1, temp, n, i, E);
                }
            }

            //Reset the offset for the unpacking of B in the 3rd matrix mult.
            if(i == PARAMS_N-2)
                offset_B = 0;
        }
    }
}

/*
    Reads 8 entries of S from the secret key into out. For correctness, only every 
    8th entry is taken, and entries are rotated by 8 positions
*/
void read_S(uint16_t *out, uint16_t *in, uint16_t offset)
{
    uint8_t j;
    L1: for(j = 0; j < PARAMS_NBAR; j++)
    {
        //#pragma HLS UNROLL factor=2
        #pragma HLS PIPELINE
        out[j] = ROL(16, in[j*PARAMS_N+offset], 8);
    }
}