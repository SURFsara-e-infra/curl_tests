#!/bin/bash

# Load a bunch of variables
. settings.sh

usage () {
  echo "This script is supposed to be called from test_start.sh."
  echo "Usage:"
  echo "$0 <read|write>"
  exit
}

timer_start () {
  START=`python -c "import time; print time.time()"`
  echo $START
}

timer_stop () {
  START=$1
  STOP=`python -c "import time; print time.time()"`
  python -c "print 'time:'+str($STOP)+';'+str($TESTFILE_SIZE_KB/1024.0)+' MB; '+str($STOP-$START)+' sec; Throughput: '+str($TESTFILE_SIZE_KB/(($STOP-$START)*1024.0))+' MB/s.'"
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
  # Client read test
  while true; do
    NUMBER=`get_random_file_number $FILES`

    START=`timer_start`
    curl -s -S -k --user $USER:$PASSWD -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}/testfile_${TESTFILE_SIZE_KB}_${NUMBER} -o /dev/null
    timer_stop $START
  done
}

test_write () {
  # Client write test
  DIR=writetestfiles${TESTFILE_SIZE_KB}`uuid`
  curl -s -S -k --user $USER:$PASSWD -X MKCOL ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/${DIR} >/dev/null 2>&1
  i=1
  while true; do
    j=`expr $i % $FILES`
    START=`timer_start`
    curl -s -S -k --user $USER:$PASSWD -T $WRITEDIR/file${TESTFILE_SIZE_KB} -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/${DIR}/testfile_${TESTFILE_SIZE_KB}_${j}
    timer_stop $START
    i=`expr $i + 1`
  done
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

test=$1
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

