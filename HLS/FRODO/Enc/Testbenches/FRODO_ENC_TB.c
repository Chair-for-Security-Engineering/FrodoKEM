#include "frodo_enc.h"

int main()
{
	FILE *fp;
	fp = fopen("frodo_enc_values.txt", "a+");
	uint16_t ss[8], ss_r[8];
	uint16_t ct[4860], ct_r[4860], pk[4808], mu_in[8];

	int check1 = 0, check2 = 0, errors = 0, passed = 0, i = 0, iteration = 0;

	while(!feof(fp))
	{
		fscanf(fp, "mu = ");
		for(i = 0; i < 8; i++)
		{
			fscanf(fp, "%04hX ", &mu_in[i]);
		}
		fscanf(fp, "\n");
		
		fscanf(fp, "pk = ");
		for(i = 0; i < 4808; i++)
		{
			fscanf(fp, "%04hX", &pk[i]);
		}
		fscanf(fp, "\n");

		fscanf(fp, "ct = ");
		for(i = 0; i < 4860; i++)
		{
			fscanf(fp, "%04hX", &ct_r[i]);
		}
		fscanf(fp, "\n");

		fscanf(fp, "ss = ");
		for(i = 0; i < 8; i++)
		{
			fscanf(fp, "%04hX", &ss_r[i]);
		}
		fscanf(fp, "\n");	
		
		frodo_enc(ct, ss, mu_in, pk);
		//printf("%02X\n", sk_result[0]);
		check1 = memcmp(&ct, &ct_r, 9720);
		check2 = memcmp(&ss, &ss_r, 16);
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