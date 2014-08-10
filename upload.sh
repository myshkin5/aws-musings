#!/bin/bash

aws s3 cp --recursive --acl public-read \
    --exclude .git/\* \
    --exclude .idea/\* \
    --exclude .gitignore \
    --exclude LICENSE \
    --exclude README.md \
    --exclude upload.sh \
    --exclude \*/\*.iml \
    --exclude \*/README \
    --exclude initial.template \
    . s3://aws-musings/
