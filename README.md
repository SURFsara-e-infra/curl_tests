curl_tests
==========

Author: Ron Trompert
Date: March 5th 2014
Version: 0.1

Introduction
------------
This set of script I have written to test a webdav environment like owncloud. 

Operation
---------
This test suite creates a bunch of files of a certain size on a remote webdav server. There are a number of read
and write processes that are continuously and concurrently running. The read processes select a random file to read from the webdav server
while the write processes write a locally generated file to the remote webdav server. After a number of transfers the test
will stop and output like the number of transfer within a time frame, the overall throughput and the average individual 
transfer rate will be printed.

Scripts
-------

prepare_tests.sh: Prepares the test environment.

settings.sh: A necessary input needs to be specified here like:
remote server, username, password, protocol, storage path on the remote host, file size in KB, number of transfers, number of test files, number of 
concurrent reads, number of concurrent writes. This is the only script where you need to specify input

test_child.sh: This script starts a read or write process.

test_start.sh: This script starts the test.

result.py: This script computes and prints the result of the test.

test_abort.sh: Aborts the test.

Usage
-----

1. Fill in the necessary values in settings.sh
2. Start prepare_tests.sh
3. Run test_start.sh

After test_start.sh finishes. The result is automatically printed. It is always a possibility when things take too long
to run test_abort.sh followed by result.py by hand.

