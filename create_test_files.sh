#!/bin/bash

. settings.sh

WRITEDIR=`pwd`/input_files
IF=/dev/zero
OF=/dev/null

rm -rf $WRITEDIR
mkdir -p $WRITEDIR
NUMCONCURRENT=10
output=output${TESTFILE_SIZE_KB}
error=error${TESTFILE_SIZE_KB}

dd if=$IF of=$WRITEDIR/file${TESTFILE_SIZE_KB} bs=${TESTFILE_SIZE_KB} count=1024 2>&1 | sed -e "s/^/write $i: /" >> $output &
wait

curl -s -S -k --user $USER:$PASSWD -X MKCOL ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB} 1>> $output 2>>$error

curl -s -S -k --user $USER:$PASSWD -X MKCOL ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/writetestfiles${TESTFILE_SIZE_KB} 1>> $output 2>>$error

k=0
while [ $k -le $FILES ]
do

    i=0
    while [ $i -le ${NUMCONCURRENT} -a $k -le $FILES ]
    do

        echo "curl -s -S -k --user USER:PASSWD -T $WRITEDIR/file${TESTFILE_SIZE_KB} -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}/testfile_${TESTFILE_SIZE_KB}_$k" >>$output
        curl -s -S -k --user $USER:$PASSWD -T $WRITEDIR/file${TESTFILE_SIZE_KB} -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/readtestfiles${TESTFILE_SIZE_KB}/testfile_${TESTFILE_SIZE_KB}_$k 1>>$output 2>>$error &
        i=`expr $i + 1`
        k=`expr $k + 1`
        sleep 1

    done
    wait

done
