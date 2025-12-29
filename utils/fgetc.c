#!/usr/bin/env -S tcc -run
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int32_t  main (void)
{
	fprintf (stdout, "%c\n", fgetc (stdin));
	return (0);
}
