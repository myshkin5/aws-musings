#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $BOSH_LITE_INSTANCE_NAME == "" ]] ; then
    BOSH_LITE_INSTANCE_NAME=$(jq -r .Parameters.BOSHLiteInstanceName.Default $(dirname $0)/../../tmp/new/bosh-lite/bosh-lite.template)
fi

STACK_NAME=$STACK_PREFIX-$BOSH_LITE_INSTANCE_NAME

delete-stack
