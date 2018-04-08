#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$StackPrefix-infrastructure-external-dns

update-stack $1 --template-url $AWSMusingsS3URL/infrastructure/external-dns.yml \
    --parameters ParameterKey=FullyQualifiedExternalParentDNSZone,ParameterValue=$FullyQualifiedExternalParentDNSZone \
        ParameterKey=StackEnv,ParameterValue=$StackEnv \
        ParameterKey=VPCId,ParameterValue=$VPCId

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export ExternalHostedZoneId=$(get-output-value ExternalHostedZoneId)"
    echo "export ExternalHostedZoneNameServers=\"$(get-output-value ExternalHostedZoneNameServers)\""
    echo "export FullyQualifiedExternalDNSZone=$(get-output-value FullyQualifiedExternalDNSZone)"
fi
