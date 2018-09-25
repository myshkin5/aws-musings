#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh

STACK_NAME=$StackPrefix-containers-$ServiceName-service

if [[ $LoadBalancerListenerPriority == "" ]] ; then
    LoadBalancerListenerPriority=$(yq r $(dirname $0)/../forwarder/service.yml \
        Parameters.LoadBalancerListenerPriority.Default)
fi

if [[ $ForwardToUrl == "" ]] ; then
    ForwardToUrl=$(yq r $(dirname $0)/../forwarder/service.yml Parameters.ForwardToUrl.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/containers/tests/forwarder/service.yml \
    --parameters ParameterKey=ServiceName,ParameterValue=$ServiceName \
        ParameterKey=IsPublicService,ParameterValue=$IsPublicService \
        ParameterKey=ForwardToUrl,ParameterValue=$ForwardToUrl \
        ParameterKey=ContainersSubnetAId,ParameterValue=$ContainersSubnetAId \
        ParameterKey=ContainersSubnetBId,ParameterValue=$ContainersSubnetBId \
        ParameterKey=ContainersSubnetCId,ParameterValue=$ContainersSubnetCId \
        ParameterKey=ClusterARN,ParameterValue=$ClusterARN \
        ParameterKey=LoadBalancerDNSName,ParameterValue=$LoadBalancerDNSName \
        ParameterKey=LoadBalancerCanonicalHostedZoneId,ParameterValue=$LoadBalancerCanonicalHostedZoneId \
        ParameterKey=LoadBalancerListenerARN,ParameterValue=$LoadBalancerListenerARN \
        ParameterKey=LoadBalancerListenerPriority,ParameterValue=$LoadBalancerListenerPriority \
        ParameterKey=HostedZoneId,ParameterValue=$HostedZoneId \
        ParameterKey=FullyQualifiedDNSZone,ParameterValue=$FullyQualifiedDNSZone \
        ParameterKey=VPCId,ParameterValue=$VPCId \
        ParameterKey=StackPrefix,ParameterValue=$StackPrefix

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

fi
