#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-infrastructure-external-dns

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/infrastructure/external-dns.yml \
    --parameters ParameterKey=FullyQualifiedExternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_PARENT_DNS_ZONE \
        ParameterKey=StackEnv,ParameterValue=$STACK_ENV \
        ParameterKey=VPCId,ParameterValue=$VPC_ID

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

    echo "export EXTERNAL_HOSTED_ZONE_ID=$(get-output-value ExternalHostedZoneId)"
    echo "export FULLY_QUALIFIED_EXTERNAL_DNS_ZONE=$(get-output-value FullyQualifiedExternalDNSZone)"
fi
