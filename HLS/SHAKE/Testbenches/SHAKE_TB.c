#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "fips202.h"
#include "ap_cint.h"

int main()
{
	FILE *fp;
	fp = fopen("shakevalues.txt", "a+");
	int check = 0, errors = 0, passed = 0, iteration = 1, i;
	uint16_t inlen, outlen;
	uint16_t output[11000], shake_out[11000];
	uint16_t input[4868];

	while(!feof(fp)){
		iteration++;
		fscanf(fp, "Inlen = %hu\n", &inlen);
		for(i = 0; i < 4868; i++){
			input[i] = 0;
		}
		for(i = 0; i < 11000; i++){
			output[i] = 0;
			shake_out[i] = 0;
		}

		fscanf(fp, "Shake-Input = ");
		for(i = 0; i < inlen; i++)
		{
			fscanf(fp, "%04hX", &input[i]);
		}
		fscanf(fp, "\n");

		fscanf(fp, "Outlen = %hu\n", &outlen);

		fscanf(fp, "Shake-Output = ");
		for(i = 0; i<outlen/2; i++)
		{
			fscanf(fp, "%04hX", &output[i]);
		}
		fscanf(fp, "\n");

		shake(shake_out, outlen, input, inlen);
		
		check = memcmp(&shake_out, &output, outlen);
		
		if(check == 0){
			passed++;
		}
		else{
			printf("Failed in Iteration: %d\n", iteration);
			errors++;
		}
	}
	fclose(fp);

	printf("==========Testing Done==========\n");
	printf("Passed: %d\n", passed);
	printf("Failed: %d\n", errors);
	if(errors == 0){
		printf("Tests passed!\n");
		return 0;
	}
	else{
		printf("Tests failed!\n");
		return 1;
	}
}
