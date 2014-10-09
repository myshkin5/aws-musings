#!/bin/bash

if [[ $# != 1 ]] ; then
    echo "Usage: $0 <client id>"
    exit -1
fi

ROOT=`dirname $0`

cd $ROOT

CLIENT_ID=$1

while `true` ; do
    if [ -f wait ] ; then
        sleep 0.3
    else
        break
    fi
done

START=`date +%s`

for (( x=0 ; x<1000 ; x++ )) ; do
    for y in `shuf -i 0-9` ; do
        echo "$HOSTNAME-$CLIENT_ID `printf %05d $x`" >> $y.log
    done
done

(( DURATION=`date +%s`-$START ))
echo "$DURATION seconds"
