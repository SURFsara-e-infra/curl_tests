#!/bin/bash

. settings.sh

TIMEOUT=3600
USEC=1000

IF=/dev/zero
OF=/dev/null

mkdir -p $WRITEDIR
NUMCONCURRENT=10
output=output${TESTFILE_SIZE_KB}
error=error${TESTFILE_SIZE_KB}

# Create test file to be copied to the remote machine
dd if=$IF of=$WRITEDIR/file${TESTFILE_SIZE_KB} bs=${TESTFILE_SIZE_KB} count=1024 2>&1 | sed -e "s/^/write $i: /" > $output &
wait

# If remote directory to read files from already exists, then delete it.
echo "curl -s -S -k --user $USER:$PASSWD -X DELETE -m $TIMEOUT --connect-timeout $TIMEOUT -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}" >>$output
curl -s -S -k --user $USER:$PASSWD -X DELETE -m $TIMEOUT --connect-timeout $TIMEOUT -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB} 1>> $output 2>$error

# If remote directory to write files to already exists, then delete it.
echo "curl -s -S -k --user $USER:$PASSWD -X DELETE -m $TIMEOUT --connect-timeout $TIMEOUT -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}" >>$output
curl -s -S -k --user $USER:$PASSWD -X DELETE -m $TIMEOUT --connect-timeout $TIMEOUT -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/writetestfiles${TESTFILE_SIZE_KB} 1>> $output 2>>$error


# Create remote directory to read files from
echo "curl -s -S -k --user $USER:$PASSWD -X MKCOL ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}" >>$output
curl -s -S -k --user $USER:$PASSWD -X MKCOL ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB} 1>> $output 2>>$error

# Create remote directory to write files to
echo "curl -s -S -k --user $USER:$PASSWD -X MKCOL ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/writetestfiles${TESTFILE_SIZE_KB}" >>$output
curl -s -S -k --user $USER:$PASSWD -X MKCOL ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/writetestfiles${TESTFILE_SIZE_KB} 1>> $output 2>>$error


# Loop over all files that will be created on the remote machine to do the read
# tests
k=1
while [ $k -le $FILES ]
do

# Write the files concurrently
    i=1
    while [ $i -le ${NUMCONCURRENT} -a $k -le $FILES ]
    do

        echo "curl -s -S -k --connect-timeout 10 --user $USER:$PASSWD -T $WRITEDIR/file${TESTFILE_SIZE_KB} -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}/testfile_${TESTFILE_SIZE_KB}_$k" >>$output
        curl -s -S -k --connect-timeout 10 --user $USER:$PASSWD -T $WRITEDIR/file${TESTFILE_SIZE_KB} -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}/testfile_${TESTFILE_SIZE_KB}_$k 1>>$output 2>>$error &
        i=`expr $i + 1`
        k=`expr $k + 1`
        usleep $USEC

    done
    wait

done
