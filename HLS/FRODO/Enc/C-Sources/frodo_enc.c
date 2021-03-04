#include "frodo_enc.h"

void frodo_enc(uint16_t ct[4860], uint16_t ss[8], uint16_t mu_in[8], uint16_t pk[4808])
{
    #pragma HLS INTERFACE ap_memory depth=4808 port=pk
    #pragma HLS INTERFACE ap_memory depth=8 port=mu_in
    #pragma HLS INTERFACE ap_memory depth=8 port=ss
    #pragma HLS INTERFACE ap_memory depth=4860 port=ct

    uint16_t *pk_b = &pk[BYTES_SEED_A/2];

    uint16_t B_1[PARAMS_N], B_2[PARAMS_N];
    #pragma HLS INTERFACE ap_bus depth=640 port=B_1
    #pragma HLS INTERFACE ap_bus depth=640 port=B_2

    uint16_t G2in[16];
    uint16_t *pkh = &G2in[0];
    uint16_t *mu = &G2in[8];
    #pragma HLS INTERFACE ap_bus depth=16 port=G2in

    uint16_t G2out[16];
    #pragma HLS INTERFACE ap_bus depth=16 port=G2out
    uint16_t *seedSE = &G2out[0];
    uint16_t *ks = &G2out[8];

    uint16_t seed_SE[9];

    uint16_t V[PARAMS_NBAR*PARAMS_NBAR];
	#pragma HLS RESOURCE variable=V core=RAM_2P_LUTRAM
    #pragma HLS INTERFACE ap_bus depth=64 port=V
    
    uint8_t begin_absorb_block = 0, begin_read_input = 0, reset = 0, i, j, k, 
        begin_add_write_reset, begin_pack, pregen, begin_shake_gen = 1,
        begin_mat_mul = 1, use_A, begin_reset;

    uint16_t seed_A_separated[9], start1, end1, start2, end2, outlen, 
        read_input_length, x, temp, vec_mat_len, mask = (1 << PARAMS_EXTRACTED_BITS)-1;
    uint16_t b;
    uint16_t S_1[PARAMS_N], S_2[PARAMS_N], E_1[PARAMS_N], E_2[PARAMS_N];
    #pragma HLS INTERFACE ap_bus depth=640 port=S_1
    #pragma HLS INTERFACE ap_bus depth=640 port=S_2
    #pragma HLS INTERFACE ap_bus depth=640 port=E_1
    #pragma HLS INTERFACE ap_bus depth=640 port=E_2

    uint16_t A_1[672], A_2[672];
    #pragma HLS INTERFACE ap_bus depth=672 port=A_1
    #pragma HLS INTERFACE ap_bus depth=672 port=A_2

    uint16_t shake_input_1[PARAMS_N], shake_input_2[PARAMS_N];

    //Hash the public key in 8 blocks. Load pk into a local array first before
    //hashing it. 
    Hash_pk: for(i = 0; i < 8; i++)
    {
        if(i == 0)
            begin_absorb_block = 0;
        else
            begin_absorb_block = 1;

        if(i == 7)
            read_input_length = 328;
        else
            read_input_length = 640;

        begin_read_input = 1;

        if((i & 0x1) == 0)
        {
            absorb_block_write(pkh, shake_input_1, 0, 160, 0, begin_absorb_block,
                ct+600, 0, 0);
            read_input(shake_input_2, pk+640*i, read_input_length, begin_read_input);    
        }
        else
        {
            absorb_block_write(pkh, shake_input_2, 0, 160, 0, begin_absorb_block,
                ct+600, 0, 0);
            read_input(shake_input_1, pk+640*i, read_input_length, begin_read_input);
        }
    }

    //Apply padding before the last block of pk is hashed
    shake_input_1[328] = 0x1F00;
    shake_input_1[329] = 0x0000;
    shake_input_1[330] = 0x0000;
    shake_input_1[331] = 0x0000;
    absorb_block_write(pkh, shake_input_1, BYTES_PKHASH, 83, 0, 1,
        ct+600, 0, 0);

    //Load pkh into shake_input_1
    Set_shake_input: for(i = 0; i < BYTES_PKHASH/2; i++)
    {
        #pragma HLS PIPELINE
        shake_input_1[i] = pkh[i];
    }

    //Load mu into shake_input_1, write the beginning of pk into seed_A_separated
    Set_shake_input_2: for(i = 0; i < 8; i++)
    {
        #pragma HLS PIPELINE
        shake_input_1[BYTES_PKHASH/2 + i] = mu_in[i];
        mu[i] = ROL(16, mu_in[i], 8);
        seed_A_separated[i+1] = ROL(16, pk[i], 8);
    }

    //Apply the padding, then hash (pkh||mu)
    shake_input_1[16] = 0x1F00;
    shake_input_1[17] = 0x0000;
    shake_input_1[18] = 0x0000;
    shake_input_1[19] = 0x0000;

    absorb_block_write(G2out, shake_input_1, 2*CRYPTO_BYTES, 5, 1, 1, ct+600, 0, 0);

    //Set seed_SE = 0x96||seedSE
    seed_SE[0] = (0x96 << 8) | ((seedSE[0] >> 8) & 0xFF);
    for(i = 0; i < 7; i++)
    {
        seed_SE[i+1] = ((seedSE[i] & 0xFF) << 8) | ((seedSE[i+1] >> 8) & 0xFF);
    }
    seed_SE[8] = ((seedSE[7] & 0xFF) << 8) | 0x1F;

    //Pregenerate the first row of S' and E'. Reset B_2, packing not yet necessary
    shake_gen_S_E(S_2, E_2, 2560, seed_SE, 0, 160, 1280, 1440, 1);
    pack_reset(shake_input_1, B_2, PARAMS_N, 0, PARAMS_N, 1);

    //2 Matrix Multiplications. 1.: B'=S'*A+E', 2.: V=S'*B+E''
    //As soon as a row of B' is finished: Pack it, after packing hash it and write it into c_1
    Mat_Mul: for(i = 0; i < PARAMS_NBAR+9; i++)
    {
        if(i < 9)
        {
            begin_reset = 1;
            begin_add_write_reset = 0;
        }
        else
        {
            begin_reset = 0;
            begin_add_write_reset = 1;
        }

        if(i < 8)
        {
            vec_mat_len = PARAMS_N;
            use_A = 1;
        }
        else
        {
            vec_mat_len = PARAMS_NBAR;
            use_A = 0;
        }

        if(i < 16)   
            begin_mat_mul = 1;
        else
            begin_mat_mul = 0;

        if(i < 15)
            begin_shake_gen = 1;
        else
            begin_shake_gen = 0;

        if((i == 0) || (i == 8))
            pregen = 1;
        else
            pregen = 0;

        if((i >= 1) && (i < 9))
            begin_pack = 1;
        else
            begin_pack = 0;

        if(i == 2)
            reset = 1;
        else
            reset = 0;

        if((i >= 2) && (i < 10))
        {
            begin_absorb_block = 1;
            begin_read_input = 1;
        }
        else
        {
            begin_absorb_block = 0;
            begin_read_input = 0;
        }

        if(i >= PARAMS_NBAR-1)
        {
            start1 = 160*(i-7);
            end1 = 160*(i-6);
            start2 = 2560+2*(i-7);
            end2 = 2576+2*(i-7);
            outlen = 1408;
        }
        else
        {
            start1 = 160*(i+1);
            end1 = 160*(i+2);
            start2 = 1280 + start1;
            end2 = 1280 + end1;
            outlen = 2560;
        }

        if((i & 0x1) == 0)
        {
            pack_reset(shake_input_2, B_1, PARAMS_N, begin_pack, PARAMS_N, begin_reset);
            shake_gen_S_E(S_1, E_1, outlen, seed_SE, start1, end1, start2, end2, begin_shake_gen);
            vector_matrix_mul(B_2, S_2, A_1, A_2, E_2, seed_A_separated, pk_b, pregen, vec_mat_len, use_A, begin_mat_mul);
            absorb_block_write(G2in, shake_input_1, 0, 150, reset, begin_absorb_block,
                ct+600*(i-2), 600, begin_read_input);
            write_reset_mod(V+8*(i-9), B_1, PARAMS_NBAR, begin_add_write_reset);
        }
        else
        {
            pack_reset(shake_input_1, B_2, PARAMS_N, begin_pack, PARAMS_N, begin_reset);
            shake_gen_S_E(S_2, E_2, outlen, seed_SE, start1, end1, start2, end2, begin_shake_gen);
            vector_matrix_mul(B_1, S_1, A_1, A_2, E_1, seed_A_separated, pk_b, pregen, vec_mat_len, use_A, begin_mat_mul);
            absorb_block_write(G2in, shake_input_2, 0, 150, reset, begin_absorb_block,
                ct+600*(i-2), 600, begin_read_input);
            write_reset_mod(V+8*(i-9), B_2, PARAMS_NBAR, begin_add_write_reset);
        }
    }

    //Encode mu and add it to V
    Encode: for(i = 0; i < 8; i++)
    {
        temp = mu[i];
        Endode_1: for(j = 0; j < 8; j++)
        {
            #pragma HLS PIPELINE
            B_2[8*i+j] = (((temp & mask) << 13) + V[8*i+j]) & ((1<<PARAMS_LOGQ)-1);
            temp >>= PARAMS_EXTRACTED_BITS;
        }
    }

    //Pack and then write C into c_2
    pack_reset(shake_input_1, B_2, PARAMS_NBAR*PARAMS_NBAR, 1, 0, 0);
    read_input(ct+4800, shake_input_1, 60, 1);

    //Hash c_2 and k, c_1 is already hashed
    Set_shake_input_3: for(i = 0; i < 8; i++)
    {
        #pragma HLS PIPELINE
        shake_input_1[60+i] = ks[i];
    }
    
    shake_input_1[68] = 0x1F00;
    shake_input_1[69] = 0x0000;
    shake_input_1[70] = 0x0000;
    shake_input_1[71] = 0x0000;
    absorb_block_write(G2in, shake_input_1, 16, 18, 0, 1, ct+600, 0, 0);

    //Write the result of the hashing into ss
    Set_ss: for(i = 0; i < 8; i++)
    {
        #pragma HLS PIPELINE
        ss[i] = G2in[i];
    }
    
}

