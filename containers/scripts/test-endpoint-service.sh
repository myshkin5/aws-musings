#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$StackPrefix-containers-test-endpoint-service

if [[ $LoadBalancerListenerPriority == "" ]] ; then
    LoadBalancerListenerPriority=$(yq r $(dirname $0)/../tests/endpoint/service.yml \
        Parameters.LoadBalancerListenerPriority.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/containers/tests/endpoint/service.yml \
    --parameters ParameterKey=ContainersSubnetAId,ParameterValue=$ContainersPublicSubnetAId \
        ParameterKey=ContainersSubnetBId,ParameterValue=$ContainersPublicSubnetBId \
        ParameterKey=ContainersSubnetCId,ParameterValue=$ContainersPublicSubnetCId \
        ParameterKey=ClusterARN,ParameterValue=$PublicClusterARN \
        ParameterKey=LoadBalancerDNSName,ParameterValue=$PublicLoadBalancerDNSName \
        ParameterKey=LoadBalancerCanonicalHostedZoneId,ParameterValue=$PublicLoadBalancerCanonicalHostedZoneId \
        ParameterKey=LoadBalancerListenerARN,ParameterValue=$PublicLoadBalancerListenerARN \
        ParameterKey=LoadBalancerListenerPriority,ParameterValue=$LoadBalancerListenerPriority \
        ParameterKey=HostedZoneId,ParameterValue=$ExternalHostedZoneId \
        ParameterKey=FullyQualifiedDNSZone,ParameterValue=$FullyQualifiedExternalDNSZone \
        ParameterKey=VPCId,ParameterValue=$VPCId \
        ParameterKey=StackPrefix,ParameterValue=$StackPrefix

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

fi
