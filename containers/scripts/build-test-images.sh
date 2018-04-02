#!/usr/bin/env bash

set -e

PROJECT_DIR=$(dirname $0)/../..

source $PROJECT_DIR/scripts/cf-utils.sh $@

cd $(dirname $0)/..

IMAGE_DIR=tmp

rm -rf $IMAGE_DIR/ 2> /dev/null
mkdir -p $IMAGE_DIR/
cp tests/endpoint/Dockerfile $IMAGE_DIR/

GOOS=linux GOARCH=amd64 go build -o $IMAGE_DIR/test-endpoint tests/endpoint/src/main.go
docker build -t $STACK_PREFIX/test-endpoint:latest tmp/

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account' --profile $PROFILE)
REGION=$(aws configure get region --profile $PROFILE)
IMAGE_ID=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$STACK_PREFIX/test-endpoint:latest

docker tag $STACK_PREFIX/test-endpoint:latest $IMAGE_ID

eval $(aws ecr get-login --no-include-email --profile $PROFILE)

docker push $IMAGE_ID
