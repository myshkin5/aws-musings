#!/usr/bin/env bash

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

IMAGES=$(aws ecr list-images \
    --repository-name $StackPrefix/test-endpoint \
    --query 'imageIds[*]' \
    --output json \
    --profile $AWSMusingsProfile)

if [[ $IMAGES == "" || $IMAGES = "[]" ]] ; then
    echo "No images to delete"
    exit
fi

aws ecr batch-delete-image \
    --repository-name $StackPrefix/test-endpoint \
    --image-ids "$IMAGES" \
    --profile $AWSMusingsProfile
