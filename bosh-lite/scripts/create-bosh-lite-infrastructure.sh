#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-bosh-lite-infrastructure

if [[ $BOSH_LITE_AVAILABILITY_ZONE == "" ]] ; then
    BOSH_LITE_AVAILABILITY_ZONE=$(yq r $(dirname $0)/../bosh-lite-infrastructure.yml \
        Parameters.BOSHLiteAvailabilityZone.Default)
fi
if [[ $BOSH_LITE_PUBLIC_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    BOSH_LITE_PUBLIC_THREE_OCTET_CIDR_BLOCK=$(yq r $(dirname $0)/../bosh-lite-infrastructure.yml \
        Parameters.BOSHLitePublicThreeOctetCIDRBlock.Default)
fi
if [[ $BOSH_LITE_PRIVATE_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    BOSH_LITE_PRIVATE_THREE_OCTET_CIDR_BLOCK=$(yq r $(dirname $0)/../bosh-lite-infrastructure.yml \
        Parameters.BOSHLitePrivateThreeOctetCIDRBlock.Default)
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/bosh-lite/bosh-lite-infrastructure.yml \
    --parameters ParameterKey=BOSHLiteAvailabilityZone,ParameterValue=$BOSH_LITE_AVAILABILITY_ZONE \
        ParameterKey=BOSHLitePublicThreeOctetCIDRBlock,ParameterValue=$BOSH_LITE_PUBLIC_THREE_OCTET_CIDR_BLOCK \
        ParameterKey=BOSHLitePrivateThreeOctetCIDRBlock,ParameterValue=$BOSH_LITE_PRIVATE_THREE_OCTET_CIDR_BLOCK \
        ParameterKey=NetworkACLId,ParameterValue=$NETWORK_ACL_ID \
        ParameterKey=PublicRouteTableId,ParameterValue=$PUBLIC_ROUTE_TABLE_ID \
        ParameterKey=PrivateRouteTableId,ParameterValue=$PRIVATE_ROUTE_TABLE_ID \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export BOSH_LITE_ELB_SECURITY_GROUP_ID=$(get-output-value BOSHLiteELBSecurityGroupId)"
echo "export BOSH_LITE_INSTANCE_SECURITY_GROUP_ID=$(get-output-value BOSHLiteInstanceSecurityGroupId)"
echo "export BOSH_LITE_PRIVATE_SUBNET_ID=$(get-output-value BOSHLitePrivateSubnetId)"
echo "export BOSH_LITE_PUBLIC_SUBNET_ID=$(get-output-value BOSHLitePublicSubnetId)"
