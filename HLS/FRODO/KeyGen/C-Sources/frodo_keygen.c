#include "frodo_keygen.h"

/*
    Perform the key generation of FrodoKEM
    Input  : uint16_t *randomness  : Array containing true randomness
    Output : uint16_t *pk          : Array containing the public key
             uint16_t *sk          : Array containing the secret key
*/
void frodo_keygen(uint16_t pk[4812], uint16_t sk[9944], uint16_t randomness[24])
{
    #pragma HLS INTERFACE ap_memory depth=4812 port=pk
    #pragma HLS INTERFACE ap_memory depth=19888 port=sk
    #pragma HLS INTERFACE ap_memory depth=24 port=randomness
	uint16_t *pk_seedA = &pk[0];
    uint16_t *pk_b = &pk[BYTES_SEED_A/2];
    uint16_t *sk_s = &sk[0];
    uint16_t *sk_pk = &sk[CRYPTO_BYTES/2];
    uint16_t *sk_S = &sk[(CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES)/2];
    uint16_t *sk_pkh = &sk[(CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES + 2*PARAMS_N*PARAMS_NBAR)/2];
    uint16_t *randomness_s = &randomness[0];
    uint16_t *randomness_seedSE = &randomness[CRYPTO_BYTES/2];
    uint16_t *randomness_z = &randomness[CRYPTO_BYTES];

    uint16_t B[PARAMS_N*PARAMS_NBAR];
    #pragma HLS INTERFACE ap_bus depth=5120 port=B
    #pragma HLS RESOURCE variable=B core=RAM_2P_LUTRAM

    uint16_t S_1[PARAMS_N], S_2[PARAMS_N];
    #pragma HLS INTERFACE ap_bus depth=640 port=S_1
    #pragma HLS INTERFACE ap_bus depth=640 port=S_2

    uint16_t X_1[PARAMS_N], X_2[PARAMS_N];

    uint16_t A_1[672], A_2[672];

    uint16_t seed_A[9];

    uint16_t seed_SE[12];
	#pragma HLS RESOURCE variable=seed_SE core=RAM_2P_LUTRAM

    uint8_t begin_write_sk, begin_matrix_mul, begin_add, begin_pack, pregen, 
        begin_absorb;
    int i, j, k;
    uint16_t sum, start_word = 0, reset, start_block = 0, sk_offset;

    //Copy z into X_1 and apply the padding...
    for(i = 0; i < 8; i++)
    {
        X_1[i] = randomness_z[i];
    }
    X_1[8] = 0x1F00;
    X_1[9] = 0x0000;
    X_1[10] = 0x0000;
    X_1[11] = 0x0000;

    //...then hash X_1 to generate seed_A
    absorb_block(seed_A+1, X_1, BYTES_SEED_A, 3, 1, 1);

    //Copy seedSE and apply padding
    seed_SE[0] = (0x5F << 8) | ((randomness_seedSE[0] >> 8) & 0xFF);
    for(i = 0; i < 7; i++)
    {
        seed_SE[i+1] = ((randomness_seedSE[i] & 0xFF) << 8) | ((randomness_seedSE[i+1] >> 8) & 0xFF); 
    }
    seed_SE[8] = ((randomness_seedSE[7] & 0xFF) << 8) | 0x1F;
    seed_SE[9] = 0x0000;
    seed_SE[10] = 0x0000;
    seed_SE[11] = 0x0000;

    //Write seedA into pk, sk, and X_1
    for(i = 0; i < 8; i++)
    {
        pk_seedA[i] = seed_A[i+1];
        sk_pk[i] = seed_A[i+1];
        X_1[i] = seed_A[i+1];
        seed_A[i+1] = ROL(16, seed_A[i+1], 8);
    }

    //Hash X_1 (seedA) as the first part of hashing the public key, do not 
    //generate output yet as b still has to be absorbed first
    absorb_block(seed_A, X_1, 0, 2, 1, 1);

    //Matrix Multiplication: Generate S and A on the fly and multiply them
    //1st Iteration : Generate the first row of S
    //2nd+ Iteration : Generate the next row of S and multiply the previous with A
    //Last Iteration : Finish multiplication, generate the first row of E for later
    Mat_Mul: for(i = 0; i < PARAMS_NBAR+1; i++)
    {
        if(i == PARAMS_NBAR)
            begin_write_sk = 0;
        else
            begin_write_sk = 1;

        if(i == 0)
        {
            reset = 1;
            begin_matrix_mul = 0;
        }
        else
        {
            reset = 0;
            begin_matrix_mul = 1;
        }

        if(i == 1)
            pregen = 1;
        else
            pregen = 0;

        if((i & 0x1) == 0)
        {
            gen_S_sample_write(S_2, seed_SE, 160, reset, sk_S+i*PARAMS_N, 
                begin_write_sk);
            vector_matrix_mul(B, A_1, A_2, S_1, seed_A, i-1, pregen, 
                begin_matrix_mul);
        }
        else
        {
            gen_S_sample_write(S_1, seed_SE, 160, reset, sk_S+i*PARAMS_N, 
                begin_write_sk);
            vector_matrix_mul(B, A_1, A_2, S_2, seed_A, i-1, pregen, 
                begin_matrix_mul);
        }
    }

    //Generate E on the fly and add it to B, pack B and hash it
    //1st Iteration : Only add_E is executed and the next line of E is generated
    //2nd Iteration : Addition and generation, packing of the previous row into pk, sk and X
    //                for the hashing
    //3rd Iteration : Same as above, start hashing from X
    Add_E: for(i = 0; i < PARAMS_NBAR+1; i++)
    {
        if(i == 0)
            begin_pack = 0;
        else
            begin_pack = 1;

        if(i == PARAMS_NBAR)
            begin_add = 0;
        else
            begin_add = 1;

        if(i < 2)
            begin_absorb = 0;
        else
            begin_absorb = 1;

        sk_offset = 600*(i-1)+8;

        if((i & 0x1) == 0)
        {
            add_E(A_2, B+i*PARAMS_N, S_2, begin_add);
            gen_S_sample_write(S_1, seed_SE, 160, 0, sk_S+i*PARAMS_N, 0);
            frodo_pack_16(pk_b+600*(i-1), sk_pk+sk_offset, X_1, A_1, PARAMS_N, 
                begin_pack);
            absorb_block(seed_A, X_2, 0, 150, 0, begin_absorb);
        }
        else
        {
            add_E(A_1, B+i*PARAMS_N, S_1, begin_add);
            gen_S_sample_write(S_2, seed_SE, 160, 0, sk_S+i*PARAMS_N, 0);
            frodo_pack_16(pk_b+600*(i-1), sk_pk+sk_offset, X_2, A_2, PARAMS_N, 
                begin_pack);
            absorb_block(seed_A, X_1, 0, 150, 0, begin_absorb);
        }
    }

    //Apply the padding for the final hash
    X_1[600] = 0x1F00;
    X_1[601] = 0x0000;
    X_1[602] = 0x0000;
    X_1[603] = 0x0000;

    absorb_block(seed_A, X_1, 16, 151, 0, 1);

    //Write s into sk
    for(i = 0; i < CRYPTO_BYTES/2; i++)
    {
        sk_s[i] = randomness_s[i];
    }

    //Write pkh into sk
    for(i = 0; i < 8; i++)
    {
        sk_pkh[i] = seed_A[i];
    }
}

