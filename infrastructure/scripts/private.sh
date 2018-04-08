#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$StackPrefix-infrastructure-private

update-stack $1 --template-url $AWSMusingsS3URL/infrastructure/private.yml \
    --parameters ParameterKey=NATInstanceId,ParameterValue=$NATInstanceId \
        ParameterKey=EgressOnlyInternetGatewayId,ParameterValue=$EgressOnlyInternetGatewayId \
        ParameterKey=VPCId,ParameterValue=$VPCId \
        ParameterKey=IPv6CIDRBlock,ParameterValue=$IPv6CIDRBlock \
        ParameterKey=VPNGatewayId,ParameterValue=$VPNGatewayId

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export PrivateRouteTableId=$(get-output-value PrivateRouteTableId)"
fi
