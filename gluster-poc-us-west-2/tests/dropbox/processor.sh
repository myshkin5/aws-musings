#!/bin/bash

if [[ $# != 3 ]] ; then
    echo "Usage: $0 <client id> <consume queue> <produce queue>"
    exit -1
fi

CLIENT_ID=$HOSTNAME-$1
CONSUME=$2
PRODUCE=$3

ROOT=`dirname $0`

cd $ROOT/$CONSUME

while `true` ; do
    if [ -f ../exit ] ; then
        echo "`date` - Exiting"
        exit 0
    fi

    file=`ls -tr target | head -1`
    if [ -f target/$file ] ; then
        mv target/$file processing/$CLIENT_ID-$file 2> /dev/null
        if [ -f processing/$CLIENT_ID-$file ] ; then
            echo "`date` - Processing $file"
            cp processing/$CLIENT_ID-$file ../$PRODUCE/working/$file
            mv ../$PRODUCE/working/$file ../$PRODUCE/target/
            rm processing/$CLIENT_ID-$file
        else
            sleep 0.3
        fi
    else
        sleep 0.3
    fi
done
