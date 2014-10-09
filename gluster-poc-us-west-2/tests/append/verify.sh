#!/bin/bash

for x in `ls *.log` ; do
    sort $x | md5sum
done
