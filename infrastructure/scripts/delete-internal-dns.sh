#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-internal-dns

delete-stack
