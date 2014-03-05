#!/bin/bash

# If you change the values below, you may need to do a test_prepare.sh!

# Specify the remote server to copy to and from
REMOTE_SERVER=webdav.server.domain

# Specify the protocol used
PROTOCOL=https

# Storage path were the user is allowed to write on the remote machine
STORAGE_PATH=/remote.php/webdav

# Speaks for itself
USER=user
PASSWD=blablabla

#Testfile size in KB
TESTFILE_SIZE_KB=102400

# Number of files (not nessecerily same as number of transfers)
FILES=100000

# Total number of transfers (not necesserily the same as the number of files)
TRANSFERS=10000

# The number of concurrent writes during the tests
# Can be 0 or greater
WRITES=1

# The number of concurrent writes during the tests
# Can be 0 or greater
READS=10

#The stuff below you can leave as is.
#----------------------------------------------------

WRITEDIR=`pwd`/input_files

error=0
if [ -z ${REMOTE_SERVER} ]; then
    echo "Please specify REMOTE_SERVER in settings.sh"
    error=1
fi

if [ -z ${STORAGE_PATH} ]; then
    echo "Please specify STORAGE_PATH in settings.sh"
    error=1
fi

if [ -z ${PROTOCOL} ]; then
    echo "Please specify PROTOCOL in settings.sh"
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

if [ -z ${FILES} ]; then
    echo "Please specify FILES in settings.sh"
    error=1
fi

if [ -z ${TESTFILE_SIZE_KB} ]; then
    echo "Please specify TESTFILE_SIZE_KB in settings.sh"
    error=1
fi

if [ -z ${TRANSFERS} ]; then
    echo "Please specify TRANSFERS in settings.sh"
    error=1
fi

if [ -z ${READS} ]; then
    echo "Please specify READS in settings.sh"
    error=1
fi

if [ -z ${WRITES} ]; then
    echo "Please specify WRITES in settings.sh"
    error=1
fi

if [ $error -ne 0 ]; then
    exit 1
fi
