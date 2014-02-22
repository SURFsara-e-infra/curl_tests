#!/bin/bash

. settings.sh
tb=1099511627776


read=`tail -n 1 test_results_read* | grep Through | awk '{print $6}' | paste -s -d + - | bc`
write=`tail -n 1 test_results_write* | grep Through | awk '{print $6}' | paste -s -d + - | bc`
tera_bytes=`df -B${tb} ${STORAGE_PATH} | grep -E '[0-9]+%' | awk '{print $1}'`

echo ${read}" MiB/s read"
echo ${write}" MiB/s written"

rpspt=`python -c "print ${read} / ${tera_bytes}"`
wpspt=`python -c "print ${write} / ${tera_bytes}"`

echo ${rpspt}" MiB/s/TiB read"
echo ${wpspt}" MiB/s/TiB written"
