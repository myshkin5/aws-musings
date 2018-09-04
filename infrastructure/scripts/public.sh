#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh

STACK_NAME=$StackPrefix-infrastructure-public

if [[ $JumpBoxKeyName == "" ]] ; then
    JumpBoxKeyName=$(yq r $(dirname $0)/../public.yml Parameters.JumpBoxKeyName.Default)
fi
if [[ $JumpBoxSSHCIDRIP == "" ]] ; then
    JumpBoxSSHCIDRIP=$(dig +short myip.opendns.com @resolver1.opendns.com)/32
    >&2 echo "WARNING: ssh to the jump box will only be accessible from the current public IP address ($JumpBoxSSHCIDRIP)."
    >&2 echo "  Set JumpBoxSSHCIDRIP to restrict access."
fi
if [[ $JumpBoxInstanceType == "" ]] ; then
    JumpBoxInstanceType=$(yq r $(dirname $0)/../public.yml Parameters.JumpBoxInstanceType.Default)
fi

if [[ $PublicSubnetACIDRBlock == "" ]] ; then
    PublicSubnetACIDRBlock=$(yq r $(dirname $0)/../public.yml Parameters.PublicSubnetACIDRBlock.Default)
fi
if [[ $PublicSubnetBCIDRBlock == "" ]] ; then
    PublicSubnetBCIDRBlock=$(yq r $(dirname $0)/../public.yml Parameters.PublicSubnetBCIDRBlock.Default)
fi
if [[ $PublicSubnetCCIDRBlock == "" ]] ; then
    PublicSubnetCCIDRBlock=$(yq r $(dirname $0)/../public.yml Parameters.PublicSubnetCCIDRBlock.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/infrastructure/public.yml \
    --parameters ParameterKey=AWSMusingsS3URL,ParameterValue=$AWSMusingsS3URL \
        ParameterKey=ExternalHostedZoneId,ParameterValue=$ExternalHostedZoneId \
        ParameterKey=FullyQualifiedExternalDNSZone,ParameterValue=$FullyQualifiedExternalDNSZone \
        ParameterKey=FullyQualifiedInternalDNSZone,ParameterValue=$FullyQualifiedInternalDNSZone \
        ParameterKey=InternalAccessCIDRBlock,ParameterValue=$InternalAccessCIDRBlock \
        ParameterKey=InternalAccessIPv6CIDRBlock,ParameterValue=$InternalAccessIPv6CIDRBlock \
        ParameterKey=InternalHostedZoneId,ParameterValue=$InternalHostedZoneId \
        ParameterKey=InternalKeyName,ParameterValue=$InternalKeyName \
        ParameterKey=JumpBoxEIPAddress,ParameterValue=$JumpBoxEIPAddress \
        ParameterKey=JumpBoxKeyName,ParameterValue=$JumpBoxKeyName \
        ParameterKey=JumpBoxSSHCIDRIP,ParameterValue=$JumpBoxSSHCIDRIP \
        ParameterKey=JumpBoxInstanceType,ParameterValue=$JumpBoxInstanceType \
        ParameterKey=PublicSubnetACIDRBlock,ParameterValue=$PublicSubnetACIDRBlock \
        ParameterKey=PublicSubnetBCIDRBlock,ParameterValue=$PublicSubnetBCIDRBlock \
        ParameterKey=PublicSubnetCCIDRBlock,ParameterValue=$PublicSubnetCCIDRBlock \
        ParameterKey=PublicSubnetAIPv6CIDRBlock,ParameterValue=$PublicSubnetAIPv6CIDRBlock \
        ParameterKey=PublicSubnetBIPv6CIDRBlock,ParameterValue=$PublicSubnetBIPv6CIDRBlock \
        ParameterKey=PublicSubnetCIPv6CIDRBlock,ParameterValue=$PublicSubnetCIPv6CIDRBlock \
        ParameterKey=VPCId,ParameterValue=$VPCId \
        ParameterKey=VPNGatewayId,ParameterValue=$VPNGatewayId

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export JumpBoxPublicIPAddress=$(get-output-value JumpBoxPublicIPAddress)"
    echo "export NetworkACLId=$(get-output-value NetworkACLId)"
    echo "export NATInstanceId=$(get-output-value NATInstanceId)"
    echo "export EgressOnlyInternetGatewayId=$(get-output-value EgressOnlyInternetGatewayId)"
    echo "export PublicRouteTableId=$(get-output-value PublicRouteTableId)"
fi
