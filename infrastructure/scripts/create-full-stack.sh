#!/usr/bin/env bash

set -e

SCRIPTS_DIR=$(dirname $0)

trap "exit 1" TERM
export TOP_PID=$$

run-and-check() {
    >&2 echo "Executing $*..."
    VARS=$($*)
    if [[ $? != 0 ]] ; then
        kill -s TERM $TOP_PID
    fi
    echo $VARS
    >&2 echo "Complete. Generated output:"
    >&2 echo $VARS
    >&2 echo
}

>&2 echo -e "\033[1m\033[42m Starting...   \033[0m"

eval $(run-and-check $SCRIPTS_DIR/create-vpc.sh $@)
eval $(run-and-check $SCRIPTS_DIR/create-internal-dns.sh $@)
eval $(run-and-check $SCRIPTS_DIR/create-public-infrastructure.sh $@)
eval $(run-and-check $SCRIPTS_DIR/create-private-infrastructure.sh $@)

>&2 echo -e "\033[1m\033[42m Complete.     \033[0m"
