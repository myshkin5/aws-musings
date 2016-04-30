#!/bin/bash

source $(dirname $0)/cf-utils.sh $@

if [[ $ACL == "" ]] ; then
    ACL=public-read
fi

cd $(dirname $0)/..

PROJECT_DIR=$PWD
TMP_DIR=$PROJECT_DIR/tmp
EXISTING_DIR=$TMP_DIR/existing
NEW_DIR=$TMP_DIR/new

echo -e "\033[1m\033[42m Downloading... \033[0m"
mkdir -p $EXISTING_DIR
aws s3 sync --profile $PROFILE --delete s3://$AWS_MUSINGS_S3_BUCKET/ $EXISTING_DIR

ROOT_FILES=$(ls | grep -v -e '.*\.iml' -e tmp -e LICENSE -e 'README\.md')

echo -e "\033[1m\033[42m Generating...  \033[0m"
rm -r $NEW_DIR 2> /dev/null
mkdir $NEW_DIR

cp -r $ROOT_FILES $NEW_DIR

cd $NEW_DIR

for FILE in $(find . -type f -name \*.template.yml) ; do
    NEW_FILE=${FILE::${#FILE}-4}
    python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < $FILE > $NEW_FILE
done

echo -e "\033[1m\033[42m Diffing...     \033[0m"
for FILE in $(find . -type f) ; do
    diff $FILE $EXISTING_DIR/$FILE > /dev/null 2>&1
    if [[ $? != 0 ]] ; then
        mkdir -p $(dirname $EXISTING_DIR/$FILE)
        cp $FILE $EXISTING_DIR/$FILE
    fi
done

cd $EXISTING_DIR

for FILE in $(find . -type f) ; do
    if [[ ! -f $NEW_DIR/$FILE ]] ; then
        rm $FILE
    fi
done

echo -e "\033[1m\033[42m Uploading...   \033[0m"
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

echo -e "\033[1m\033[42m Done.          \033[0m"
