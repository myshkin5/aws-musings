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

echo "export IPV6_CIDR_BLOCK=$IPV6_CIDR_BLOCK"
echo "export INTERNAL_ACCESS_IPV6_CIDR_BLOCK=$IPV6_CIDR_BLOCK"
echo "export PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK=${RAW_56}00::/64"
echo "export PUBLIC_SUBNET_B_IPV6_CIDR_BLOCK=${RAW_56}01::/64"
echo "export PUBLIC_SUBNET_C_IPV6_CIDR_BLOCK=${RAW_56}02::/64"
