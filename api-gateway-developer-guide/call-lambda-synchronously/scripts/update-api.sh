#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-api-gateway-with-lambda

if [[ $LAMBDA_IAM_ROLE == "" ]] ; then
    LAMBDA_IAM_ROLE=$(cat $(dirname $0)/../api-gateway-with-lambda.yml \
        | shyaml get-value Parameters.BOSHLiteInstanceName.Default)
fi

aws cloudformation update-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/api-gateway-developer-guide/call-lambda-synchronously/api-gateway-with-lambda.yml \
    --profile $PROFILE > /dev/null

wait-for-stack-completion
