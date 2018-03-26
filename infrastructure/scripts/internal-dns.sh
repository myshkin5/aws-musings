#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-infrastructure-internal-dns

if [[ $INTERNAL_DNS_ZONE == "" ]] ; then
    INTERNAL_DNS_ZONE=$(yq r $(dirname $0)/../internal-dns.yml Parameters.InternalDNSZone.Default)
fi

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/internal-dns.yml \
    --parameters ParameterKey=FullyQualifiedExternalDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_DNS_ZONE \
        ParameterKey=InternalDNSZone,ParameterValue=$INTERNAL_DNS_ZONE \
        ParameterKey=VPCId,ParameterValue=$VPC_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export FULLY_QUALIFIED_INTERNAL_DNS_ZONE=$(get-output-value FullyQualifiedInternalDNSZone)"
    echo "export INTERNAL_HOSTED_ZONE_ID=$(get-output-value InternalHostedZoneId)"
fi
