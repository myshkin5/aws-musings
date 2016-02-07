#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-public

if [[ $FULLY_QUALIFIED_EXTERNAL_PARENT_DNS_ZONE == "" ]] ; then
    FULLY_QUALIFIED_EXTERNAL_PARENT_DNS_ZONE=vkzone.net
fi
if [[ $JUMP_BOX_KEY_NAME == "" ]] ; then
    JUMP_BOX_KEY_NAME=$(jq -r .Parameters.JumpBoxKeyName.Default $(dirname $0)/../public-infrastructure.template)
fi
if [[ $JUMP_BOX_SSH_CIDR_IP == "" ]] ; then
    JUMP_BOX_SSH_CIDR_IP=50.183.202.137/32
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $S3_URL/infrastructure/public-infrastructure.template \
    --parameters ParameterKey=DNSZone,ParameterValue=$DNS_ZONE \
        ParameterKey=FullyQualifiedInternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE \
        ParameterKey=FullyQualifiedExternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_PARENT_DNS_ZONE \
        ParameterKey=SecondOctet,ParameterValue=$SECOND_OCTET \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=JumpBoxEIPAddress,ParameterValue=$JUMP_BOX_EIP_ADDRESS \
        ParameterKey=JumpBoxKeyName,ParameterValue=$JUMP_BOX_KEY_NAME \
        ParameterKey=JumpBoxSSHCIDRIP,ParameterValue=$JUMP_BOX_SSH_CIDR_IP \
        ParameterKey=InternalKeyName,ParameterValue=$INTERNAL_KEY_NAME \
        ParameterKey=VPNGatewayId,ParameterValue=$VPN_GATEWAY_ID \
        ParameterKey=AWSMusingsS3URL,ParameterValue=$S3_URL \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export JUMP_BOX_PUBLIC_IP_ADDRESS=$(get-output-value JumpBoxPublicIPAddress)"
echo "export NETWORK_ACL_ID=$(get-output-value NetworkACLId)"
echo "export NAT_INSTANCE_ID=$(get-output-value NATInstanceId)"
