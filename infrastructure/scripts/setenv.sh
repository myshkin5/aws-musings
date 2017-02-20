#!/usr/bin/env bash

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $SECOND_OCTET == "" ]] ; then
    SECOND_OCTET=$(cat $(dirname $0)/../vpc.yml | shyaml get-value Parameters.SecondOctet.Default)
fi
if [[ $DNS_ZONE == "" ]] ; then
    DNS_ZONE=dev
fi
if [[ $FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE == "" ]] ; then
    FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE=$(cat $(dirname $0)/../public-infrastructure.yml \
        | shyaml get-value Parameters.FullyQualifiedInternalParentDNSZone.Default)
fi
if [[ $INTERNAL_KEY_NAME == "" ]] ; then
    INTERNAL_KEY_NAME=$(cat $(dirname $0)/../public-infrastructure.yml \
        | shyaml get-value Parameters.InternalKeyName.Default)
fi