void encode_add(uint16_t *out, uint16_t *in, uint16_t mu, uint8_t begin)
{
    #pragma HLS INLINE off
    uint8_t i;
    L1: for(i = 0; i < 8; i++)
    {
        #pragma HLS PIPELINE
        out[i] = (((mu & 0x3) << 13) + in[i]) & ((1<<PARAMS_LOGQ)-1);
        mu >>= 2;
    }
}

//Combines the two functions absorb_block and read_input
void absorb_block_write(uint16_t *output, uint16_t *input, uint16_t outlen,
    uint16_t inlen, uint8_t reset, uint8_t begin_absorb,
    uint16_t *ct, uint16_t write_len, uint8_t begin_write)
{
    absorb_block(output, input, outlen, inlen, reset, begin_absorb);
    read_input(ct, input, write_len, begin_write);
}

//Combines the two functions frodo_pack_16 and reset_vector
void pack_reset(uint16_t *out, uint16_t *in, uint16_t inlen, uint8_t begin_pack, 
    uint16_t n, uint8_t begin_reset)
{
    frodo_pack_16(out, in, inlen, begin_pack);
    reset_vector(in, n, begin_reset);
}

//Resets a vector of length n if begin is 1
void reset_vector(uint16_t *vec, uint16_t n, uint8_t begin)
{
    #pragma HLS INLINE off
    uint16_t i;
    if(begin)
    {
        L1: for(i = 0; i < n; i++)
        {
            vec[i] = 0;
        }
    }
}

