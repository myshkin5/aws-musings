#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $BOSH_LITE_INSTANCE_NAME == "" ]] ; then
    BOSH_LITE_INSTANCE_NAME=$(yq r $(dirname $0)/../bosh-lite.yml Parameters.BOSHLiteInstanceName.Default)
fi

STACK_NAME=$STACK_PREFIX-$BOSH_LITE_INSTANCE_NAME

delete-stack
