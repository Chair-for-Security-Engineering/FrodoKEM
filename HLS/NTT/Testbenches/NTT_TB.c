#include "reduce.h"
#include "params.h"
#include "poly.h"
#include "ntt.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main()
{
	FILE *fp;
	fp = fopen("ntt_values10.txt", "a+");
	poly a, omega, r, result;
	int check = 0, errors = 0, passed = 0, i = 0, iteration = 0;

	while(!feof(fp))
	{
		fscanf(fp, "A = \n");
		for(i = 0; i < NEWHOPE_N; i++)
		{
			fscanf(fp, "%04hX", &a.coeffs[i]);
		}
		fscanf(fp, "\n");
		fscanf(fp, "Omega = \n");
		for(i = 0; i < NEWHOPE_N; i++)
		{
			fscanf(fp, "%04hX", &omega.coeffs[i]);
		}
		fscanf(fp, "\n");
		fscanf(fp, "Result = \n");
		for(i = 0; i < NEWHOPE_N; i++)
		{
			fscanf(fp, "%04hX", &result.coeffs[i]);
		}
		fscanf(fp, "\n");
		ntt(&a, &omega);
		check = memcmp(&result, &a, 2048);
		if(check == 0)
			passed++;
		else
			errors++;
	}
	fclose(fp);
	printf("==========Tesing Done==========\n");
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
