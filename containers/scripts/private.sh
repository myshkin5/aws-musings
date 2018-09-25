#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh

STACK_NAME=$StackPrefix-containers-private

if [[ $ContainersPrivateSubnetACIDRBlock == "" ]] ; then
    ContainersPrivateSubnetACIDRBlock=$(yq r $(dirname $0)/../private.yml \
        Parameters.ContainersPrivateSubnetACIDRBlock.Default)
fi
if [[ $ContainersPrivateSubnetBCIDRBlock == "" ]] ; then
    ContainersPrivateSubnetBCIDRBlock=$(yq r $(dirname $0)/../private.yml \
        Parameters.ContainersPrivateSubnetBCIDRBlock.Default)
fi
if [[ $ContainersPrivateSubnetCCIDRBlock == "" ]] ; then
    ContainersPrivateSubnetCCIDRBlock=$(yq r $(dirname $0)/../private.yml \
        Parameters.ContainersPrivateSubnetCCIDRBlock.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/containers/private.yml \
    --parameters ParameterKey=ContainersPrivateSubnetACIDRBlock,ParameterValue=$ContainersPrivateSubnetACIDRBlock \
        ParameterKey=ContainersPrivateSubnetBCIDRBlock,ParameterValue=$ContainersPrivateSubnetBCIDRBlock \
        ParameterKey=ContainersPrivateSubnetCCIDRBlock,ParameterValue=$ContainersPrivateSubnetCCIDRBlock \
        ParameterKey=ContainersPrivateSubnetAIPv6CIDRBlock,ParameterValue=$ContainersPrivateSubnetAIPv6CIDRBlock \
        ParameterKey=ContainersPrivateSubnetBIPv6CIDRBlock,ParameterValue=$ContainersPrivateSubnetBIPv6CIDRBlock \
        ParameterKey=ContainersPrivateSubnetCIPv6CIDRBlock,ParameterValue=$ContainersPrivateSubnetCIPv6CIDRBlock \
        ParameterKey=NetworkACLId,ParameterValue=$NetworkACLId \
        ParameterKey=PrivateRouteTableId,ParameterValue=$PrivateRouteTableId \
        ParameterKey=VPCId,ParameterValue=$VPCId

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export ContainersPrivateSubnetAId=$(get-output-value ContainersPrivateSubnetAId)"
    echo "export ContainersPrivateSubnetBId=$(get-output-value ContainersPrivateSubnetBId)"
    echo "export ContainersPrivateSubnetCId=$(get-output-value ContainersPrivateSubnetCId)"
    echo "export PrivateLoadBalancerDNSName=$(get-output-value PrivateLoadBalancerDNSName)"
    echo "export PrivateLoadBalancerCanonicalHostedZoneId=$(get-output-value PrivateLoadBalancerCanonicalHostedZoneId)"
    echo "export PrivateLoadBalancerListenerARN=$(get-output-value PrivateLoadBalancerListenerARN)"
fi
