#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$StackPrefix-api-gateway-with-lambda

update-stack $1 --template-url $AWSMusingsS3URL/api-gateway-developer-guide/call-lambda-synchronously/api-gateway-with-lambda.yml
