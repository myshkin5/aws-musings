#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-containers-test-endpoint-service

if [[ $LOAD_BALANCER_LISTENER_PRIORITY == "" ]] ; then
    LOAD_BALANCER_LISTENER_PRIORITY=$(yq r $(dirname $0)/../tests/endpoint/service.yml \
        Parameters.LoadBalancerListenerPriority.Default)
fi

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/containers/tests/endpoint/service.yml \
    --parameters ParameterKey=ContainersSubnetAId,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_A_ID \
        ParameterKey=ContainersSubnetBId,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_B_ID \
        ParameterKey=ContainersSubnetCId,ParameterValue=$CONTAINERS_PUBLIC_SUBNET_C_ID \
        ParameterKey=ClusterARN,ParameterValue=$PUBLIC_CLUSTER_ARN \
        ParameterKey=LoadBalancerDNSName,ParameterValue=$PUBLIC_LOAD_BALANCER_DNS_NAME \
        ParameterKey=LoadBalancerCanonicalHostedZoneId,ParameterValue=$PUBLIC_LOAD_BALANCER_CANONICAL_HOSTED_ZONE_ID \
        ParameterKey=LoadBalancerListenerARN,ParameterValue=$PUBLIC_LOAD_BALANCER_LISTENER_ARN \
        ParameterKey=LoadBalancerListenerPriority,ParameterValue=$PUBLIC_LOAD_BALANCER_LISTENER_PRIORITY \
        ParameterKey=HostedZoneId,ParameterValue=$EXTERNAL_HOSTED_ZONE_ID \
        ParameterKey=FullyQualifiedDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_DNS_ZONE \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=StackPrefix,ParameterValue=$STACK_PREFIX

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

fi
