#include "poly.h"
#include "params.h"
#include <stdio.h>
#include <string.h>

int main()
{
	FILE *fp;
	fp = fopen("polymulvalues1.txt", "a+");

	poly a, r, result, b;
	int k, control;
	int check = 0, errors = 0, passed = 0;

	while(!feof(fp))
	{
		fscanf(fp, "a = ");
		for(k = 0; k < NTRU_N; k++)
		{
			fscanf(fp, "%04hX", &a.coeffs[k]);
		}
		fscanf(fp, "\n");
		fscanf(fp, "b = ");
		for(k = 0; k < NTRU_N; k++)
		{
			fscanf(fp, "%04hX", &b.coeffs[k]);
		}
		fscanf(fp, "\n");
		fscanf(fp, "r = ");
		for(k = 0; k < NTRU_N; k++)
		{
			fscanf(fp, "%04hX", &r.coeffs[k]);
		}
		fscanf(fp, "\n");
		poly_mul_test(&result, &a, &b);
		check = memcmp(&result, &r, 2*NTRU_N);
		if(check == 0){
			passed++;
		}
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
