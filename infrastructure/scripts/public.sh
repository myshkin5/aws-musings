#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-infrastructure-public

if [[ $JUMP_BOX_KEY_NAME == "" ]] ; then
    JUMP_BOX_KEY_NAME=$(yq r $(dirname $0)/../public.yml Parameters.JumpBoxKeyName.Default)
fi
if [[ $JUMP_BOX_SSH_CIDR_IP == "" ]] ; then
    JUMP_BOX_SSH_CIDR_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)/32
    >&2 echo "WARNING: ssh to the jump box will only be accessible from the current public IP address ($JUMP_BOX_SSH_CIDR_IP)."
    >&2 echo "  Set JUMP_BOX_SSH_CIDR_IP to restrict access."
fi
if [[ $JUMP_BOX_INSTANCE_TYPE == "" ]] ; then
    JUMP_BOX_INSTANCE_TYPE=$(yq r $(dirname $0)/../public.yml Parameters.JumpBoxInstanceType.Default)
fi

if [[ $PUBLIC_SUBNET_A_CIDR_BLOCK == "" ]] ; then
    PUBLIC_SUBNET_A_CIDR_BLOCK=$(yq r $(dirname $0)/../public.yml Parameters.PublicSubnetACIDRBlock.Default)
fi
if [[ $PUBLIC_SUBNET_B_CIDR_BLOCK == "" ]] ; then
    PUBLIC_SUBNET_B_CIDR_BLOCK=$(yq r $(dirname $0)/../public.yml Parameters.PublicSubnetBCIDRBlock.Default)
fi
if [[ $PUBLIC_SUBNET_C_CIDR_BLOCK == "" ]] ; then
    PUBLIC_SUBNET_C_CIDR_BLOCK=$(yq r $(dirname $0)/../public.yml Parameters.PublicSubnetCCIDRBlock.Default)
fi

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/public.yml \
    --parameters ParameterKey=AWSMusingsS3URL,ParameterValue=$AWS_MUSINGS_S3_URL \
        ParameterKey=ExternalHostedZoneId,ParameterValue=$EXTERNAL_HOSTED_ZONE_ID \
        ParameterKey=FullyQualifiedExternalDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_DNS_ZONE \
        ParameterKey=FullyQualifiedInternalDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_DNS_ZONE \
        ParameterKey=InternalAccessCIDRBlock,ParameterValue=$INTERNAL_ACCESS_CIDR_BLOCK \
        ParameterKey=InternalAccessIPv6CIDRBlock,ParameterValue=$INTERNAL_ACCESS_IPV6_CIDR_BLOCK \
        ParameterKey=InternalHostedZoneId,ParameterValue=$INTERNAL_HOSTED_ZONE_ID \
        ParameterKey=InternalKeyName,ParameterValue=$INTERNAL_KEY_NAME \
        ParameterKey=JumpBoxEIPAddress,ParameterValue=$JUMP_BOX_EIP_ADDRESS \
        ParameterKey=JumpBoxKeyName,ParameterValue=$JUMP_BOX_KEY_NAME \
        ParameterKey=JumpBoxSSHCIDRIP,ParameterValue=$JUMP_BOX_SSH_CIDR_IP \
        ParameterKey=JumpBoxInstanceType,ParameterValue=$JUMP_BOX_INSTANCE_TYPE \
        ParameterKey=PublicSubnetACIDRBlock,ParameterValue=$PUBLIC_SUBNET_A_CIDR_BLOCK \
        ParameterKey=PublicSubnetBCIDRBlock,ParameterValue=$PUBLIC_SUBNET_B_CIDR_BLOCK \
        ParameterKey=PublicSubnetCCIDRBlock,ParameterValue=$PUBLIC_SUBNET_C_CIDR_BLOCK \
        ParameterKey=PublicSubnetAIPv6CIDRBlock,ParameterValue=$PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK \
        ParameterKey=PublicSubnetBIPv6CIDRBlock,ParameterValue=$PUBLIC_SUBNET_B_IPV6_CIDR_BLOCK \
        ParameterKey=PublicSubnetCIPv6CIDRBlock,ParameterValue=$PUBLIC_SUBNET_C_IPV6_CIDR_BLOCK \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=VPNGatewayId,ParameterValue=$VPN_GATEWAY_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export JUMP_BOX_PUBLIC_IP_ADDRESS=$(get-output-value JumpBoxPublicIPAddress)"
    echo "export NETWORK_ACL_ID=$(get-output-value NetworkACLId)"
    echo "export NAT_INSTANCE_ID=$(get-output-value NATInstanceId)"
    echo "export EGRESS_ONLY_INTERNET_GATEWAY_ID=$(get-output-value EgressOnlyInternetGatewayId)"
    echo "export PUBLIC_ROUTE_TABLE_ID=$(get-output-value PublicRouteTableId)"
fi
