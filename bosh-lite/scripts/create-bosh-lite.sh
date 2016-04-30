#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..
TMP_DIR=$PROJECT_DIR/tmp

source $PROJECT_DIR/scripts/cf-utils.sh $@

if [[ $BOSH_LITE_INSTANCE_NAME == "" ]] ; then
    BOSH_LITE_INSTANCE_NAME=$(jq -r .Parameters.BOSHLiteInstanceName.Default $TMP_DIR/new/bosh-lite/bosh-lite.template)
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
if [[ $BOSH_LITE_IMAGE_ID == "" ]] ; then
    BOSH_LITE_IMAGE_ID=ami-22839a48
fi
if [[ $BOSH_LITE_INSTANCE_TYPE == "" ]] ; then
    BOSH_LITE_INSTANCE_TYPE=m3.xlarge
fi
if [[ $BOSH_LITE_SPOT_PRICE == "" ]] ; then
    BOSH_LITE_SPOT_PRICE=0.06
fi
if [[ $BOSH_LITE_CF_ADMIN_PASSWORD == "" ]] ; then
    echo "Set BOSH_LITE_CF_ADMIN_PASSWORD to a generated password before running"
    exit 1
fi

STACK_NAME=$STACK_PREFIX-$BOSH_LITE_INSTANCE_NAME

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/bosh-lite/bosh-lite.template \
    --parameters ParameterKey=AWSMusingsS3URL,ParameterValue=$AWS_MUSINGS_S3_URL \
        ParameterKey=BOSHLiteCFAdminPassword,ParameterValue=$BOSH_LITE_CF_ADMIN_PASSWORD \
        ParameterKey=BOSHLiteELBSecurityGroupId,ParameterValue=$BOSH_LITE_ELB_SECURITY_GROUP_ID \
        ParameterKey=BOSHLiteELBSSLCertificateId,ParameterValue=$BOSH_LITE_ELB_SSL_CERTIFICATE_ID \
        ParameterKey=BOSHLiteImageId,ParameterValue=$BOSH_LITE_IMAGE_ID \
        ParameterKey=BOSHLiteInstanceName,ParameterValue=$BOSH_LITE_INSTANCE_NAME \
        ParameterKey=BOSHLiteInstanceSecurityGroupId,ParameterValue=$BOSH_LITE_INSTANCE_SECURITY_GROUP_ID \
        ParameterKey=BOSHLiteInstanceType,ParameterValue=$BOSH_LITE_INSTANCE_TYPE \
        ParameterKey=BOSHLitePublicSubnetId,ParameterValue=$BOSH_LITE_PUBLIC_SUBNET_ID \
        ParameterKey=BOSHLitePrivateSubnetId,ParameterValue=$BOSH_LITE_PRIVATE_SUBNET_ID \
        ParameterKey=BOSHLiteSpotPrice,ParameterValue=$BOSH_LITE_SPOT_PRICE \
        ParameterKey=DNSZone,ParameterValue=$DNS_ZONE \
        ParameterKey=FullyQualifiedExternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_PARENT_DNS_ZONE \
        ParameterKey=FullyQualifiedInternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE \
        ParameterKey=InternalKeyName,ParameterValue=$INTERNAL_KEY_NAME \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion
