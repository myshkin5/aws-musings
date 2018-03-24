#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_ORG-$STACK_ENV-infrastructure-vpc

if [[ $CIDR_BLOCK == "" ]] ; then
    CIDR_BLOCK=$(yq r $(dirname $0)/../vpc.yml Parameters.CIDRBlock.Default)
fi

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/vpc.yml \
    --parameters ParameterKey=CIDRBlock,ParameterValue=$CIDR_BLOCK

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export VPC_ID=$(get-output-value VPCId)"
fi
