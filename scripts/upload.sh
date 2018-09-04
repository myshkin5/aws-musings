#!/bin/bash

source $(dirname $0)/cf-utils.sh

if [[ $AWSMusingsS3ACL == "" ]] ; then
    AWSMusingsS3ACL=public-read
fi

cd $(dirname $0)/..

>&2 echo -e "\033[1m\033[42m Uploading...  \033[0m"
aws s3 sync --profile $AWSMusingsProfile --delete --acl $AWSMusingsS3ACL \
    --exclude .git/\* \
    --exclude .idea/\* \
    --exclude .DS_Store \
    --exclude \*.iml \
    --exclude \*/tmp/\* \
    . s3://$AWSMusingsS3Bucket/

>&2 echo -e "\033[1m\033[42m Done.         \033[0m"
