#!/bin/bash
################################################
### get oracle sid and execute v30-awr2ipoc.sh put date 
################################################
ls ~/awrlog | grep html | awk -F "_" '{print $1}' | sort -u | while read LINE
do
	echo $LINE
	~/ipoc/bin/v30-awr2ipoc.sh $LINE
done
