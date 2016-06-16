#!/usr/bin/env bash

set -e

source $(dirname $0)/../../../scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-api-gateway-with-lambda

delete-stack
