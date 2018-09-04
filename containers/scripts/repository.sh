#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh

STACK_NAME=$StackPrefix-containers-$ServiceName-repository

update-stack $1 --template-url $AWSMusingsS3URL/containers/repository.yml \
    --parameters ParameterKey=ServiceName,ParameterValue=$ServiceName \
        ParameterKey=StackPrefix,ParameterValue=$StackPrefix

if [[ $OUTPUT_RESULT == "true" ]] ; then
    RESULT=$(describe-stack)

fi
