#!/bin/bash

aws s3 sync --delete --acl public-read \
    --exclude .git/\* \
    --exclude .idea/\* \
    --exclude .gitignore \
    --exclude LICENSE \
    --exclude README.md \
    --exclude upload.sh \
    --exclude \*.iml \
    --exclude \*/README \
    . s3://aws-musings/
