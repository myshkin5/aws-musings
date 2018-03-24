#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_ORG-$STACK_ENV-infrastructure-internal-dns

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/internal-dns.yml \
    --parameters ParameterKey=FullyQualifiedExternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_PARENT_DNS_ZONE \
        ParameterKey=InternalDNSZone,ParameterValue=$INTERNAL_DNS_ZONE \
        ParameterKey=StackEnv,ParameterValue=$STACK_ENV \
        ParameterKey=VPCId,ParameterValue=$VPC_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export INTERNAL_HOSTED_ZONE_ID=$(get-output-value InternalHostedZoneId)"
fi