void write_reset_mod(uint16_t *out, uint16_t *in, uint16_t n, uint8_t begin)
{
    int i;
    if(begin)
    {
        for(i = 0; i < n; i++)
        {
            #pragma HLS PIPELINE
            out[i] = in[i];
            in[i] = 0;
        }
    }
}

/*
    Implements the matrix multiplications.
    Input:  uint16_t *S: One row of S'
            uint16_t *A_1: Will hold one row of A or B
            uint16_t *A_2: Will hold one row of A or B
            uint16_t *E: One row of E' or E''
            uint16_t *seed_A_separated: seed_A
            uint16_t *pk: public key
            uint8_t begin: Decides if function the first tow needs to be pregenerated
            uint16_t n: Amount of columns of the right matrix
            uint8_t use_A: Decides whether A or B is used on the right side
            uint8_t begin: Decides if the function can begin execution
    Output: uint16_t *output_vec: One row of the resulting matrix
*/
void vector_matrix_mul(uint16_t *output_vec, uint16_t *S, uint16_t *A_1,  
    uint16_t *A_2, uint16_t *E, uint16_t *seed_A_separated, uint16_t *pk, 
    uint8_t pregen, uint16_t n, uint8_t use_A, uint8_t begin)
{
    int k;
    uint16_t s, offset = 0, e;

    if(begin)
    {
        //Only pregenerate the first row the first time the function is called
        if(pregen)
        {
            //Generate A using shake128_10240...
            if(use_A)
            {
                seed_A_separated[0] = 0;
                shake128_10240(A_2, seed_A_separated);
            }
            //...or generate B using frodo_unpack_8
            else
            {
                frodo_unpack_8(A_2, pk+offset, 16);
            }
        }

        //Multiplication of vector on the left with matrix on the right
        L1: for(k = 0; k < PARAMS_N; k++)
        {
            //Set seedA for the next row unless the last iteration is reached, 
            //then set seedA for the first row again
            if(k == PARAMS_N-1)
                seed_A_separated[0] = 0;
            else
                seed_A_separated[0] = k+1;

            s = S[k];

            if((k & 0x1) == 0)
            {
                if(use_A)
                {
                    shake128_10240(A_1, seed_A_separated);
                    scalar_vector_mul(output_vec, A_2, s, n, k, E);
                }
                else
                {
                    frodo_unpack_8(A_1, pk+offset+8, 8);
                    scalar_vector_mul(output_vec, A_2, s, n, k, E);
                    offset += 15;
                }
            }
            else
            {
                if(use_A)
                {
                    shake128_10240(A_2, seed_A_separated);
                    scalar_vector_mul(output_vec, A_1, s, n, k, E);  
                }
                else
                {
                    frodo_unpack_8(A_2, pk+offset, 16);
                    scalar_vector_mul(output_vec, A_1, s, n, k, E);
                }   
            }

            //For the last iteration, reset the offset of the pk to generate the 
            //first row of B again
            if(k == PARAMS_N-2)
                offset = 0;
        }
    }
}

