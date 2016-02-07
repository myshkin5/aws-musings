#!/usr/bin/env bash

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $SECOND_OCTET == "" ]] ; then
    SECOND_OCTET=$(jq -r .Parameters.SecondOctet.Default $(dirname $0)/../vpc.template)
fi
if [[ $DNS_ZONE == "" ]] ; then
    DNS_ZONE=dev
fi
if [[ $FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE == "" ]] ; then
    FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE=$(jq -r .Parameters.FullyQualifiedInternalParentDNSZone.Default $(dirname $0)/../public-infrastructure.template)
fi
if [[ $INTERNAL_KEY_NAME == "" ]] ; then
    INTERNAL_KEY_NAME=$(jq -r .Parameters.InternalKeyName.Default $(dirname $0)/../public-infrastructure.template)
fi
