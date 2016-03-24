#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-bosh-lite-infrastructure

if [[ $BOSH_LITE_AVAILABILITY_ZONE == "" ]] ; then
    BOSH_LITE_AVAILABILITY_ZONE=$(jq -r .Parameters.BOSHLiteAvailabilityZone.Default \
        $(dirname $0)/../bosh-lite-infrastructure.template)
fi
if [[ $BOSH_LITE_PUBLIC_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    BOSH_LITE_PUBLIC_THREE_OCTET_CIDR_BLOCK=$(jq -r .Parameters.BOSHLitePublicThreeOctetCIDRBlock.Default \
        $(dirname $0)/../bosh-lite-infrastructure.template)
fi
if [[ $BOSH_LITE_PRIVATE_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    BOSH_LITE_PRIVATE_THREE_OCTET_CIDR_BLOCK=$(jq -r .Parameters.BOSHLitePrivateThreeOctetCIDRBlock.Default \
        $(dirname $0)/../bosh-lite-infrastructure.template)
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $S3_URL/bosh-lite/bosh-lite-infrastructure.template \
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
