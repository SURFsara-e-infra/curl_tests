#!/bin/bash

. settings.sh

# Total number of transfers is not necesserily the same as the number of files.
TRANSFERS=10000
WRITES=1
READS=10

rm -f test_results*.txt

for i in `seq 1 $READS` ; do
  ./test_child.sh read $TRANSFERS > test_results_read-$i.txt &
done

for i in `seq 1 $WRITES` ; do
  ./test_child.sh write $TRANSFERS > test_results_write-$i.txt &
done

wait

echo "All child processes have been terminated. Now calculating throughput..."
./result.py
