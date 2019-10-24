#!/bin/bash

ls -ARlF | awk '{print $1 " " $5 " " $9}' | sort -k2,2 -nr | awk 'BEGIN{file_cnt = 0; dir_cnt = 0; total = 0}/ .*/{if(NR <= 5){print NR ":" $2 " " $3}} {if(substr($1, 1, 1) == "-") file_cnt++} {if(substr($1, 1, 1) == "d") dir_cnt++} {total += $2} END {print "Dir num: " dir_cnt} END {print "File num: " file_cnt} END {print "Total: " total} ' 
