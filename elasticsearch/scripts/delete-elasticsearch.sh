#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $ELASTICSEARCH_INSTANCE_NAME == "" ]] ; then
    ELASTICSEARCH_INSTANCE_NAME=$(cat $(dirname $0)/../elasticsearch.yml \
        | shyaml get-value Parameters.ElasticsearchInstanceName.Default)
fi

STACK_NAME=$STACK_PREFIX-$ELASTICSEARCH_INSTANCE_NAME

delete-stack
