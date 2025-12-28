#!/usr/bin/env -S tcc -run
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define  DOUBLE_QUOTE            0
#define  SINGLE_QUOTE            1
#define  BACK_QUOTE              2
#define  OPENING_PARENTHESIS     0
#define  CLOSING_PARENTHESIS     1
#define  OPENING_SQUARE_BRACKET  2
#define  CLOSING_SQUARE_BRACKET  3
#define  OPENING_CURLY_BRACE     4
#define  CLOSING_CURLY_BRACE     5

int32_t  main (void)
{
    int32_t   index                            = 0;
    uint32_t  input                            = '\0';
    uint32_t  line                             = 1;
    uint8_t   pairs[]                          = { 0, 0, 0, 0, 0, 0 };
    uint8_t   quotes[]                         = { 0, 0, 0 };

    while (!feof (stdin))
    {
        input                                  = fgetc (stdin);
        switch (input)
        {
            case 0x22: // "
                quotes[DOUBLE_QUOTE]           = quotes[DOUBLE_QUOTE]       + 1;
                break;

            case 0x27: // '
                quotes[SINGLE_QUOTE]           = quotes[SINGLE_QUOTE]       + 1;
                break;

            case 0x60: // `
                quotes[BACK_QUOTE]             = quotes[BACK_QUOTE]         + 1;
                break;

            case 0x28: // (
                pairs[OPENING_PARENTHESIS]     = pairs[OPENING_PARENTHESIS] + 1;
                break;

            case 0x29: // )
                pairs[CLOSING_PARENTHESIS]     = pairs[CLOSING_PARENTHESIS] + 1;
                break;

            case 0x5B: // [
                pairs[OPENING_SQUARE_BRACKET]  = pairs[OPENING_PARENTHESIS] + 1;
                break;

            case 0x5D: // ]
                pairs[CLOSING_SQUARE_BRACKET]  = pairs[CLOSING_PARENTHESIS] + 1;
                break;

            case 0x7B: // {
                pairs[OPENING_CURLY_BRACE]     = pairs[OPENING_CURLY_BRACE] + 1;
                break;

            case 0x7D: // }
                pairs[CLOSING_CURLY_BRACE]     = pairs[CLOSING_CURLY_BRACE] + 1;
                break;
        }

        if (input                             != -1)
        {
            fprintf (stdout, "%.2hhx ", input);
        }

        if (input                             == '\n')
        {

            for (index = 0; index < 3; index++)
            {
                if ((quotes[index] % 2)       != 0)
                {
                    fprintf (stderr, "[ERROR] line %d: ", line);

                    if (index                 == DOUBLE_QUOTE)
                    {
                        fprintf (stderr, "Unmatched '\"' in input\n");
                    }

                    if (index                 == SINGLE_QUOTE)
                    {
                        fprintf (stderr, "Unmatched '\'' in input\n");
                    }

                    if (index                 == BACK_QUOTE)
                    {
                        fprintf (stderr, "Unmatched '`' in input\n");
                    }
                }
            }
            line                               = line                       + 1;
        }
    }

    for (index = 0; index < 6; index = index + 2)
    {
        if (pairs[index]                      != pairs[index+1])
        {
            fprintf (stderr, "[ERROR] ");
            if (index                         == OPENING_PARENTHESIS)
            {
                fprintf (stderr, "'(' opened with no closing ')' in input\n");
            }

            if (index                         == OPENING_SQUARE_BRACKET)
            {
                fprintf (stderr, "'[' opened with no closing ']' in input\n");
            }

            if (index                         == OPENING_CURLY_BRACE)
            {
                fprintf (stderr, "'{' opened with no closing '}' in input\n");
            }
        }
    }

    return (0);
}
