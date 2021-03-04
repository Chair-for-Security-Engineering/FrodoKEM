#include "fips202.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "ap_cint.h"

// CDF table
static const uint16_t CDF_TABLE[13] = {4643, 13363, 20579, 25843, 29227, 31145, 32103, 32525, 32689, 32745, 32762, 32766, 32767};
static const uint16_t CDF_TABLE_LEN = 13;

uint16_t frodo_sample(uint16_t in);