#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..
TMP_DIR=$PROJECT_DIR/tmp

source $PROJECT_DIR/scripts/cf-utils.sh $@

if [[ $ELASTICSEARCH_INSTANCE_NAME == "" ]] ; then
    ELASTICSEARCH_INSTANCE_NAME=$(jq -r .Parameters.ElasticsearchInstanceName.Default $TMP_DIR/new/elasticsearch/elasticsearch.template)
fi
if [[ $DNS_ZONE == "" ]] ; then
    DNS_ZONE=dev
fi
if [[ $FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE == "" ]] ; then
    FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE=$(jq -r .Parameters.FullyQualifiedInternalParentDNSZone.Default \
        $TMP_DIR/new/infrastructure/public-infrastructure.template)
fi
if [[ $INTERNAL_KEY_NAME == "" ]] ; then
    INTERNAL_KEY_NAME=$(jq -r .Parameters.InternalKeyName.Default \
        $TMP_DIR/new/infrastructure/public-infrastructure.template)
fi
if [[ $ELASTICSEARCH_IMAGE_ID == "" ]] ; then
    ELASTICSEARCH_IMAGE_ID=ami-fce3c696
fi
if [[ $ELASTICSEARCH_INSTANCE_TYPE == "" ]] ; then
    ELASTICSEARCH_INSTANCE_TYPE=c3.large
fi
if [[ $ELASTICSEARCH_SPOT_PRICE == "" ]] ; then
    ELASTICSEARCH_SPOT_PRICE=0.024
fi

STACK_NAME=$STACK_PREFIX-$ELASTICSEARCH_INSTANCE_NAME

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/elasticsearch/elasticsearch.template \
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
