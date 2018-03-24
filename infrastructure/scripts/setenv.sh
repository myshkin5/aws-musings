#!/usr/bin/env bash

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $INTERNAL_DNS_ZONE == "" ]] ; then
    INTERNAL_DNS_ZONE=$(yq r $(dirname $0)/../internal-dns.yml Parameters.InternalDNSZone.Default)
fi
if [[ $INTERNAL_ACCESS_CIDR_BLOCK == "" ]] ; then
    INTERNAL_ACCESS_CIDR_BLOCK=$(yq r $(dirname $0)/../public.yml Parameters.InternalAccessCIDRBlock.Default)
fi
if [[ $INTERNAL_KEY_NAME == "" ]] ; then
    INTERNAL_KEY_NAME=$(yq r $(dirname $0)/../public.yml Parameters.InternalKeyName.Default)
fi
