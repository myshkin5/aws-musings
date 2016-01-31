#!/usr/bin/env bash

set -e -x

apt-get update
apt-get --yes install python-pip python-dev libffi-dev libssl-dev git
pip install 'requests[security]' --upgrade
pip install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz

aws-error-exit() {
    REASON=$1
    cfn-signal --exit-code 1 --reason \"$REASON\" \"$HANDLE\"
    exit 1
}

cfn-init --stack $STACK_NAME --resource $RESOURCE --region $REGION || aws-error-exit 'Failed to run cfn-init'
cfn-hup || aws-error-exit 'Failed to start cfn-hup'

echo $HOSTNAME > /etc/hostname
sed -i -e "s/127.0.0.1 localhost/127.0.0.1 localhost $HOSTNAME/g" /etc/hosts

git clone --depth=1 https://github.com/Bash-it/bash-it.git /root/.bash_it
sudo -u ubuntu git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/ubuntu/.bash_it

curl --output /tmp/bashrc.sh --silent $S3_URL/common/bashrc.sh
cat /tmp/bashrc.sh >> /root/.bashrc
cat /tmp/bashrc.sh >> /home/ubuntu/.bashrc
