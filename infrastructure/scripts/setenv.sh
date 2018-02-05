#!/usr/bin/env bash

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $SECOND_OCTET == "" ]] ; then
    SECOND_OCTET=$(yq r $(dirname $0)/../vpc.yml Parameters.SecondOctet.Default)
fi
if [[ $DNS_ZONE == "" ]] ; then
    DNS_ZONE=dev
fi
if [[ $INTERNAL_KEY_NAME == "" ]] ; then
    INTERNAL_KEY_NAME=$(yq r $(dirname $0)/../public-infrastructure.yml Parameters.InternalKeyName.Default)
fi
