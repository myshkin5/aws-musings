#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-elasticsearch-infrastructure

if [[ $ELASTICSEARCH_AVAILABILITY_ZONE == "" ]] ; then
    ELASTICSEARCH_AVAILABILITY_ZONE=$(yq r $(dirname $0)/../elasticsearch-infrastructure.yml \
        Parameters.ElasticsearchAvailabilityZone.Default)
fi
if [[ $ELASTICSEARCH_PRIVATE_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    ELASTICSEARCH_PRIVATE_THREE_OCTET_CIDR_BLOCK=$(yq r $(dirname $0)/../elasticsearch-infrastructure.yml \
        Parameters.ElasticsearchPrivateThreeOctetCIDRBlock.Default)
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/elasticsearch/elasticsearch-infrastructure.yml \
    --parameters ParameterKey=ElasticsearchAvailabilityZone,ParameterValue=$ELASTICSEARCH_AVAILABILITY_ZONE \
        ParameterKey=ElasticsearchPrivateThreeOctetCIDRBlock,ParameterValue=$ELASTICSEARCH_PRIVATE_THREE_OCTET_CIDR_BLOCK \
        ParameterKey=NetworkACLId,ParameterValue=$NETWORK_ACL_ID \
        ParameterKey=PrivateRouteTableId,ParameterValue=$PRIVATE_ROUTE_TABLE_ID \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export ELASTICSEARCH_INSTANCE_SECURITY_GROUP_ID=$(get-output-value ElasticsearchInstanceSecurityGroupId)"
echo "export ELASTICSEARCH_PRIVATE_SUBNET_ID=$(get-output-value ElasticsearchPrivateSubnetId)"
