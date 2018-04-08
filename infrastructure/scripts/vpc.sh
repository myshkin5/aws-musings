#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$StackPrefix-infrastructure-vpc

if [[ $CIDRBlock == "" ]] ; then
    CIDRBlock=$(yq r $(dirname $0)/../vpc.yml Parameters.CIDRBlock.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/infrastructure/vpc.yml \
    --parameters ParameterKey=CIDRBlock,ParameterValue=$CIDRBlock

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export VPCId=$(get-output-value VPCId)"
fi