uint16_t reg(uint16_t in)
{
    #pragma HLS PIPELINE II=1
    #pragma HLS INTERFACE ap_ctrl_none register port=return
    #pragma HLS INLINE off
    return in;
}

/*
    Scalar-vector multiplication and addition of error terms E in the start
    Input:  uint16_t *input_vec: Vector on the right to be multiplied
            uint16_t scalar: Scalar to multiply the vector with
            uint16_t n: Amount of elements in the vector
            uint16_t index: Row index of the vector
            uint16_t *E: Error terms to be added at the start
    Output: uint16_t *output_vec: Output vector
*/
void scalar_vector_mul(uint16_t *output_vec, uint16_t *input_vec, 
    uint16_t scalar, uint16_t n, uint16_t index, uint16_t *E)
{
    #pragma HLS INLINE off
    uint16_t i, temp, e, x;
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
        //printf("%04X\n", temp);
        temp = reg(temp);
        x = temp + output_vec[i];
        //In the next clock cycle add result to output vector
        output_vec[i] += temp;
    }
}

void reset(uint16_t *B, uint16_t n)
{
	#pragma HLS INLINE off
    int i;
    L1: for(i = 0; i < n; i+=2)
    {
        B[i+0] = 0;
        B[i+1] = 0;
    }
}

void read_input(uint16_t *out, uint16_t *in, uint16_t len, uint8_t begin)
{
    #pragma HLS INLINE off
    uint16_t i;
    if(begin)
    {
        L1: for(i = 0; i < len; i++)
        {
            #pragma HLS PIPELINE
            out[i] = in[i];
        }
    }
}