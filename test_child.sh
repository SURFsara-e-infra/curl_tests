#!/bin/bash

# Load a bunch of variables
. settings.sh

# How many transfers should we do? Again, test_start.sh will tell us.
TRANSFERS=$2

usage () {
  echo "This script is supposed to be called from test_start.sh."
  echo "Usage:"
  echo "$0 <read|write> <repetitions>"
  exit
}

timer_start () {
  START=`python -c "import time; print time.time()"`
}

timer_stop () {
  STOP=`python -c "import time; print time.time()"`
  python -c "print str($TESTFILE_SIZE_KB*$i/1024.0)+' MB; '+str($STOP-$START)+' sec; Throughput: '+str($TESTFILE_SIZE_KB*$i/(($STOP-$START)*1024.0))+' MB/s.'"
}

get_random_file_number () {
  if [ -z "$1" ] ; then 
    echo "Function get_random_file_number needs a max number."
    exit 1
  fi
  a=`expr $RANDOM \* $1`
  b=`expr $a / 32768`
  NUMBER=`expr $b + 1`
  echo $NUMBER
}

test_read () {
  # Client read test (= server write, but we are testing the client)
  timer_start
  for i in `seq 1 $TRANSFERS` ; do
    NUMBER=`get_random_file_number $FILES`

    curl -s -S -k --user $USER:$PASSWD -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}/testfile_${TESTFILE_SIZE_KB}_${NUMBER} -o /dev/null
    # In the loop because this child may get killed and we want the last values.
    timer_stop
  done
  # The first child process that has finished with all files, will kill 
  # all other child processes.
  echo "One child has finished. Terminating all other child procs..." 1>&2
  kill_child_procs
}

test_write () {
  # Client write test
  timer_start
  for i in `seq 1 $TRANSFERS` ; do
    j=`expr $i % $FILES`
    curl -s -S -k --user $USER:$PASSWD -T $WRITEDIR/file${TESTFILE_SIZE_KB} ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/writetestfiles${TESTFILE_SIZE_KB} 
    # In the loop because this child may get killed and we want the last values.
    timer_stop
  done
  # The	first child process that has finished with all files, will kill	
  # all	other child processes.                                                        
  echo "One child has finished. Terminating all other child procs..." 1>&2
  kill_child_procs
}

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

test=$2
case $test in
  "read" )
       test_read
       exit 0
       ;;
  "write" )
       test_write
       exit 0
       ;;
  * )
       usage
       exit 1
       ;;
esac

