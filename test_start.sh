#!/bin/bash

. settings.sh

rm -f test_results*.txt

for i in `seq 1 $READS` ; do
  ./test_child.sh read > test_results_read-$i.txt &
done

for i in `seq 1 $WRITES` ; do
  ./test_child.sh write > test_results_write-$i.txt &
done
