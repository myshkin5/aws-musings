#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh

STACK_NAME=$StackPrefix-containers-public

if [[ $ContainersPublicSubnetACIDRBlock == "" ]] ; then
    ContainersPublicSubnetACIDRBlock=$(yq r $(dirname $0)/../public.yml \
        Parameters.ContainersPublicSubnetACIDRBlock.Default)
fi
if [[ $ContainersPublicSubnetBCIDRBlock == "" ]] ; then
    ContainersPublicSubnetBCIDRBlock=$(yq r $(dirname $0)/../public.yml \
        Parameters.ContainersPublicSubnetBCIDRBlock.Default)
fi
if [[ $ContainersPublicSubnetCCIDRBlock == "" ]] ; then
    ContainersPublicSubnetCCIDRBlock=$(yq r $(dirname $0)/../public.yml \
        Parameters.ContainersPublicSubnetCCIDRBlock.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/containers/public.yml \
    --parameters ParameterKey=ContainersPublicSubnetACIDRBlock,ParameterValue=$ContainersPublicSubnetACIDRBlock \
        ParameterKey=ContainersPublicSubnetBCIDRBlock,ParameterValue=$ContainersPublicSubnetBCIDRBlock \
        ParameterKey=ContainersPublicSubnetCCIDRBlock,ParameterValue=$ContainersPublicSubnetCCIDRBlock \
        ParameterKey=ContainersPublicSubnetAIPv6CIDRBlock,ParameterValue=$ContainersPublicSubnetAIPv6CIDRBlock \
        ParameterKey=ContainersPublicSubnetBIPv6CIDRBlock,ParameterValue=$ContainersPublicSubnetBIPv6CIDRBlock \
        ParameterKey=ContainersPublicSubnetCIPv6CIDRBlock,ParameterValue=$ContainersPublicSubnetCIPv6CIDRBlock \
        ParameterKey=NetworkACLId,ParameterValue=$NetworkACLId \
        ParameterKey=PublicRouteTableId,ParameterValue=$PublicRouteTableId \
        ParameterKey=VPCId,ParameterValue=$VPCId

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export ContainersPublicSubnetAId=$(get-output-value ContainersPublicSubnetAId)"
    echo "export ContainersPublicSubnetBId=$(get-output-value ContainersPublicSubnetBId)"
    echo "export ContainersPublicSubnetCId=$(get-output-value ContainersPublicSubnetCId)"
    echo "export PublicClusterARN=$(get-output-value PublicClusterARN)"
    echo "export PublicLoadBalancerDNSName=$(get-output-value PublicLoadBalancerDNSName)"
    echo "export PublicLoadBalancerCanonicalHostedZoneId=$(get-output-value PublicLoadBalancerCanonicalHostedZoneId)"
    echo "export PublicLoadBalancerListenerARN=$(get-output-value PublicLoadBalancerListenerARN)"
fi
