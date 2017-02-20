#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

if [[ $ELASTICSEARCH_INSTANCE_NAME == "" ]] ; then
    ELASTICSEARCH_INSTANCE_NAME=$(cat $(dirname $0)/../elasticsearch.yml \
        | shyaml get-value Parameters.ElasticsearchInstanceName.Default)
fi
if [[ $DNS_ZONE == "" ]] ; then
    DNS_ZONE=dev
fi
if [[ $FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE == "" ]] ; then
    FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE=$(cat $PROJECT_DIR/infrastructure/public-infrastructure.yml \
        | shyaml get-value Parameters.FullyQualifiedInternalParentDNSZone.Default)
fi
if [[ $INTERNAL_KEY_NAME == "" ]] ; then
    INTERNAL_KEY_NAME=$(cat $PROJECT_DIR/infrastructure/public-infrastructure.yml \
        | shyaml get-value Parameters.InternalKeyName.Default)
fi
if [[ $ELASTICSEARCH_IMAGE_ID == "" ]] ; then
    ELASTICSEARCH_IMAGE_ID=ami-6edd3078
fi
if [[ $ELASTICSEARCH_INSTANCE_TYPE == "" ]] ; then
    ELASTICSEARCH_INSTANCE_TYPE=c3.large
fi
if [[ $ELASTICSEARCH_SPOT_PRICE == "" ]] ; then
    ELASTICSEARCH_SPOT_PRICE=0.024
fi

STACK_NAME=$STACK_PREFIX-$ELASTICSEARCH_INSTANCE_NAME

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/elasticsearch/elasticsearch.yml \
    --parameters ParameterKey=AWSMusingsS3URL,ParameterValue=$AWS_MUSINGS_S3_URL \
        ParameterKey=ElasticsearchImageId,ParameterValue=$ELASTICSEARCH_IMAGE_ID \
        ParameterKey=ElasticsearchInstanceName,ParameterValue=$ELASTICSEARCH_INSTANCE_NAME \
        ParameterKey=ElasticsearchInstanceSecurityGroupId,ParameterValue=$ELASTICSEARCH_INSTANCE_SECURITY_GROUP_ID \
        ParameterKey=ElasticsearchInstanceType,ParameterValue=$ELASTICSEARCH_INSTANCE_TYPE \
        ParameterKey=ElasticsearchPrivateSubnetId,ParameterValue=$ELASTICSEARCH_PRIVATE_SUBNET_ID \
        ParameterKey=ElasticsearchSpotPrice,ParameterValue=$ELASTICSEARCH_SPOT_PRICE \
        ParameterKey=DNSZone,ParameterValue=$DNS_ZONE \
        ParameterKey=FullyQualifiedInternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE \
        ParameterKey=InternalKeyName,ParameterValue=$INTERNAL_KEY_NAME \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion
