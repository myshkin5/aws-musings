#!/usr/bin/env bash

if [[ $AWSMusingsS3Bucket == "" ]] ; then
    AWSMusingsS3Bucket=aws-musings-us-east-1
fi
if [[ $AWSMusingsS3URL == "" ]] ; then
    AWSMusingsS3URL=https://s3.amazonaws.com/$AWSMusingsS3Bucket
fi
if [[ $AWSMusingsProfile == "" ]] ; then
    AWSMusingsProfile=default
fi
if [[ $StackOrg == "" ]] ; then
    >&2 echo "Environment variable \$StackOrg is not defined"
    exit -1
fi
if [[ $StackEnv == "" ]] ; then
    StackEnv=dev
fi
StackPrefix=$StackOrg-$StackEnv

update-stack() {
    if [[ $1 == "create" ]] ; then
        shift
        VERB=create-stack
        PARAMS=$@
        ROLLBACK=--disable-rollback
        >&2 echo "Creating $STACK_NAME..."
    elif [[ $1 == "update" ]] ; then
        shift
        VERB=update-stack
        PARAMS=$@
        >&2 echo "Updating $STACK_NAME..."
    elif [[ $1 == "delete" ]] ; then
        VERB=delete-stack
        >&2 echo "Deleting $STACK_NAME..."
    else
        >&2 echo "First parameter to a stack script must be 'create', 'update' or 'delete'"
        exit -1
    fi

    aws cloudformation $VERB --stack-name $STACK_NAME $PARAMS $ROLLBACK --profile $AWSMusingsProfile > /dev/null

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
        STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $AWSMusingsProfile \
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
        STATUS=$(aws cloudformation describe-stacks --profile $AWSMusingsProfile | \
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
    aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $AWSMusingsProfile
}

get-output-value() {
    KEY=$1
    echo $RESULT | jq -r ".Stacks[0].Outputs[] | select(.OutputKey == \"$KEY\") | .OutputValue"
}
