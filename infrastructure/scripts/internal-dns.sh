#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-infrastructure-internal-dns

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/internal-dns.yml \
    --parameters ParameterKey=FullyQualifiedInternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE \
        ParameterKey=VPCId,ParameterValue=$VPC_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export INTERNAL_HOSTED_ZONE_ID=$(get-output-value InternalHostedZoneId)"
fi
