#!/usr/bin/env bash
##
## v32cc.sh - bash port of v32cc
##
########################################################################################

########################################################################################
##
## Declare global variables
##
TMPFILE=$(mktemp -p /tmp v32cc.XXXX) ## temporary file
lookahead=                           ## lookahead character

########################################################################################
##
## getsymbol(): obtain character from input stream
##
function getsymbol()
{
    ####################################################################################
    ##
    ## check if we have exhausted our line-buffered input, obtain more if needed
    ##
    lineinput=$(cat ${TMPFILE})
#    if [ -z "${lineinput}" ]; then
#        read lineinput
#        echo "${lineinput}"                                         >  ${TMPFILE}
#    fi

    ####################################################################################
    ##
    ## obtain the next character from our input into `lookahead` and display it to
    ## STDOUT.
    ##
    lookahead=$(echo "${lineinput}" | cut -c1)
    echo "${lookahead}"                                             >  ${TMPFILE}.look

    ####################################################################################
    ##
    ## update `lineinput` to omit the recently-stored character in `lookahead`
    ##
    lineinput=$(echo "${lineinput}" | cut -c2-)
    echo "${lineinput}"                                             >  ${TMPFILE}
}

########################################################################################
##
## showerror(): report an error
##
function showerror()
{
    msg="${1}"
    printf "[error] %s\n" "${msg}" 1>&2
}

########################################################################################
##
## aborterror(): report an error and exit
##
function aborterror()
{
    msg="${1}"
    showerror "${msg}"
    exit 1
}

########################################################################################
##
## expected(): report what was expected
##
function expected()
{
    msg="${1}"
    aborterror "${msg} expected"
    exit 1
}

########################################################################################
##
## match(): match a specific input character
##
function match()
{
    lookahead=$(cat ${TMPFILE}.look)
    symbol="${1}"

    if [ "${lookahead}" = "${symbol}" ]; then
        getsymbol
    else
        expected "${symbol}"
    fi
}

########################################################################################
##
## iswhitespace(): recognize a whitespace character
##
function iswhitespace()
{
    result="FALSE"

    if [ "${symbol}" = ' ' ] || [ "${symbol}" = '\t' ]; then
        result="TRUE"
    fi

    echo "${result}"
}

########################################################################################
##
## issymbol(): recognize an alpha character
##
function issymbol()
{
    symbol="${1}"
    result="FALSE"

    symchk=$(echo "${symbol}" | grep '^[A-Za-z]$' | wc -l)
    if [ "${symchk}" -eq 1 ]; then
        result="TRUE"
    fi

    echo "${result}"
}

########################################################################################
##
## isnumber(): recognize a decimal digit
##
function isnumber()
{
    number="${1}"
    result="FALSE"

    numberchk=$(echo "${number}" | grep '^[0-9]$' | wc -l)
    if [ "${numberchk}" -eq 1 ]; then
        result="TRUE"
    fi

    echo "${result}"
}

########################################################################################
##
## issymnum(): recognize a decimal digit
##
function issymnum ()
{
    symbol="${1}"
    result="FALSE"

    symchk=$(issymbol "${symbol}")
    numchk=$(isnumber "${symbol}")

    if [ "${symchk}" = "TRUE" ] || [ "${numchk}" = "TRUE" ]; then
        result="TRUE"
    fi

    echo "${result}"
}

########################################################################################
##
## isaddop(): recognize an addition operation
##
function isaddop()
{
    lookahead=$(cat ${TMPFILE}.look)

    result=$(printf -- "${lookahead}" | grep -q '[+-]' && echo "TRUE" || echo "FALSE")

    echo "${result}"
}

########################################################################################
##
## skipwhitespace(): skip over leading white space
##
function skipwhitespace ()
{
    lookahead=$(cat ${TMPFILE}.look)
    whitespacechk=$(iswhitespace "${lookahead}")
    while [ "${whitespacechk}" = "TRUE" ]; do
        getsymbol
        lookahead=$(cat ${TMPFILE}.look)
        whitespacechk=$(iswhitespace "${lookahead}")
    done
}

########################################################################################
##
## getname(): get an identifier
##
function getname()
{
    lookahead=$(cat ${TMPFILE}.look)
    namechk=$(issymbol "${lookahead}")
    token=

    if [ "${namechk}" = "FALSE" ]; then
        expected "name"
    fi

    symnumchk=$(issymnum "${lookahead}")
    while [ "${symnumchk}" = "TRUE" ]; do
        token="${token}${lookahead}"
        getsymbol
        symnumchk=$(issymnum "${lookahead}")
    done

    echo "${token}"
}

########################################################################################
##
## getnumber(): get a number
##
function getnumber()
{
    ####################################################################################
    ##
    ## declare local variables
    ##
    lookahead=$(cat "${TMPFILE}.look")
    value=

    ####################################################################################
    ##
    ## determine if `lookahead` is a number; if not, error out
    ##
    numberchk=$(isnumber "${lookahead}")
    if [ "${numberchk}" = "FALSE" ]; then
        expected "integer"
    fi

    ####################################################################################
    ##
    ## while `lookahead` is a number, append it, and obtain the next value
    ##
    numchk=$(isnumber "${lookahead}")
    while [ "${numchk}" = "TRUE" ]; do
        value="${value}${lookahead}"
        getsymbol
        numchk=$(isnumber "${lookahead}")
    done

    echo "${value}"
}

