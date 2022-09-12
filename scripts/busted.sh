#!/bin/sh

cd ..
busted --coverage spec
luacov
cat spec/luacov.report.out
rm -f ./spec/luacov.report.out