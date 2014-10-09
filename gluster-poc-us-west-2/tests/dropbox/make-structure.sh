#!/bin/bash

ROOT=`dirname $0`

cd $ROOT

mkdir log

for (( x=0 ; x<10 ; x++ )) ; do
    mkdir $x
    mkdir $x/working
    mkdir $x/target
    mkdir $x/processing
done
