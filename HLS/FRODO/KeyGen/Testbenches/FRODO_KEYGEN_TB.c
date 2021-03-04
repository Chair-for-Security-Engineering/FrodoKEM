#include "frodo_keygen.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

int main()
{
	FILE *fp;
	fp = fopen("frodo_keygen_values.txt", "a+");
	uint16_t sk[9944], sk_result[9944];
	uint16_t randomness[24], pk[4812], pk_result[4812];

	int check1 = 0, check2 = 0, errors = 0, passed = 0, i = 0, iteration = 0, index = 0;

	while(!feof(fp))
	{
		fscanf(fp, "Randomness = ");
		for(i = 0; i < 24; i++)
		{
			fscanf(fp, "%04hX", &randomness[i]);
		}
		fscanf(fp, "\n");
		frodo_keygen(pk_result, sk_result, randomness);

		fscanf(fp, "Seed_A = ");
		for(i = 0; i < 8; i++)
		{
			fscanf(fp, "%04hX ", &pk[index]);
			index++;
		}
		fscanf(fp, "\n");

		fscanf(fp, "b = ");
		for(i = 0; i < 4800; i++)
		{
			fscanf(fp, "%04hX ", &pk[index]);
			index++;
		}
		fscanf(fp, "\n");
		check1 = memcmp(&pk_result, &pk, 9616);

		index = 0;
		fscanf(fp, "s = ");
		for(i = 0; i < 8; i++)
		{
			fscanf(fp, "%04hX ", &sk[index]);
			index++;
		}
		fscanf(fp, "\n");

		fscanf(fp, "pk = ");
		for(i = 0; i < 4808; i++)
		{
			fscanf(fp, "%04hX ", &sk[index]);
			index++;
		}
		fscanf(fp, "\n");

		fscanf(fp, "S = ");
		for(i = 0; i < 5120; i++)
		{
			fscanf(fp, "%04hX ", &sk[index]);
			index++;
		}
		fscanf(fp, "\n");

		fscanf(fp, "pkh = ");
		for(i = 0; i < 8; i++)
		{
			fscanf(fp, "%04hX ", &sk[index]);
			index++;
		}
		fscanf(fp, "\n");

		check2 = memcmp(&sk_result, &sk, 19888);
		if((check1 == 0) && (check2 == 0))
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
