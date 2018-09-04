#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh

cd $(dirname $0)/..

IMAGE_DIR=tmp/$ServiceName

rm -rf $IMAGE_DIR/ 2> /dev/null
mkdir -p $IMAGE_DIR/
cp $SERVICE_SOURCE_DIR/Dockerfile $IMAGE_DIR/

GOOS=linux GOARCH=amd64 go build -o $IMAGE_DIR/$ServiceName $SERVICE_SOURCE_DIR/src/main.go
docker build -t $StackPrefix/$ServiceName:latest $IMAGE_DIR

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account' --profile $AWSMusingsProfile)
REGION=$(aws configure get region --profile $AWSMusingsProfile)
IMAGE_ID=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$StackPrefix/$ServiceName:latest

docker tag $StackPrefix/$ServiceName:latest $IMAGE_ID

eval $(aws ecr get-login --no-include-email --profile $AWSMusingsProfile)

docker push $IMAGE_ID
