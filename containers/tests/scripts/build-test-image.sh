#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../../..

source $PROJECT_DIR/scripts/cf-utils.sh

if [[ $# != 1 ]] ; then
    >&2 echo "Usage: $0 <test service name>"
    exit -1
fi

SERVICE_NAME=$1

cd $PROJECT_DIR/containers/tests

IMAGE_DIR=tmp/$SERVICE_NAME

rm -rf $IMAGE_DIR/ 2> /dev/null
mkdir -p $IMAGE_DIR/
cp $SERVICE_NAME/Dockerfile $IMAGE_DIR/

GOOS=linux GOARCH=amd64 go build -o $IMAGE_DIR/$SERVICE_NAME $SERVICE_NAME/src/main.go
docker build --tag $StackPrefix/$SERVICE_NAME:latest $IMAGE_DIR

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account' --profile $AWSMusingsProfile)
REGION=$(aws configure get region --profile $AWSMusingsProfile)
IMAGE_ID=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$StackPrefix/$SERVICE_NAME:latest

docker tag $StackPrefix/$SERVICE_NAME:latest $IMAGE_ID

eval $(aws ecr get-login --no-include-email --profile $AWSMusingsProfile)

docker push $IMAGE_ID
