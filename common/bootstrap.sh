#!/usr/bin/env bash

set -e -x

FLAVOR=$(bash -c "source /etc/os-release && echo \$ID")
case $FLAVOR in
"ubuntu")
    OS_USER=ubuntu
    USER_HOME=/home/ubuntu
    AWS_DIR=/usr/local/bin
    ;;
"amzn")
    OS_USER=ec2-user
    USER_HOME=/home/ec2-user
    AWS_DIR=/opt/aws/bin
    ;;
*)
    >&2 echo "Unknown Linux flavor $FLAVOR"
    exit -1
    ;;
esac

aws-signal() {
    EXIT_CODE=$1
    REASON=$2
    SIGNAL_RESOURCE=$RESOURCE
    if [[ $AUTO_SCALING_GROUP != "" ]] ; then
        SIGNAL_RESOURCE=$AUTO_SCALING_GROUP
    fi

    $AWS_DIR/cfn-signal --exit-code $EXIT_CODE --stack $STACK_NAME --resource $SIGNAL_RESOURCE --region $REGION \
        --reason "$REASON"
}

aws-error-exit() {
    REASON=$1
    aws-signal 1 $REASON
    exit 1
}

aws-signal-success() {
    aws-signal 0 "$RESOURCE setup complete"
}

aws-bootstrap() {
    case $FLAVOR in
    "ubuntu")
        # Can't use aws-error-exit here since AWS CLI hasn't been installed yet
        apt-get update
        apt-get --yes install python-pip python-dev libffi-dev libssl-dev git $EXTRA_PACKAGES
        pip install 'requests[security]' --upgrade
        pip install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
        ;;
    "amzn")
        yum -y update || aws-error-exit 'yum update failed'
        yum -y install git || aws-error-exit 'yum install extras failed'
        ;;
    esac

    $AWS_DIR/cfn-init --stack $STACK_NAME --resource $RESOURCE --region $REGION \
        || aws-error-exit 'Failed to run cfn-init'
    $AWS_DIR/cfn-hup || aws-error-exit 'Failed to start cfn-hup'

    echo $HOSTNAME > /etc/hostname
    echo "127.0.0.1 $HOSTNAME $HOSTNAME.localdomain localhost localhost.localdomain" > /etc/new-hosts
    grep -v 127.0.0.1 /etc/hosts >> /etc/new-hosts || true
    mv /etc/new-hosts /etc/hosts

    if [[ $FLAVOR == "amzn" ]] ; then
        sed -i -e "s/localhost/$HOSTNAME/g" /etc/sysconfig/network
    fi

    git clone --depth=1 https://github.com/Bash-it/bash-it.git /root/.bash_it
    sudo -u $OS_USER git clone --depth=1 https://github.com/Bash-it/bash-it.git $USER_HOME/.bash_it

    curl --output /tmp/bashrc.sh --silent $AWS_MUSINGS_S3_URL/common/bashrc.sh
    cat /tmp/bashrc.sh >> /root/.bashrc
    cat /tmp/bashrc.sh >> $USER_HOME/.bashrc
}
