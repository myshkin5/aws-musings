#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

STACK_NAME=$StackPrefix-containers-test-endpoint-repository

update-stack $1 --template-url $AWSMusingsS3URL/containers/tests/endpoint/repository.yml \
    --parameters ParameterKey=StackPrefix,ParameterValue=$StackPrefix

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

fi

