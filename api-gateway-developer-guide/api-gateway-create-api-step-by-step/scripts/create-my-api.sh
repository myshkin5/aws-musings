#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-my-api

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/api-gateway-developer-guide/api-gateway-create-api-step-by-step/my-api.yml \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion
