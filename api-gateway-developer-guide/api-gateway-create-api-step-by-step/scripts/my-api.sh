#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-my-api

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/api-gateway-developer-guide/api-gateway-create-api-step-by-step/my-api.yml
