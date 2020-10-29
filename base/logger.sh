#!/usr/bin/env bash
#set -euo pipefail

print_color_test() {
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

print_color() {
    CTRL="\033[${1};${2};${3}m"
    echo -en "${CTRL}"
    echo -n "${4}"
    echo -e "\033[0m"
}

msg() {
    echo -e "$1" >&2
}

debug() {
    print_color 1 33 40 $1
}

info() {
    print_color 1 36 40 $1
}

error() {
    local line="ERROR:${FUNCNAME[$i+1]}:${BASH_LINENO[$i+1]}"
    print_color 7 31 40 ${line}
    print_color 7 31 40 $1
    exit 1
}

log_test() {
    debug 123
    info  456
    error 789
}
