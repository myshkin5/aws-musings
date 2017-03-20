#!/bin/bash

if [[ $# != 1 ]] ; then
    >&2 echo "Usage: $0 <client id>"
    exit -1
fi

ROOT=`dirname $0`

cd $ROOT

CLIENT_ID=$1

for (( x=0 ; x<9 ; x++ )) ; do
    (( y=$x+1 ))
    ./processor.sh $CLIENT_ID $x $y >> log/$HOSTNAME-$CLIENT_ID-$x.log 2>&1 &
done
