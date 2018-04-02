#!/usr/bin/env bash

if [[ $# != 1 ]] ; then
    >&2 echo "Usage: $0 <IPv6 CIDR of VPC>"
    exit -1
fi

IPV6_CIDR_BLOCK=$1

SUFFIX_56=00::/56
if [[ $IPV6_CIDR_BLOCK != *$SUFFIX_56 ]] ; then
    >&2 echo "$0 currently only works with /56 CIDR blocks (must end in $SUFFIX_56)"
    exit -1
fi
RAW_56=${IPV6_CIDR_BLOCK%$SUFFIX_56}

echo "export CONTAINERS_PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK=${RAW_56}30::/64"
echo "export CONTAINERS_PUBLIC_SUBNET_B_IPV6_CIDR_BLOCK=${RAW_56}31::/64"
echo "export CONTAINERS_PUBLIC_SUBNET_C_IPV6_CIDR_BLOCK=${RAW_56}32::/64"
