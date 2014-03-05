#!/bin/bash

anywait(){

    for pid in "$@"; do
        while kill -0 "$pid"; do
            sleep 0.5
        done
    done
}

. settings.sh

rm -f test_results*.txt

for i in `seq 1 $READS` ; do
  ./test_child.sh read $TRANSFERS > test_results_read-$i.txt &
done

for i in `seq 1 $WRITES` ; do
  ./test_child.sh write $TRANSFERS > test_results_write-$i.txt &
done

anywait

./test_abort.sh

echo "All child processes have been terminated. Now calculating throughput..."
./result.py
