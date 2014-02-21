#!/bin/bash

# This scipt has been tested on CentOS 6 (RHEL6 compatibel).

# Load a bunch of variables
. settings.sh

# Get the server name from the calling script test_start.sh.
SERVER=$1

# How many transfers should we do? Again, test_start.sh will tell us.
TRANSFERS=$3

usage () {
  echo "This script is supposed to be called from test_start.sh."
  echo "Usage:"
  echo "$0 <hostname> <read|write> <repetitions>"
  exit
}

timer_start () {
  START=`python -c "import time; print time.time()"`
}

timer_stop () {
  STOP=`python -c "import time; print time.time()"`
  python -c "print str($TESTFILE_SIZE_MB*$i)+' MB; '+str($STOP-$START)+' sec; Throughput: '+str($TESTFILE_SIZE_MB*$i/(($STOP-$START)))+' MB/s.'"
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

    curl -s -S -k --user $USER:$PASSWD -L https://${REMOTE_SERVER}/$[STORAGE_PATH}/${TESTFILE}-${TESTFILE_SIZE_KB}-$NUMBER -o /dev/null
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
    curl -s -S -k --user $USER:$PASSWD -T $WRITEDIR/file${FILESIZE} -L https://p-edubox.grid.sara.nl/remote.php/webdav/testfile8_${FILESIZE}_$k
    # In the loop because this child may get killed and we want the last values.
    timer_stop
  done
  # The	first child process that has finished with all files, will kill	
  # all	other child processes.                                                        
  echo "One child has finished. Terminating all other child procs..." 1>&2
  kill_child_procs
}

if [ $# -ne 3 ]; then
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

