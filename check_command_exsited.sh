#!/bin/bash
source ./base/base.sh

check_command_exists gcc
check_command_exists make
check_command_exists ctags
check_command_exists python

echo "OK"
