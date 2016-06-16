#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..
TMP_DIR=$PROJECT_DIR/tmp

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-api-gateway-with-lambda

if [[ $LAMBDA_IAM_ROLE == "" ]] ; then
    LAMBDA_IAM_ROLE=$(jq -r .Parameters.BOSHLiteInstanceName.Default $TMP_DIR/new/api-gateway-developer-guide/call-lambda-synchronously/api-gateway-with-lambda.template)
fi

aws cloudformation update-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/api-gateway-developer-guide/call-lambda-synchronously/api-gateway-with-lambda.template \
    --profile $PROFILE > /dev/null

wait-for-stack-completion
