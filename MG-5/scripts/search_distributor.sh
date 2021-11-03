#!/bin/bash

# the read IDs can not contain -
id="readIDs.tmp"
d="${1}"
reads="${2}"

END=$3
for ((bin=0;bin<END;bin++));
do
	o="distributed_reads/${bin}.fastq"
	pat1=$'\t'"$bin"","
	pat2=","${bin}","
	
	grep -e "$pat1" -e "$pat2" "$d" | awk '{print "@" $1 "$"}' > "$id"
	grep -A 3 -f "$id" "$reads" | sed "/--/d" > "$o"
	rm "$id"
done
