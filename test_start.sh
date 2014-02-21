#!/bin/bash

. settings.sh

# Number of transfers is not necesserily the same as the number of files.
TRANSFERS=10000
RATIO_RW_OPS=10

rm -f test_results*.txt

for i in `seq 1 $RATIO_RW_OPS` ; do
  ./test_child.sh $REMOTE_SERVER read $TRANSFERS > test_results_read-$i.txt &
done

./test_child.sh $REMOTE_SERVER write $TRANSFERS > test_results_write-1.txt &

wait

echo "All child processes have been terminated. Now calculating throughput..."

calculate_throughput () {
  TRANSFER_TYPE=$1
  MB_TOTAL=0
  SEC_TOTAL=0
  for file in test_results_${TRANSFER_TYPE}.txt ; do
    MB=`get_last_line $file | sed -e 's/^\(.*\) MB;.*$/\1/'`
    MB_TOTAL=`echo "$MB_TOTAL + $MB" | bc`
    SEC=`get_last_line $file | sed -e 's/^.* MB; \(.*\) sec;.*$/\1/'`
    SEC_TOTAL=`echo "$SEC_TOTAL + $SEC" | bc`
  done
  if [ "$SEC_TOTAL" = "0" ] ; then
    echo "Error calculating average thoughput! Total seconds = 0!"
  fi
  THROUGHPUT=`echo "scale=3 ; $MB_TOTAL / $SEC_TOTAL" | bc`
  echo "Throughput for transfer type $TRANSFER_TYPE: $THROUGHPUT MB/s."
}

for i in `seq 1 $RATIO_RW_OPS` ; do
  calculate_throughput read-${i}
done
calculate_throughput write-1

echo -n "Cleaning up... "
rm -f $STORAGE_PATH/$TESTFILE-proc*-*
echo "Done."
