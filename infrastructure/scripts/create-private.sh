#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-infrastructure-private

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/infrastructure/private.yml \
    --parameters ParameterKey=NetworkACLId,ParameterValue=$NETWORK_ACL_ID \
        ParameterKey=NATInstanceId,ParameterValue=$NAT_INSTANCE_ID \
        ParameterKey=EgressOnlyInternetGatewayId,ParameterValue=$EGRESS_ONLY_INTERNET_GATEWAY_ID \
        ParameterKey=SecondOctet,ParameterValue=$SECOND_OCTET \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=VPCIPv656CIDRPrefix,ParameterValue=$VPC_IPV6_56_CIDR_PREFIX \
        ParameterKey=VPNGatewayId,ParameterValue=$VPN_GATEWAY_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export PRIVATE_ROUTE_TABLE_ID=$(get-output-value PrivateRouteTableId)"
