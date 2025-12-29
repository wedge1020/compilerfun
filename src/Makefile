BIN = v32cc
CC = gcc
CFLAGS = -Wall --std=gnu18
LEX = flex
LEXFLAGS = 
LEXSRC = lexer.l
YACC = bison
YACCFLAGS = -d
YACCSRC = parser.y
BINPATH = ../bin
all: head source tail

debug: CFLAGS +=  -g
debug: DEBUG = debug
debug: source object $(GAME) 

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
	@$(LEX)  $(LEXFLAGS)  $(LEXSRC)                   && echo  "\033[0;32mOK\033[0m"  \
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
	@$(YACC) $(YACCFLAGS) $(YACCSRC)                    && echo  "\033[0;32mOK\033[0m"  \
													   || (echo "\033[0;31mFAIL\033[0m" \
													   || exit 1)
	@[ ! -s "$(YACC).errors" ] && rm -f $(YACC).errors || echo -n
else
	$(YACC)  $(YACCFLAGS) $(YACCSRC)
endif

source: lexfiles yaccfiles
ifneq ($(MAKECMDGOALS),debug)
	@printf "[\033[0;34m%s\033[0m]    %-28s -> %-28s ... "	  "$(CC)"        \
															  "$(SRCFILE)"   \
															  "$(BIN)"
	@$(CC)   -c $(CFLAGS) $(SRCFILE) 2> $(CC).errors  && echo "\033[0;32mOK\033[0m" \
													  || (echo "\033[0;31mFAIL\033[0m" \
													  && exit 1)
	@[ ! -s "$(CC).errors" ] && rm -f $(CC).errors    || echo -n
else
	$(CC)    -c $(CFLAGS) $(SRCFILE)				  || exit 1
endif

$(BIN):
ifneq ($(MAKECMDGOALS),debug)
	@printf "[\033[1;34m%s\033[0m]    %-28s -> %-28s ... "    "$(CC)"  \
															  "*.o"    \
															  "$(BIN)"
	@$(CC) $(CFLAGS) *.o $(BIN) 2>> $(CC).errors      && echo "\033[1;32mDONE\033[0m"  \
													  || (echo "\033[1;31mFAIL\033[0m" \
													  && exit 1)
	@[ ! -s "$(CC).errors" ] && rm -f $(CC).errors    || echo -n
else
	$(CC)  $(CFLAGS) *.o $(BIN)                       || exit 1
endif

tail:
ifndef DEBUG
	@echo
endif

clean:
	@rm -f .*.sw[op] *.save* *~ *.errors *.debug
ifneq ("$(wildcard $(BIN))","")
	@printf "[\033[0;34m%s\033[0m]     %-36s\n" "$(CATEGORY)" \
	                                            "removing output files"
	@make -f Makefile.clean --no-print-directory
	@echo
endif
	@echo -n
