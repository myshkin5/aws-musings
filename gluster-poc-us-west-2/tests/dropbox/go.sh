#!/bin/bash

if [[ $# != 2 ]] ; then
    >&2 echo "Usage: $0 <file> <count>"
    exit -1
fi

ROOT=`dirname $0`

FILE=$1
COUNT=$2

if [[ ! -f $FILE ]] ; then
    >&2 echo "$FILE not found"
    >&2 echo "Usage: $0 <file> <count>"
    exit -2
fi

md5sum $FILE

START=`date +%s`

for (( x=0 ; x<$COUNT ; x++ )) ; do
    cp $FILE $ROOT/1/working/$START-$x
    mv $ROOT/1/working/$START-$x $ROOT/1/target/
done

echo "Waiting..."

FOUND=0
DONE=0

while (( $FOUND < $COUNT )) ; do
    for x in `ls $ROOT/9/target/$START-* 2> /dev/null` ; do
        md5sum $x
        (( FOUND++ ))
        rm $x
    done

    sleep 1
done

(( DURATION=`date +%s`-$START ))
echo "$DURATION seconds"
