#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$StackPrefix-infrastructure-vpn

if [[ $BGPASNumber == "" ]] ; then
    BGPASNumber=$(yq r $(dirname $0)/../vpn.yml Parameters.BGPASNumber.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/infrastructure/vpn.yml \
    --parameters ParameterKey=BGPASNumber,ParameterValue=$BGPASNumber \
        ParameterKey=CustomerGatewayIPAddress,ParameterValue=$CustomerGatewayIPAddress \
        ParameterKey=InternalAccessCIDRBlock,ParameterValue=$InternalAccessCIDRBlock \
        ParameterKey=VPCId,ParameterValue=$VPCId

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export VPNGatewayId=$(get-output-value VPNGatewayId)"
fi
