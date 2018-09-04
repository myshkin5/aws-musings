#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh

STACK_NAME=$StackPrefix-containers-test-forwarder-service

if [[ $LoadBalancerListenerPriority == "" ]] ; then
    LoadBalancerListenerPriority=$(yq r $(dirname $0)/../forwarder/service.yml \
        Parameters.LoadBalancerListenerPriority.Default)
fi

if [[ $Message == "" ]] ; then
    Message=$(yq r $(dirname $0)/../forwarder/service.yml Parameters.Message.Default)
fi
if [[ $ForwardToUrl == "" ]] ; then
    ForwardToUrl=$(yq r $(dirname $0)/../endpoint/service.yml Parameters.ForwardToUrl.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/containers/tests/forwarder/service.yml \
    --parameters ParameterKey=ServiceName,ParameterValue=$ServiceName \
        ParameterKey=Message,ParameterValue=$Message \
        ParameterKey=ForwardToUrl,ParameterValue=$ForwardToUrl \
        ParameterKey=ContainersSubnetAId,ParameterValue=$ContainersPublicSubnetAId \
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
