#!/usr/bin/env bash

# Delayed calling set -e as list-images returns an error when there are no images
#set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh

IMAGES=$(aws ecr list-images \
    --repository-name $StackPrefix/$ServiceName \
    --query 'imageIds[*]' \
    --output json \
    --profile $AWSMusingsProfile)

if [[ $IMAGES == "" || $IMAGES = "[]" ]] ; then
    echo "No images to delete"
    exit
fi

set -e

aws ecr batch-delete-image \
    --repository-name $StackPrefix/$ServiceName \
    --image-ids "$IMAGES" \
    --profile $AWSMusingsProfile
