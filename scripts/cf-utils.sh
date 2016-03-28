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
        if [[ $STATUS == "CREATE_COMPLETE" ]] ; then
            break
        fi
        if [[ $STATUS != "CREATE_IN_PROGRESS" ]] ; then
            echo "Creating stack returned $STATUS"
            exit -1
        fi
        sleep 10
    done
}

delete-stack() {
    aws cloudformation delete-stack --stack-name $STACK_NAME --profile $PROFILE > /dev/null

    while $(true) ; do
        STATUS=$(aws cloudformation describe-stacks --profile $PROFILE | \
            jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .StackStatus")
        if [[ $STATUS == "" ]] ; then
            break
        fi
        if [[ $STATUS != "DELETE_IN_PROGRESS" ]] ; then
            echo "Deleting stack returned $STATUS"
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
