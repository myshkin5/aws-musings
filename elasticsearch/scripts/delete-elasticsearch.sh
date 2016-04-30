#!/usr/bin/env bash

set -e

source $(dirname $0)/../../scripts/cf-utils.sh $@

if [[ $ELASTICSEARCH_INSTANCE_NAME == "" ]] ; then
    ELASTICSEARCH_INSTANCE_NAME=$(jq -r .Parameters.ElasticsearchInstanceName.Default $(dirname $0)/../../tmp/new/elasticsearch/elasticsearch.template)
fi

STACK_NAME=$STACK_PREFIX-$ELASTICSEARCH_INSTANCE_NAME

delete-stack