/*
    Adds 2 vectors of length PARAMS_N element-wise and writes them into an 
    output vector
    Input:  uint16_t *in1: First input vector
            uint16_t *in2: Second input vector
            uint8_t begin: Adding only starts when begin = 1
    Output: uint16_t *out: Output vector
*/
void add_E(uint16_t *out, uint16_t *in1, uint16_t *in2, uint8_t begin)
{
    #pragma HLS INLINE off
    uint16_t i;
    if(begin)
    {
        L1: for(i = 0; i < PARAMS_N; i++)
        {
            #pragma HLS PIPELINE
            out[i] = in1[i] + in2[i];
        }
    }
}

/*
    Function to write rows of S into the secret key. To match the test vectors from 
    the reference implementation, each entry from S has to be rotated by 8 bits
    Input:  uint16_t *S: One row of S
            uint8_t begin: Writing only starts when begin = 1
    Output: uint16_t *sk: Pointer to the right place in the secret key
*/
void write_sk_16(uint16_t *sk, uint16_t *S, uint8_t begin)
{
    #pragma HLS INLINE off
    uint16_t i;
    if(begin)
    {
        L1: for(i = 0; i < PARAMS_N; i++)
        {
            #pragma HLS PIPELINE
            sk[i] = ROL(16, S[i], 8);
        }
    }
}

/*
    Multiplies one column of S with matrix A
    Input:  uint16_t *A_1: Array to hold one row of A
            uint16_t *A_2: Array to hold one row of A
            uint16_t *S: One column of S
            uint16_t *seed_A: Input to the hash function
            uint8_t offset: Offset for the addesses of B
            uint8_t pregen: Pregeneration only happens when pregen = 1
            uint8_t begin: Multiplication only happens when begin = 1
    Output: uint16_t *B: Resulting Matrix
*/
void vector_matrix_mul(uint16_t *B, uint16_t *A_1, uint16_t *A_2, uint16_t *S, 
    uint16_t *seed_A, uint8_t offset, uint8_t pregen, uint8_t begin)
{
    #pragma HLS INLINE off
    uint16_t i, sum, k;

    if(begin)
    { 
        if(pregen)
        {
            seed_A[0] = 0;
            shake128_10240(A_2, seed_A);            
        }

        for(i = 0; i < PARAMS_N; i++)
        {
            //Set seed_A for the generation of row 0 if in the last iteration...
            if(i == PARAMS_N-1)
                seed_A[0] = 0;
            //...or for the generation of the next row.
            else
                seed_A[0] = i+1;

            //Multiply one row of A with S, and generate the next row of A in parallel
            if((i & 0x1) == 0)
            {
                shake128_10240(A_1, seed_A);
                sum = vector_vector_mul(A_2, S);
            }
            else
            {
                shake128_10240(A_2, seed_A);
                sum = vector_vector_mul(A_1, S);               
            }
            B[i*PARAMS_NBAR+offset] = sum;
        }
    }
}

/*
    Multiplies two vectors
    Input:  uint16_t *a: First vector
            uint16_t *s: Second vector
    Output: uint16_t sum: Result of the vector-vector multiplication
*/
uint16_t vector_vector_mul(uint16_t *a, uint16_t *s)
{
    #pragma HLS INLINE off
    uint16_t i, sum = 0;
    L1: for(i = 0; i < PARAMS_N; i++)
    {
        #pragma HLS PIPELINE
        sum += a[i] * s[i];
    }
    return sum;
}