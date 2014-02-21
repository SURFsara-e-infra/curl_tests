#!/bin/bash

. ./settings.sh

WRITEDIR=`pwd`/input_files
IF=/dev/zero
OF=/dev/null

rm -rf $WRITEDIR
mkdir -p $WRITEDIR
NUMCONCURRENT=10

dd if=$IF of=$WRITEDIR/file${TESTFILE_SIZE_KB} bs=${TESTFILE_SIZE_KB} count=1024 2>&1 | sed -e "s/^/write $i: /" &
wait

k=0
while [ $k -le $FILES ]
do

    i=0
    while [ $i -lt ${NUMCONCURRENT} -a $k -lt $FILES ]
    do

        i=`expr $i + 1`
        k=`expr $k + 1`
        curl -s -S -k --user $USER:$PASSWD -T $WRITEDIR/file${TESTFILE_SIZE_KB} -L ${PROTOCOL}://${REMOTE_SERVER}/${STORAGE_PATH}/testfile_${TESTFILE_SIZE_KB}_$k 1>>output 2>>error </dev/null &

    done
    wait

done
