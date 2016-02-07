#!/usr/bin/env bash

PROFILE=myshkin5
S3_URL=https://s3.amazonaws.com/aws-musings-us-east-1
STACK_PREFIX=vkzone-dev

while [ $# -gt 0 ] ; do
    if [[ "$1" == "-u" || "$1" == "--url" ]] ; then
        S3_URL=$2
        shift
    elif [[ "$1" == "-p" || "$1" == "--profile" ]] ; then
        PROFILE=$2
        shift
    elif [[ "$1" == "-s" || "$1" == "--stack-prefix" ]] ; then
        STACK_PREFIX=$2
        shift
    else
        echo "Unknown command line argument, $1"
        exit -1
    fi
    shift
done

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
