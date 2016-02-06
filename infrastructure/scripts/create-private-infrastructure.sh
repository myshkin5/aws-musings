#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh

STACK_NAME=$STACK_PREFIX-private

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $S3_URL/infrastructure/private-infrastructure.template \
    --parameters ParameterKey=DNSZone,ParameterValue=$DNS_ZONE \
        ParameterKey=FullyQualifiedInternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE \
        ParameterKey=SecondOctet,ParameterValue=$SECOND_OCTET \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=InternalKeyName,ParameterValue=$INTERNAL_KEY_NAME \
        ParameterKey=NetworkACLId,ParameterValue=$NETWORK_ACL_ID \
        ParameterKey=NATInstanceId,ParameterValue=$NAT_INSTANCE_ID \
        ParameterKey=VPNGatewayId,ParameterValue=$VPN_GATEWAY_ID \
        ParameterKey=AWSMusingsS3URL,ParameterValue=$S3_URL \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion
