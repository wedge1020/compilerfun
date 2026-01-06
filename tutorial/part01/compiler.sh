#!/usr/bin/env bash
##
## compiler.sh - bash port of tutorial's cradle
##
##############################################################################

##############################################################################
##
## Declare global variables
##
lookahead=                   ## lookahead character
                              
##############################################################################
##
## getsymbol(): obtain character from input stream
##
function getsymbol()
{
    read -n 1 lookahead
}
                              
##############################################################################
##
## showerror(): report an error
##
function showerror()
{
    msg="${1}"
    printf "[error] %s\n" "${msg}" 1>&2
}

##############################################################################
##
## aborterror(): report an error and exit
##
function aborterror()
{
    msg="${1}"
    showerror "${msg}"
    exit 1
}

##############################################################################
##
## expected(): report what was expected
##
function expected()
{
    msg="${1}"
    aborterror "${msg} expected"
}

##############################################################################
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

##############################################################################
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

    return "${result}"
}

##############################################################################
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

    return "${result}"
}

##############################################################################
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

    return "${result}" 
}

##############################################################################
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

    return "${result}" 
}

##############################################################################
##
## emit(): output a string with indentation
##
function emit()
{
    msg="${1}"
    printf "    %s"  "${msg}"
}

##############################################################################
##
## emitline(): output a string with indentation and newline
##
function emitline()
{
    msg="${1}"
    emit "${msg}"
    printf "\n"
}

##############################################################################
##
## initialize(): initialize everything
##
function initialize()
{
    getsymbol
}

##############################################################################
##
## where we start
##
initialize
exit 0
