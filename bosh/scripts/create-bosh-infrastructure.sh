#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-bosh-infrastructure

if [[ $MANAGEMENT_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    MANAGEMENT_THREE_OCTET_CIDR_BLOCK=$(jq -r .Parameters.ManagementThreeOctetCIDRBlock.Default \
        $(dirname $0)/../bosh-infrastructure.template)
fi
if [[ $THREE_OCTET_CIDR_BLOCK_A == "" ]] ; then
    THREE_OCTET_CIDR_BLOCK_A=$(jq -r .Parameters.ThreeOctetCIDRBlockA.Default \
        $(dirname $0)/../bosh-infrastructure.template)
fi
if [[ $THREE_OCTET_CIDR_BLOCK_B == "" ]] ; then
    THREE_OCTET_CIDR_BLOCK_B=$(jq -r .Parameters.ThreeOctetCIDRBlockB.Default \
        $(dirname $0)/../bosh-infrastructure.template)
fi
if [[ $THREE_OCTET_CIDR_BLOCK_C == "" ]] ; then
    THREE_OCTET_CIDR_BLOCK_C=$(jq -r .Parameters.ThreeOctetCIDRBlockC.Default \
        $(dirname $0)/../bosh-infrastructure.template)
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $S3_URL/bosh/bosh-infrastructure.template \
    --parameters ParameterKey=ManagementThreeOctetCIDRBlock,ParameterValue=$MANAGEMENT_THREE_OCTET_CIDR_BLOCK \
        ParameterKey=NetworkACLId,ParameterValue=$NETWORK_ACL_ID \
        ParameterKey=PrivateRouteTableId,ParameterValue=$PRIVATE_ROUTE_TABLE_ID \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=ThreeOctetCIDRBlockA,ParameterValue=$THREE_OCTET_CIDR_BLOCK_A \
        ParameterKey=ThreeOctetCIDRBlockB,ParameterValue=$THREE_OCTET_CIDR_BLOCK_B \
        ParameterKey=ThreeOctetCIDRBlockC,ParameterValue=$THREE_OCTET_CIDR_BLOCK_C \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export MANAGEMENT_SUBNET_ID=$(get-output-value ManagementSubnetId)"
echo "export BOSH_DIRECTOR_SECURITY_GROUP_ID=$(get-output-value BOSHDirectorSecurityGroupId)"
