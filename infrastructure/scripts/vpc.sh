#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-infrastructure-vpc

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/vpc.yml \
    --parameters ParameterKey=SecondOctet,ParameterValue=$SECOND_OCTET

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export VPC_ID=$(get-output-value VPCId)"
fi
