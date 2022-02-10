#!/usr/bin/env bash

# ./showtable.sh "table1.txt"

echo $(dirname $0)

. ../bin/_table.sh

echo $1

printTable ',' "$(cat $1)"