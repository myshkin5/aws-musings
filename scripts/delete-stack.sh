#!/usr/bin/env bash

set -e

source $(dirname $0)/cf-utils.sh $@

if [[ $1 == "" ]] ; then
    >&2 echo "Stack name not specified"
    exit -1
fi

STACK_NAME=$STACK_PREFIX-$1

aws cloudformation delete-stack --stack-name $STACK_NAME --profile $PROFILE > /dev/null

while $(true) ; do
    STATUS=$(aws cloudformation describe-stacks --profile $PROFILE | \
        jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .StackStatus")
    if [[ $STATUS == "" ]] ; then
        break
    fi
    if [[ $STATUS != "DELETE_IN_PROGRESS" ]] ; then
        >&2 echo "Deleting stack returned $STATUS"
        exit -1
    fi
    sleep 10
done
