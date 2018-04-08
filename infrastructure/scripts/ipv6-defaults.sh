#!/usr/bin/env bash

if [[ $# != 1 ]] ; then
    >&2 echo "Usage: $0 <IPv6 CIDR of VPC>"
    exit -1
fi

IPv6CIDRBlock=$1

SUFFIX_56=00::/56
if [[ $IPv6CIDRBlock != *$SUFFIX_56 ]] ; then
    >&2 echo "$0 currently only works with /56 CIDR blocks (must end in $SUFFIX_56)"
    exit -1
fi
RAW_56=${IPv6CIDRBlock%$SUFFIX_56}

echo "export IPv6CIDRBlock=$IPv6CIDRBlock"
echo "export InternalAccessIPv6CIDRBlock=$IPv6CIDRBlock"
echo "export PublicSubnetAIPv6CIDRBlock=${RAW_56}00::/64"
echo "export PublicSubnetBIPv6CIDRBlock=${RAW_56}01::/64"
echo "export PublicSubnetCIPv6CIDRBlock=${RAW_56}02::/64"
