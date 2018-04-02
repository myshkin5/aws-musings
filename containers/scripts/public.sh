#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-containers-public

if [[ $CONTAINERS_PUBLIC_SUBNET_A_CIDR_BLOCK == "" ]] ; then
    CONTAINERS_PUBLIC_SUBNET_A_CIDR_BLOCK=$(yq r $(dirname $0)/../public.yml \
        Parameters.ContainersPublicSubnetACIDRBlock.Default)
fi
if [[ $CONTAINERS_PUBLIC_SUBNET_B_CIDR_BLOCK == "" ]] ; then
    CONTAINERS_PUBLIC_SUBNET_B_CIDR_BLOCK=$(yq r $(dirname $0)/../public.yml \
        Parameters.ContainersPublicSubnetBCIDRBlock.Default)
fi
if [[ $CONTAINERS_PUBLIC_SUBNET_C_CIDR_BLOCK == "" ]] ; then
    CONTAINERS_PUBLIC_SUBNET_C_CIDR_BLOCK=$(yq r $(dirname $0)/../public.yml \
        Parameters.ContainersPublicSubnetCCIDRBlock.Default)
fi

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/containers/public.yml \
    --parameters ParameterKey=ContainersPublicSubnetACIDRBlock,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_A_CIDR_BLOCK \
        ParameterKey=ContainersPublicSubnetBCIDRBlock,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_B_CIDR_BLOCK \
        ParameterKey=ContainersPublicSubnetCCIDRBlock,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_C_CIDR_BLOCK \
        ParameterKey=ContainersPublicSubnetAIPv6CIDRBlock,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK \
        ParameterKey=ContainersPublicSubnetBIPv6CIDRBlock,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_B_IPV6_CIDR_BLOCK \
        ParameterKey=ContainersPublicSubnetCIPv6CIDRBlock,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_C_IPV6_CIDR_BLOCK \
        ParameterKey=NetworkACLId,ParameterValue=$NETWORK_ACL_ID \
        ParameterKey=PublicRouteTableId,ParameterValue=$PUBLIC_ROUTE_TABLE_ID \
        ParameterKey=VPCId,ParameterValue=$VPC_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export CONTAINERS_PUBLIC_SUBNET_A_ID=$(get-output-value ContainersPublicSubnetAId)"
    echo "export CONTAINERS_PUBLIC_SUBNET_B_ID=$(get-output-value ContainersPublicSubnetBId)"
    echo "export CONTAINERS_PUBLIC_SUBNET_C_ID=$(get-output-value ContainersPublicSubnetCId)"
    echo "export PUBLIC_CLUSTER_ARN=$(get-output-value PublicClusterARN)"
    echo "export PUBLIC_LOAD_BALANCER_DNS_NAME=$(get-output-value PublicLoadBalancerDNSName)"
    echo "export PUBLIC_LOAD_BALANCER_CANONICAL_HOSTED_ZONE_ID=$(get-output-value PublicLoadBalancerCanonicalHostedZoneId)"
    echo "export PUBLIC_LOAD_BALANCER_LISTENER_ARN=$(get-output-value PublicLoadBalancerListenerARN)"
fi
