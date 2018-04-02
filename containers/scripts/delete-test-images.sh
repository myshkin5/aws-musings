#!/usr/bin/env bash

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

IMAGES=$(aws ecr list-images \
    --repository-name $STACK_PREFIX/test-endpoint \
    --query 'imageIds[*]' \
    --output json \
    --profile $PROFILE)

if [[ $IMAGES == "" || $IMAGES = "[]" ]] ; then
    echo "No images to delete"
    exit
fi

aws ecr batch-delete-image \
    --repository-name $STACK_PREFIX/test-endpoint \
    --image-ids "$IMAGES" \
    --profile $PROFILE
