#!/usr/bin/env bash

source $(dirname $0)/../../scripts/cf-utils.sh

if [[ $InternalAccessCIDRBlock == "" ]] ; then
    InternalAccessCIDRBlock=$(yq r $(dirname $0)/../public.yml Parameters.InternalAccessCIDRBlock.Default)
fi
if [[ $InternalKeyName == "" ]] ; then
    InternalKeyName=$(yq r $(dirname $0)/../public.yml Parameters.InternalKeyName.Default)
fi
