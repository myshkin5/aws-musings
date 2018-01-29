#!/bin/bash

source $(dirname $0)/cf-utils.sh $@

if [[ $ACL == "" ]] ; then
    ACL=public-read
fi

cd $(dirname $0)/..

>&2 echo -e "\033[1m\033[42m Uploading...  \033[0m"
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
    . s3://$AWS_MUSINGS_S3_BUCKET/

>&2 echo -e "\033[1m\033[42m Done.         \033[0m"
