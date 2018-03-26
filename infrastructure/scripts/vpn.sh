#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-infrastructure-vpn

if [[ $BGP_AS_NUMBER == "" ]] ; then
    BGP_AS_NUMBER=$(yq r $(dirname $0)/../vpn.yml Parameters.BGPASNumber.Default)
fi

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/vpn.yml \
    --parameters ParameterKey=BGPASNumber,ParameterValue=$BGP_AS_NUMBER \
        ParameterKey=CustomerGatewayIPAddress,ParameterValue=$CUSTOMER_GATEWAY_IP_ADDRESS \
        ParameterKey=InternalAccessCIDRBlock,ParameterValue=$INTERNAL_ACCESS_CIDR_BLOCK \
        ParameterKey=VPCId,ParameterValue=$VPC_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export VPN_GATEWAY_ID=$(get-output-value VPNGatewayId)"
fi
