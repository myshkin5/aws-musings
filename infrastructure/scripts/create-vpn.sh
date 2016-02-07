#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-vpn

if [[ $BGP_AS_NUMBER == "" ]] ; then
    SECOND_OCTET=$(jq -r .Parameters.BGPASNumber.Default $(dirname $0)/../vpn.template)
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $S3_URL/infrastructure/vpn.template \
    --parameters ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=BGPASNumber,ParameterValue=$BGP_AS_NUMBER \
        ParameterKey=CustomerGatewayIPAddress,ParameterValue=$CUSTOMER_GATEWAY_IP_ADDRESS \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export VPN_GATEWAY_ID=$(get-output-value VPNGatewayId)"
