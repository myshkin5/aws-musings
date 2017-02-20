#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-bosh-infrastructure

if [[ $MANAGEMENT_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    MANAGEMENT_THREE_OCTET_CIDR_BLOCK=$(cat $(dirname $0)/../bosh-infrastructure.yml \
        | shyaml get-value Parameters.ManagementThreeOctetCIDRBlock.Default)
fi
if [[ $THREE_OCTET_CIDR_BLOCK_A == "" ]] ; then
    THREE_OCTET_CIDR_BLOCK_A=$(cat $(dirname $0)/../bosh-infrastructure.yml \
        | shyaml get-value Parameters.ThreeOctetCIDRBlockA.Default)
fi
if [[ $THREE_OCTET_CIDR_BLOCK_B == "" ]] ; then
    THREE_OCTET_CIDR_BLOCK_B=$(cat $(dirname $0)/../bosh-infrastructure.yml \
        | shyaml get-value Parameters.ThreeOctetCIDRBlockB.Default)
fi
if [[ $THREE_OCTET_CIDR_BLOCK_C == "" ]] ; then
    THREE_OCTET_CIDR_BLOCK_C=$(cat $(dirname $0)/../bosh-infrastructure.yml \
        | shyaml get-value Parameters.ThreeOctetCIDRBlockC.Default)
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/bosh/bosh-infrastructure.yml \
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
