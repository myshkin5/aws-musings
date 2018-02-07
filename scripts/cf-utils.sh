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

update-stack() {
    if [[ $1 == "create" ]] ; then
        shift
        VERB=create-stack
        PARAMS=$@
        ROLLBACK=--disable-rollback
    elif [[ $1 == "update" ]] ; then
        shift
        VERB=update-stack
        PARAMS=$@
    elif [[ $1 == "delete" ]] ; then
        VERB=delete-stack
    else
        >&2 echo "First parameter to a stack script must be 'create' or 'update'"
        exit -1
    fi

    aws cloudformation $VERB --stack-name $STACK_NAME $PARAMS $ROLLBACK --profile $PROFILE > /dev/null

    if [[ $VERB == "delete-stack" ]] ; then
        wait-for-stack-deletion
        OUTPUT_RESULT=false
    else
        wait-for-stack-completion
        OUTPUT_RESULT=true
    fi
}

wait-for-stack-completion() {
    while $(true) ; do
        STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE \
            | jq -r .Stacks[0].StackStatus)
        if [[ $STATUS == "CREATE_COMPLETE" || $STATUS == "UPDATE_COMPLETE" ]] ; then
            break
        fi
        if [[ $STATUS != *_IN_PROGRESS ]] ; then
            >&2 echo "Creating/updating stack returned $STATUS"
            exit -1
        fi
        sleep 10
    done
}

wait-for-stack-deletion() {
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
}

describe-stack() {
    aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE
}

get-output-value() {
    KEY=$1
    echo $RESULT | jq -r ".Stacks[0].Outputs[] | select(.OutputKey == \"$KEY\") | .OutputValue"
}
