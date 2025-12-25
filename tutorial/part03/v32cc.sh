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
## issymbol(): recognize an alpha character
##
function issymbol()
{
    lookahead=$(cat ${TMPFILE}.look)
    result="FALSE"

    alphachk=$(echo "${lookahead}" | grep '^[A-Za-z]$' | wc -l)
    if [ "${alphachk}" -eq 1 ]; then
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
    lookahead=$(cat ${TMPFILE}.look)
    result="FALSE"

    numberchk=$(echo "${lookahead}" | grep '^[0-9]$' | wc -l)
    if [ "${numberchk}" -eq 1 ]; then
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
## getname(): get an identifier
##
function getname()
{
    lookahead=$(cat ${TMPFILE}.look)
    namechk=$(issymbol)

    if [ "${namechk}" = "FALSE" ]; then
        expected "name"
    fi

    result="${lookahead}"
    getsymbol

    printf "${result}\n"
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

    ####################################################################################
    ##
    ## determine if `lookahead` is a number; if not, error out
    ##
    numberchk=$(isnumber)
    if [ "${numberchk}" = "FALSE" ]; then
        expected "integer"
        exit 1
    fi

    ####################################################################################
    ##
    ## if `lookahead` is a number, store it, and obtain the next value
    ##
    result="${lookahead}"
    getsymbol

    ####################################################################################
    ##
    ## display the result to STDOUT
    ##
    echo "${result}"
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
    printf "\n"
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
    lookchk=$(issymbol)

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
expression
if [ ! "${alookahead}" = '\n' ]; then
    expected "newline"

rm -f ${TMPFILE} ${TMPFILE}.look

exit 0
