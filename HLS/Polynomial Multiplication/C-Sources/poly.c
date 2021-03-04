#include "poly.h"
#include <stdint.h>
#include "ap_cint.h"
#include <string.h>

uint11 r[NTRU_N], b[NTRU_N];

/*
	Test function for the polynomial multiplication, needed to get the test values
	into the local arrays.
*/
void poly_mul_test(poly *R, poly *a, poly *B)
{
	#pragma HLS ARRAY_PARTITION variable=r complete dim=1
	#pragma HLS ARRAY_PARTITION variable=b complete dim=1
	int i;

	L1: for(i = 0; i < NTRU_N; i++)
	{
		#pragma HLS PIPELINE
		b[i] = B->coeffs[i];
	}
	poly_mul(a);
	L2: for(i = 0; i < NTRU_N; i++)
	{
		#pragma HLS PIPELINE
		R->coeffs[i] = r[i];
	}
}

/*
	Polynomial Multiplication. Input poly b and output poly r are fully partitioned,
	defined as global arrays. 
*/
void poly_mul(poly *a)
{
    uint11 temp, a_k, b_i;
    int i, k;

    //Reset the output poly
    Reset: for(i = 0; i < NTRU_N; i++)
    {
    	#pragma HLS UNROLL
        r[i] = 0;
    }

    Outer_Loop: for(k = 0; k < NTRU_N; k++)
    {
    	#pragma HLS PIPELINE
    	//Load current coefficient of a into local variable
    	a_k = a->coeffs[k];
        L1: for(i = 0; i < NTRU_N; i++)
        {
        	#pragma HLS UNROLL
        	//Check if a_k is 1 -> b_i = b[i]
        	//				 -1 -> b_i = -b[i]
        	//				  0 -> b_i = 0
        	if(a_k == 1)
        		b_i = b[i];
        	else if(a_k == NTRU_Q-1)
        		b_i = -b[i];
        	else
        		b_i = 0;
        	//Add b_i to r[i]
        	r[i] += b_i;
        }

        //Rotate b by one element
        temp = b[NTRU_N-1];
        Rotate: for(i = NTRU_N-1; i > 0; i--)
        {
        	#pragma HLS UNROLL
            b[i] = b[i-1];
        }
        b[0] = temp;
    }
}