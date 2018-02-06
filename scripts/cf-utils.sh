#!/usr/bin/env bash

if [[ $AWS_MUSINGS_S3_BUCKET == "" ]] ; then
    AWS_MUSINGS_S3_BUCKET=aws-musings-us-east-1
fi
if [[ $AWS_MUSINGS_S3_URL == "" ]] ; then
    AWS_MUSINGS_S3_URL=https://s3.amazonaws.com/$AWS_MUSINGS_S3_BUCKET
fi
if [[ $PROFILE == "" ]] ; then
    PROFILE=default
fi
if [[ $STACK_PREFIX == "" ]] ; then
    STACK_PREFIX=vkzone-dev
fi

wait-for-stack-completion() {
    while $(true) ; do
        STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE \
            | jq -r .Stacks[0].StackStatus)
        if [[ $STATUS == "CREATE_COMPLETE" || $STATUS == "UPDATE_COMPLETE" ]] ; then
            break
        fi
        if [[ $STATUS != "CREATE_IN_PROGRESS" && $STATUS != "UPDATE_IN_PROGRESS" ]] ; then
            >&2 echo "Creating/updating stack returned $STATUS"
            exit -1
        fi
        sleep 10
    done
}

describe-stack() {
    aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE
}

get-output-value() {
    KEY=$1
    echo $RESULT | jq -r ".Stacks[0].Outputs[] | select(.OutputKey == \"$KEY\") | .OutputValue"
}
