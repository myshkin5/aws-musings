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

echo "export ContainersPublicSubnetAIPv6CIDRBlock=${RAW_56}03::/64"
echo "export ContainersPublicSubnetBIPv6CIDRBlock=${RAW_56}04::/64"
echo "export ContainersPublicSubnetCIPv6CIDRBlock=${RAW_56}05::/64"

echo "export ContainersPrivateSubnetAIPv6CIDRBlock=${RAW_56}33::/64"
echo "export ContainersPrivateSubnetBIPv6CIDRBlock=${RAW_56}34::/64"
echo "export ContainersPrivateSubnetCIPv6CIDRBlock=${RAW_56}35::/64"
