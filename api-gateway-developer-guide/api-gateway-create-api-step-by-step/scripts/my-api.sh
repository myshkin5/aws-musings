#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$StackPrefix-my-api

update-stack $1 --template-url $AWSMusingsS3URL/api-gateway-developer-guide/api-gateway-create-api-step-by-step/my-api.yml