########################################################################################
##
## emit(): output a string with indentation
##
function emit()
{
    msg="${1}"
    printf "    %s"  "${msg}"
}

########################################################################################
##
## emitline(): output a string with indentation and newline
##
function emitline()
{
    msg="${1}"
    emit "${msg}"
    echo
}

########################################################################################
##
## emitlabel(): output a string as a label
##
function emitlabel()
{
    msg="${1}"
    printf "%s:\n" "${msg}"
}


########################################################################################
##
## multiply(): recognize and translate a multiplication
##
function multiply()
{
    match '*'
    factor
    emitline "POP   R1"
    emitline "IMUL  R0,    R1"
}

########################################################################################
##
## divide(): recognize and translate a division
##
function divide()
{
    match '/'
    factor
    emitline "POP   R1"
    emitline "IDIV  R1,    R0"
    emitline "MOV   R0,    R1"
}

########################################################################################
##
## modulus(): recognize and translate a modulus
##
function modulus()
{
    match '%'
    factor
    emitline "POP   R1"
    emitline "IMOD  R1,    R0"
    emitline "MOV   R0,    R1"
}

########################################################################################
##
## term(): parse and translate a math term
##
function term()
{
    lookahead=$(cat ${TMPFILE}.look)
    factor
    lookahead=$(cat ${TMPFILE}.look)

    multopchk=$(echo "${lookahead}" | grep -q '[*/%]' && echo "TRUE" || echo "FALSE")
    while [ "${multopchk}" = "TRUE" ]; do

        emitline "PUSH  R0"

        case "${lookahead}" in
            '*')
                multiply
                ;;
            '/')
                divide
                ;;
            '%')
                modulus
                ;;
        esac
        lookahead=$(cat ${TMPFILE}.look)
        multopchk=$(echo "${lookahead}" | grep -q '[*/%]' && echo "TRUE" || echo "FALSE")
    done
}

########################################################################################
##
## ident(): parse and translate an identifier
##
function ident()
{
    lookahead=$(cat ${TMPFILE}.look)
    name=$(getname)

    if [ "${lookahead}" = '(' ]; then
        match '('
        match ')'
        emitline "CALL  ${name}"
    else
        emitline "CALL  fhack"
        emitlabel "fhack"
        emitline "POP   R1"
        emitline "LEA   R0,    [R1+${name}]"
    fi
}

########################################################################################
##
## factor(): parse and translate a math factor
##
function factor()
{
    lookahead=$(cat ${TMPFILE}.look)
    lookchk=$(issymbol "${lookahead}")

    if [ "${lookahead}" = '(' ]; then
        match '('
        expression
        match ')'
    elif [ "${lookchk}" = "TRUE" ]; then
        ident
    else
        number="$(getnumber)"
        msg="MOV   R0,    ${number}"
        emitline "${msg}"
    fi
}

########################################################################################
##
## add(): recognize and translate an addition
##
function add()
{
    match "+"
    term
    emitline "POP   R1"
    emitline "IADD  R0,    R1"
}

########################################################################################
##
## subtract(): recognize and translate a subtraction
##
function subtract()
{
    match "-"
    term
    emitline "POP   R1"
    emitline "ISUB  R0,    R1"
    emitline "ISGN  R0"
}

########################################################################################
##
## expression(): parse and translate an expression
##
function expression()
{
    lookahead=$(cat ${TMPFILE}.look)
    addopchk=$(isaddop)

    if [ "${addopchk}" = "TRUE" ]; then
        emitline "MOV   R0,    0"
    else
        term
        lookahead=$(cat ${TMPFILE}.look)
    fi

    addopchk=$(isaddop)
    while [ "${addopchk}" = "TRUE" ]; do
        emitline "PUSH  R0"
        case "${lookahead}" in
            "+")
                add
                ;;
            "-")
                subtract
                ;;
        esac
        lookahead=$(cat ${TMPFILE}.look)
        addopchk=$(isaddop)
    done
}

########################################################################################
##
## assignment(): parse and translate an assignment statement
##
function assignment ()
{
    name=$(getname)

    match '='
    expression;

    emitline  "CALL  fhack2"
    emitlabel "fhack2"
    emitline  "POP   R2"
    emitline  "LEA   R1,    [R2+${name}]"
    emitline  "MOV   [R1],  R0"
}

########################################################################################
##
## initialize(): initialize everything
##
function initialize()
{
    touch ${TMPFILE}
    read lineinput
    echo "${lineinput}"                                         >  ${TMPFILE}
    getsymbol
}

########################################################################################
##
## where we start
##
initialize
assignment
if [ ! "${alookahead}" = '\n' ]; then
    expected "newline"
fi

rm -f ${TMPFILE} ${TMPFILE}.look

exit 0
