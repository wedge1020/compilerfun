//
// codegen_v32.c - output assembly for our chosen platform (v32)
//
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
//
// Pre-processor directives
//
#include "defs.h"
#include "data.h"
#include "decl.h"

#define  AVAILABLE  1
#define  ALLOCATED  0

////////////////////////////////////////////////////////////////////////////////////////
//
// registers
//
static int   free_registers[11];
static char *register_list[11]  = { "R0", "R1", "R2", "R3",
                                    "R4", "R5", "R6", "R7",
                                    "R8", "R9", "R10"       };

////////////////////////////////////////////////////////////////////////////////////////
//
// registers_clear(): mark all registers as available
//
void registers_clear (void)
{
    int  index                  = 0;

    ////////////////////////////////////////////////////////////////////////////////////
    //
    // free_registers[] marks which registers are in use; a 1 in the array element
    // indicates it is free for use
    //
    for (index                  = 0;
         index                 <  11;
         index                  = index + 1)
    {
        free_registers[index]   = AVAILABLE;
    }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// allocate_register(): allocate an available register. Return value is the number of
//                      the register. Bail out if there are no available registers.
//
static int allocate_register (void)
{
    int  index                     = 0;

    for (index                     = 0;
         index                    <  11;
         index                     = index + 1)
    {
        ////////////////////////////////////////////////////////////////////////////////
        //
        // Check if the entry currently being iterated is AVAILABLE, if it is, then
        // ALLOCATE and return it
        //
        if (free_registers[index] == AVAILABLE)
        {
            free_registers[index]  = ALLOCATED;
            return (index);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    //
    // If we were unsuccessful in allocating a register, fail with an error
    //
    fatal ("Out of registers");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// deallocate_register(): mark the indicated register as AVAILABLE, provided it is
//                        ALLOCATED.
//
static void deallocate_register (int the_register)
{
    if (free_registers[the_register] != 0)
    {
        fatald ("Error trying to free register", the_register);
    }
    free_registers[the_register]      = AVAILABLE;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_preamble(): generate the initial assembly output
//
void codegen_preamble ()
{
  registers_clear ();
  fputs ("; program start section\n"
         "  call __global_scope_initialization\n"
         "  call __function_main\n\n"
         "; location of global variables\n"
         "  %define global_malloc_start_address 0\n"
         "  %define global_malloc_end_address   1\n"
         "  %define global_malloc_first_block   2\n\n"
         "__global_scope_initialization:\n"
         "  push  BP\n"
         "  mov   BP, SP\n"
         "  mov   R0, 1048576\n"
         "  mov   [global_malloc_start_address], R0\n"
         "  mov   R0, 3145727\n"
         "  mov   [global_malloc_end_address],   R0\n"
         "  mov   R0, -1\n"
         "  mov   [global_malloc_first_block],   R0\n"
         "  mov   SP, BP\n"
         "  pop   BP\n"
         "  ret\n\n", Outfile);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_function_preamble(): generate a standard function preamble; establish
//                              the label, set up the local stack
//
void  codegen_function_preamble (char *name)
{
    fprintf (Outfile, "__function_%s:\n"
                      "  push  BP\n"
                      "  mov   BP, SP\n", name);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_function_postamble(): generate a standard function postamble; restore the
//                               previous stack, return
//
void  codegen_function_postamble ()
{
    fputs ("  mov   SP, BP\n"
           "  pop   BP\n"
           "  ret\n\n", Outfile);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_load_integer(): load an integer literal into an available register;
//                         return the register involved in the transaction
//
int codegen_load_integer (int value)
{
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // obtain an available register for this operation 
    //
    int  dstreg  = allocate_register ();

    ////////////////////////////////////////////////////////////////////////////////////
    //
    // generate the assembly code to perform this operation
    //
    fprintf (Outfile, "    MOV   %s, %d\n", register_list[dstreg], value);

    return (dstreg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_load_glob(): load a value from a variable into a register; return the
//                      number of the register
//
int   cgloadglob (char *identifier)
{
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // obtain an available register for this operation 
    //
    int  dstreg  = allocate_register ();

    ////////////////////////////////////////////////////////////////////////////////////
    //
    // generate the assembly code to perform this operation
    //
    fprintf (Outfile, "    MOV   %s,   [%s]\n", register_list[dstreg], identifier);

    return (dstreg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_add(): Add two registers together and return the number of the register
// with the result
//
int  codegen_add (int srcreg, int dstreg)
{
    fprintf (Outfile, "    IADD  %s,   %s\n", reglist[dstreg], reglist[srcreg]);
    deallocate_register (srcreg);
    return (dstreg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_sub(): Subtract the second register from the first and
// return the number of the register with the result
//
int  codegen_sub (int srcreg, int dstreg)
{
    fprintf (Outfile, "    ISUB  %s,   %s\n", reglist[dstreg], reglist[srcreg]);
    deallocate_register (srcreg);
    return (dstreg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_mul(): Multiply two registers together and return the number
// of the register with the result
int  codegen_mul (int srcreg, int dstreg)
{
    fprintf (Outfile, "    IMUL  %s,   %s\n", reglist[dstreg], reglist[srcreg]);
    deallocate_register (srcreg);
    return (dstreg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_div(): Divide the first register by the second and return the
// number of the register with the result
//
int  codegen_div (int srcreg, int dstreg)
{
    fprintf (Outfile, "    IDIV  %s,   %s\n", reglist[dstreg], reglist[srcreg]);
    deallocate_register (srcreg);
    return (dstreg);
}

// Call printint() with the given register
void cgprintint(int r) {
  fprintf(Outfile, "\tmovq\t%s, %%rdi\n", reglist[r]);
  fprintf(Outfile, "\tcall\tprintint\n");
  deallocate_register(r);
}

// Store a register's value into a variable
int cgstorglob(int r, char *identifier) {
  fprintf(Outfile, "\tmovq\t%s, %s(\%%rip)\n", reglist[r], identifier);
  return (r);
}

// Generate a global symbol
void cgglobsym(char *sym) {
  fprintf(Outfile, "\t.comm\t%s,8,8\n", sym);
}

// List of comparison instructions,
// in AST order: A_EQ, A_NE, A_LT, A_GT, A_LE, A_GE
static char *cmplist[]  = { "IEQ", "INE", "ILT", "IGT", "ILE", "IGE" };

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_compare_and_set(): Compare two registers and set if true.
//
int  codegen_compare_and_set (int ASTop, int dstreg, int srcreg)
{
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // Check the range of the AST operation
    //
    if (ASTop < A_EQ || ASTop > A_GE)
    {
        fatal ("Bad ASTop in codegen_compare_and_set()");
    }

    fprintf (Outfile, "    %s    %s,   %s\n", cmplist[ASTop - A_EQ], breglist[dstreg], breglist[srcreg]);

    deallocate_register (srcreg);
    return (dstreg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_label(): Generate a label
//
void codegen_label (int labelid)
{
    fprintf (Outfile, "L%d:\n", labelid);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_jump(): Generate a jump to a label
//
void codegen_jump (int labelid)
{
    fprintf (Outfile, "    JMP   L%d\n", labelid);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// List of inverted jump instructions,
// in AST order: A_EQ, A_NE, A_LT, A_GT, A_LE, A_GE
//
static char *invcmplist[] = { "jne", "je", "jge", "jle", "jg", "jl" };

////////////////////////////////////////////////////////////////////////////////////////
//
// codegen_compare_and_jump(): Compare two registers and jump if false.
//
int  cgcompare_and_jump (int ASTop, int dstreg, int srcreg, int label)
{
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // Check the range of the AST operation
    //
    if (ASTop < A_EQ || ASTop > A_GE)
    {
        fatal ("Bad ASTop in codegen_compare_and_set()");
    }

    fprintf (Outfile, "    %s    %s,   %s\n",  cmplist[ASTop - A_EQ], breglist[dstreg], breglist[srcreg]);
    fprintf (Outfile, "    JF    %s,   L%d\n", breglist[dstreg], label);

    registers_clear ();
    return (NOREG);
}
