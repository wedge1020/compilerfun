BIN = v32cc
CC = gcc
CFLAGS = -Wall --std=gnu18
INPUTS := $(wildcard *.c)
OBJ := $(patsubst %.c,%.o,${INPUTS})
LEX = flex
LEXFLAGS = 
LEXSRC = lexer.l
YACC = bison
YACCFLAGS = -d
YACCSRC = parser.y
BINPATH = ../bin
all: head $(BIN) tail

debug: CFLAGS +=  -g
debug: DEBUG = debug
debug: $(BIN) 

head:
ifndef DEBUG
	@printf "\033[0;33m%s\033[0m:\n" "$(BIN)"
	@printf "\033[0;33m================================================================"
	@printf "==================\033[0m\n"
endif

lexfiles:
ifneq ($(MAKECMDGOALS),debug)
	@printf "[\033[0;34m%s\033[0m]   %-28s -> %-28s ... "	 "$(LEX)"               \
															 "$(LEXSRC)"            \
															 "lex.yy.c"
	@$(LEX)  $(LEXFLAGS)  $(LEXSRC)                  && echo  "\033[0;32mOK\033[0m"  \
													 || (echo "\033[0;31mFAIL\033[0m" \
													 || exit 1)
	@[ ! -s "$(LEX).errors" ] && rm -f $(LEX).errors || echo -n
else
	$(LEX)   $(LEXFLAGS)  $(LEXSRC)
endif

yaccfiles:
ifneq ($(MAKECMDGOALS),debug)
	@printf "[\033[0;34m%s\033[0m]  %-28s -> %-28s ... "	 "$(YACC)"              \
															 "$(YACCSRC)"           \
															 "parser.tab.c"
	@$(YACC) $(YACCFLAGS) $(YACCSRC)                   && echo  "\033[0;32mOK\033[0m"  \
													   || (echo "\033[0;31mFAIL\033[0m" \
													   || exit 1)
	@[ ! -s "$(YACC).errors" ] && rm -f $(YACC).errors || echo -n
else
	$(YACC)  $(YACCFLAGS) $(YACCSRC)
endif

$(BIN): lexfiles yaccfiles
ifneq ($(MAKECMDGOALS),debug)
	@printf "[\033[0;34m%s\033[0m]    %-28s -> %-28s ... "	  "$(CC)"        \
															  "lex.yy.c"   \
															  "lex.yy.o"
	@$(CC) -c $(CFLAGS) lex.yy.c      2>  $(CC).errors && echo "\033[0;32mOK\033[0m"  \
													   || (echo "\033[0;31mFAIL\033[0m" \
													   && exit 1)
	@printf "[\033[0;34m%s\033[0m]    %-28s -> %-28s ... "	  "$(CC)"        \
															  "parser.tab.c"   \
															  "parser.tab.o"
	@$(CC) -c $(CFLAGS) parser.tab.c  2>> $(CC).errors && echo "\033[0;32mOK\033[0m"  \
													   || (echo "\033[0;31mFAIL\033[0m" \
													   && exit 1)
	@printf "[\033[0;34m%s\033[0m]    %-28s -> %-28s ... "	  "$(CC)"        \
															  "registeruse.c"   \
															  "registeruse.o"
	@$(CC) -c $(CFLAGS) registeruse.c 2>> $(CC).errors && echo "\033[0;32mOK\033[0m"  \
													   || (echo "\033[0;31mFAIL\033[0m" \
													   && exit 1)
	@printf "[\033[0;34m%s\033[0m]    %-28s -> %-28s ... "	  "$(CC)"        \
															  "symboltable.c"   \
															  "symboltable.o"
	@$(CC) -c $(CFLAGS) symboltable.c 2>> $(CC).errors && echo "\033[0;32mOK\033[0m"  \
													   || (echo "\033[0;31mFAIL\033[0m" \
													   && exit 1)
	@printf "[\033[1;34m%s\033[0m]    %-28s -> %-28s ... "	  "$(CC)"        \
															  "*.o"   \
															  "$(BIN)"
	@$(CC)    $(CFLAGS) *.o -o $(BIN) 2>> $(CC).errors && echo "\033[1;32mDONE\033[0m"  \
													   || (echo "\033[1;31mFAIL\033[0m" \
													   && exit 1)
	@[ ! -s "$(CC).errors" ] && rm -f $(CC).errors     || echo -n
else
	$(CC) -c $(CFLAGS) lex.yy.c                       || exit 1
	$(CC) -c $(CFLAGS) parser.tab.c                   || exit 1
	$(CC) -c $(CFLAGS) registeruse.c                  || exit 1
	$(CC) -c $(CFLAGS) symboltable.c                  || exit 1
	$(CC)    $(CFLAGS) *.o -o $(BIN)                  || exit 1
endif

tail:
ifndef DEBUG
	@echo
endif

clean:
	@rm -vf .*.sw[op] *.save* *~ *.errors *.debug *.o lex.yy.c parser.tab.c parser.tab.h $(BIN)
