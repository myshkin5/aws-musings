#!/bin/bash

PROFILE=myshkin5
BUCKET=aws-musings-us-east-1
ACL=public-read

usage()
{
    echo -e "Usage:  $0 ...\n\
            [ -b | --bucket <bucket> (The bucket to upload to, default is\n\
                    $BUCKET) ]\n\
            [ -p | --profile <profile> (The AWS CLI profile to upload as,\n\
                    default is the $PROFILE profile) ]\n\
            [ -a | --acl <acl> (The access control list that will protect the\n\
                    uploaded files, default is $ACL) ]"
    echo "        $0 [-?|-h|--help]"
}

while [ $# -gt 0 ] ; do
    if [[ "$1" == "-b" || "$1" == "--bucket" ]] ; then
        BUCKET=$2
        shift
    elif [[ "$1" == "-p" || "$1" == "--profile" ]] ; then
        PROFILE=$2
        shift
    elif [[ "$1" == "-a" || "$1" == "--acl" ]] ; then
        ACL=$2
        shift
    elif [[ "$1" == "-?" ||  "$1" == "-h" || "$1" == "--help" ]] ; then
        usage
        exit 0
    else
        usage
        exit -1
    fi
    shift
done

cd $(dirname $0)/..

aws s3 sync --profile $PROFILE --delete --acl $ACL \
    --exclude .git/\* \
    --exclude .idea/\* \
    --exclude .DS_Store \
    --exclude .gitignore \
    --exclude LICENSE \
    --exclude README.md \
    --exclude upload.sh \
    --exclude \*.iml \
    --exclude \*/README \
    . s3://$BUCKET/
