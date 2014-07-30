#!/usr/bin/env bash


let DEBUG=0

DEBUG(){
    if [ "$DEBUG" = "true" ]; then
        $@　　
    fi
}

print_color(){
    for STYLE in 0 1 2 3 4 5 6 7; do
        for FG in 30 31 32 33 34 35 36 37; do
            for BG in 40 41 42 43 44 45 46 47; do
                CTRL="\033[${STYLE};${FG};${BG}m"
                echo -en "${CTRL}"
                echo -n "${STYLE};${FG};${BG}"
                echo -en "\033[0m"
            done
            echo
        done
        echo
    done
    # Reset
    echo -e "\033[0m"
}

msg() {
    echo -e "$1" >&2
}

info() {
    msg "\e[32m${1}\e[0m"
}

error() {
    msg "\e[31mAn error in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}\e[0m"
    msg "\e[31m${1}${2}\e[0m"
    exit 1
}

check_command_exists() {
    type $1 >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        error ${2-"Please install '$1' first."}
    fi
}
