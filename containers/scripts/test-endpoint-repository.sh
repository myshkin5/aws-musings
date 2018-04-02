#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$STACK_PREFIX-containers-test-endpoint-repository

update-stack $1 --template-url $AWS_MUSINGS_S3_URL/containers/tests/endpoint/repository.yml \
    --parameters ParameterKey=StackPrefix,ParameterValue=$STACK_PREFIX

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

fi

