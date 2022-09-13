#!/bin/bash

# cd into the scripts folder
cd "$(dirname "$0")" || exit

# cd to root
cd ..

# check unit tests with code coverage if flag --coverage is added
if [ "$1" == "--coverage" ]; then
    busted "$1" spec
    luacov
    cat spec/luacov.report.out
    rm -f ./spec/luacov.report.out
    rm -f ./spec/luacov.stats.out
else
  busted spec
fi