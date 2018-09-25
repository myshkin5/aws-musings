#!/usr/bin/env bash

set -e

SCRIPTS_DIR=$(dirname $0)

trap "exit 1" TERM
export TOP_PID=$$

run-and-check() {
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

eval $(run-and-check $SCRIPTS_DIR/vpc.sh create)
eval $(run-and-check $SCRIPTS_DIR/external-dns.sh create)
eval $(run-and-check $SCRIPTS_DIR/internal-dns.sh create)
eval $(run-and-check $SCRIPTS_DIR/public.sh create)
eval $(run-and-check $SCRIPTS_DIR/private.sh create)

>&2 echo -e "\033[1m\033[42m Complete.     \033[0m"
