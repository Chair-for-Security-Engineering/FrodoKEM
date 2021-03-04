#include "sample.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

int main()
{
	FILE *fp;
	fp = fopen("frodo_sample_n_values.txt", "a+");
	uint16_t input[5120];
	uint16_t r[5120], result[5120];
	int n;
	int check = 0, errors = 0, passed = 0, i = 0, iteration = 0;

	while(!feof(fp))
	{
		for(i = 0; i < 5120; i++)
		{
			input[i] = 0;
			r[i] = 0;
			result[i] = 0;
		}
		fscanf(fp, "N = %d\n", &n);
		fscanf(fp, "Input = ");
		for(i = 0; i < n; i++)
		{
			fscanf(fp, "%04hX ", &input[i]);
		}
		fscanf(fp, "\n");
		fscanf(fp, "Output = ");
		for(i = 0; i < n; i++)
		{
			fscanf(fp, "%04hX ", &result[i]);
		}
		fscanf(fp, "\n");
		frodo_sample_n(r, input, n);
		check = memcmp(&result, &r, 2*n);
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
