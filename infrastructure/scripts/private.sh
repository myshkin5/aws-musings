#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_ORG-$STACK_ENV-infrastructure-private

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/private.yml \
    --parameters ParameterKey=NATInstanceId,ParameterValue=$NAT_INSTANCE_ID \
        ParameterKey=EgressOnlyInternetGatewayId,ParameterValue=$EGRESS_ONLY_INTERNET_GATEWAY_ID \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=IPv6CIDRBlock,ParameterValue=$IPV6_CIDR_BLOCK \
        ParameterKey=VPNGatewayId,ParameterValue=$VPN_GATEWAY_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export PRIVATE_ROUTE_TABLE_ID=$(get-output-value PrivateRouteTableId)"
fi
