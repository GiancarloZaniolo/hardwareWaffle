#!/bin/bash

# TESTNAME="../tests/sample_mat3.txt"
# TESTNAME="../../tests/large.txt"
TESTNAME="../../tests/sample_mat.txt"

cd "$(dirname "$0")"
cd ../code_sw/code_cuda
git switch main
make

DUMPFILE="../../dumps/dump_main.txt"
rm $DUMPFILE
touch $DUMPFILE

for i in {1..100}; do
  ./waffle -f $TESTNAME >> $DUMPFILE
done


DUMPFILE=../../dumps/dump_old_rows_calculation.txt
rm $DUMPFILE
touch $DUMPFILE

git switch old_rows_calculation
make

for i in {1..100}; do
  ./waffle -f $TESTNAME >> $DUMPFILE
done
