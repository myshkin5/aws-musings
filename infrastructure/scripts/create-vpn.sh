#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-vpn

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/infrastructure/vpn.template \
    --parameters ParameterKey=BGPASNumber,ParameterValue=$BGP_AS_NUMBER \
        ParameterKey=CustomerGatewayIPAddress,ParameterValue=$CUSTOMER_GATEWAY_IP_ADDRESS \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export VPN_GATEWAY_ID=$(get-output-value VPNGatewayId)"
