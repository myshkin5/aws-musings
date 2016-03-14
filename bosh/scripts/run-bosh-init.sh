#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-bosh-init

if [[ $DNS_ZONE == "" ]] ; then
    DNS_ZONE=dev
fi
if [[ $FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE == "" ]] ; then
    FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE=$(jq -r .Parameters.FullyQualifiedInternalParentDNSZone.Default $(dirname $0)/../../infrastructure/public-infrastructure.template)
fi
if [[ $INTERNAL_KEY_NAME == "" ]] ; then
    INTERNAL_KEY_NAME=$(jq -r .Parameters.InternalKeyName.Default $(dirname $0)/../../infrastructure/public-infrastructure.template)
fi
if [[ $MANAGEMENT_THREE_OCTET_CIDR_BLOCK == "" ]] ; then
    MANAGEMENT_THREE_OCTET_CIDR_BLOCK=$(jq -r .Parameters.ManagementThreeOctetCIDRBlock.Default $(dirname $0)/../bosh-infrastructure.template)
fi
if [[ $AWS_ACCESS_KEY_ID == "" ]] ; then
    >&2 echo "ERROR: AWS_ACCESS_KEY_ID must be set to an AWS access key id"
    exit 1
fi
if [[ $AWS_SECRET_ACCESS_KEY == "" ]] ; then
    >&2 echo "ERROR: AWS_SECRET_ACCESS_KEY must be set to an AWS secret access key"
    exit 1
fi
if [[ $PRIVATE_KEY_FILE == "" || ! -f $PRIVATE_KEY_FILE ]] ; then
    >&2 echo "ERROR: PRIVATE_KEY_FILE must be set and pointing to a valid private SSH key file"
    exit 1
fi
PRIVATE_KEY=$(cat $PRIVATE_KEY_FILE)

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $S3_URL/bosh/bosh-init.template \
    --parameters ParameterKey=AWSAccessKeyId,ParameterValue=$AWS_ACCESS_KEY_ID \
        ParameterKey=AWSMusingsS3URL,ParameterValue=$S3_URL \
        ParameterKey=AWSSecretAccessKey,ParameterValue="$AWS_SECRET_ACCESS_KEY" \
        ParameterKey=BOSHDirectorSecurityGroupId,ParameterValue=$BOSH_DIRECTOR_SECURITY_GROUP_ID \
        ParameterKey=DNSZone,ParameterValue=$DNS_ZONE \
        ParameterKey=FullyQualifiedInternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE \
        ParameterKey=InternalKeyName,ParameterValue=$INTERNAL_KEY_NAME \
        ParameterKey=ManagementSubnetId,ParameterValue=$MANAGEMENT_SUBNET_ID \
        ParameterKey=ManagementThreeOctetCIDRBlock,ParameterValue=$MANAGEMENT_THREE_OCTET_CIDR_BLOCK \
        ParameterKey=PrivateKey,ParameterValue="$PRIVATE_KEY" \
        ParameterKey=StackPrefix,ParameterValue="$STACK_PREFIX" \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export BOSH_INIT_PRIVATE_IP_ADDRESS=$(get-output-value BOSHInitPrivateIPAddress)"
