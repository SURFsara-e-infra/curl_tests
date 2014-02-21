#!/bin/bash

# If you change the values below, you may need to do a test_prepare.sh!

# Specify the remote server to copy to and from
REMOTE_SERVER=p-edubox.grid.sara.nl

# Specify the protocol used
PROTOCOL=https

# Local storage path where the test files are.
STORAGE_PATH=/remote.php/webdav

# Anonymous user to read and write the files. This is not allowed to be root.
USER=
PASSWD=

#Testfile size in KB
TESTFILE_SIZE_KB=

# Number of files (not nessecerily same as number of transfers)
FILES=10000

#The stuff below you can leave as is.
#----------------------------------------------------

error=0
if [ -z ${REMOTE_SERVER} ]; then
    echo "Please specify REMOTE_SERVER in settings.sh"
    error=1
fi

if [ -z ${STORAGE_PATH} ]; then
    echo "Please specify STORAGE_PATH in settings.sh"
    error=1
fi

if [ -z ${USER} ]; then
    echo "Please specify USER in settings.sh"
    error=1
fi

if [ -z ${PASSWD} ]; then
    echo "Please specify PASSWD in settings.sh"
    error=1
fi

if [ $error -ne 0 ]; then
    exit 1
fi

get_last_line () {
  tail -n 1 $1
}

kill_child_procs () {
  echo "One child has finished. Terminating all other child procs..." 1>&2
  killall -9 test_child.sh
}
