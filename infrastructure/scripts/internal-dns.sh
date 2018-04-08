#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$StackPrefix-infrastructure-internal-dns

if [[ $InternalDNSZone == "" ]] ; then
    InternalDNSZone=$(yq r $(dirname $0)/../internal-dns.yml Parameters.InternalDNSZone.Default)
fi

update-stack $1 --template-url $AWSMusingsS3URL/infrastructure/internal-dns.yml \
    --parameters ParameterKey=FullyQualifiedExternalDNSZone,ParameterValue=$FullyQualifiedExternalDNSZone \
        ParameterKey=InternalDNSZone,ParameterValue=$InternalDNSZone \
        ParameterKey=VPCId,ParameterValue=$VPCId

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export FullyQualifiedInternalDNSZone=$(get-output-value FullyQualifiedInternalDNSZone)"
    echo "export InternalHostedZoneId=$(get-output-value InternalHostedZoneId)"
fi
