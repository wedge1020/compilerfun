#!/usr/bin/env bash
##
## v32cc.sh - bash port of v32cc
##
########################################################################################

########################################################################################
##
## Declare global variables
##
lookahead=                   ## lookahead character

########################################################################################
##
## getsymbol(): obtain character from input stream
##
function getsymbol()
{
    read -r -s -n 1 input
	lookahead="${input}"
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
    symbol="${1}"
    result="FALSE"

    alphachk=$(echo "${symbol}" | grep '^[A-Za-z]$' | wc -l)

    if [ "${alphachk}" -eq 1 ]; then
        result="TRUE"
    fi

    printf "${result}"
}

########################################################################################
##
## isnumber(): recognize a decimal digit
##
function isnumber()
{
    symbol="${1}"
    result="FALSE"

    numberchk=$(echo "${symbol}" | grep '^[0-9]$' | wc -l)

    if [ "${numberchk}" -eq 1 ]; then
        result="TRUE"
    fi

    printf "${result}"
}

########################################################################################
##
## getname(): get an identifier
##
function getname()
{
    namechk=$(issymbol "${lookahead}")

    if [ "${namechk}" = "FALSE" ]; then
        expected "name"
    fi

    result="${lookahead}"
    getsymbol

    printf "${result}"
}

########################################################################################
##
## getnumber(): get a number
##
function getnumber()
{
    numberchk=$(isnumber "${lookahead}")

    if [ "${numberchk}" = "FALSE" ]; then
        expected "integer"
    fi

    result="${lookahead}"
    getsymbol

    printf "${result}"
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
## term(): parse and translate a math expression
##
function term()
{
    number="$(getnumber)"
    if [ ! -z "${number}" ]; then
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
    emitline "ISUB  R0,    R1"
    emitline "ISGN  R0"
}

########################################################################################
##
## expression(): parse and translate an expression
##
function expression()
{
    term
    emitline "MOV   R1,    R0"
	getsymbol
    case "${lookahead}" in
        "+")
            add
            ;;
        "-")
            subtract
            ;;
        *)
            expected "addop"
            ;;
    esac
}

########################################################################################
##
## initialize(): initialize everything
##
function initialize()
{
    getsymbol
}

########################################################################################
##
## where we start
##
initialize
expression

exit 0
