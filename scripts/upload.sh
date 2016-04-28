#!/bin/bash

source $(dirname $0)/cf-utils.sh $@

if [[ $ACL == "" ]] ; then
    ACL=public-read
fi

PROJECT_DIR=$(dirname $0)/..
TMP_DIR=$PROJECT_DIR/tmp

rm -r $TMP_DIR

cd $PROJECT_DIR
ROOT_FILES=$(ls | grep -v *.iml)

mkdir $TMP_DIR

cp -rp $ROOT_FILES $TMP_DIR

cd $TMP_DIR

for FILE in $(find . -name \*.template.yml) ; do
    NEW_FILE=${FILE::${#FILE}-4}
    python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)' < $FILE > $NEW_FILE
done

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
