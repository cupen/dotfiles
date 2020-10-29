#!/usr/bin/env bash

require() {
    type $1 >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "$2 install '$1' first."
        exit 1
    fi
}
