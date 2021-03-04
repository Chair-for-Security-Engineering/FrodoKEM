#include "frodo_dec.h"

int main()
{
	FILE *fp;
	fp = fopen("frodo_dec_values.txt", "a+");
	uint16_t ss[8], ss_r[8];
	uint16_t ct[4860], sk[9944];

	int check1 = 0, check2 = 0, errors = 0, passed = 0, i = 0, iteration = 0;

	while(!feof(fp))
	{
		fscanf(fp, "ct = ");
		for(i = 0; i < 4860; i++)
		{
			fscanf(fp, "%04hX", &ct[i]);
		}
		fscanf(fp, "\n");

		fscanf(fp, "sk = ");
		for(i = 0; i < 9944; i++)
		{
			fscanf(fp, "%04hX", &sk[i]);
		}
		fscanf(fp, "\n");

		fscanf(fp, "ss = ");
		for(i = 0; i < 8; i++)
		{
			fscanf(fp, "%04hX ", &ss[i]);
		}
		fscanf(fp, "\n");	
		
		frodo_dec(ss_r, ct, sk);

		check1 = memcmp(&ss_r, &ss, 16);
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
