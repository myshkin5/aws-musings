#!/usr/bin/env bash

set -e -x

SCRIPTS_DIR=$(dirname $0)

trap "exit 1" TERM
export TOP_PID=$$

run-and-check() {
    VARS=$($*)
    if [[ $? != 0 ]] ; then
        kill -s TERM $TOP_PID
    fi
    echo $VARS
}

eval $(run-and-check $SCRIPTS_DIR/create-vpc.sh $@)
eval $(run-and-check $SCRIPTS_DIR/create-public-infrastructure.sh $@)
eval $(run-and-check $SCRIPTS_DIR/create-private-infrastructure.sh $@)
