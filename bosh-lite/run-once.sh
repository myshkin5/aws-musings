#!/bin/bash
### BEGIN INIT INFO
# Provides:          bosh-lite
# Required-Start:    $local_fs $network
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: runs bosh-lite once.
### END INIT INFO

set -e

PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
AWS_DIR=/usr/local/bin

. /lib/lsb/init-functions

aws-error-exit() {
    REASON=$1
    $AWS_DIR/cfn-signal --exit-code 1 --stack "STACK_NAME" --resource "RESOURCE" --region "REGION" \
        --reason "$REASON"
    exit 1
}

aws-signal-success() {
    $AWS_DIR/cfn-signal --exit-code 0 --stack "STACK_NAME" --resource "RESOURCE" --region "REGION" \
        --reason "RESOURCE setup complete"
}

do_start () {
    ONCE_FILE=/usr/local/bosh-lite-run-once
    if [ -f $ONCE_FILE ] ; then
        log_action_msg "bosh-lite already run. Done."
    else
        log_action_msg "Running bosh-lite..."

        # HOME must be set so bosh can locate $HOME/.bosh
        export HOME=/root

        echo "$(date) Starting bosh-lite configuration..."

        /usr/local/bootstrap-bosh-lite.sh "BOSH_LITE_URL" >> /var/log/bosh-lite.log 2>&1 || \
            aws-error-exit "Failed bosh-lite bootstrap"

        echo "$(date) Finished bosh-lite configuration"
        touch $ONCE_FILE
        aws-signal-success
    fi
}

case "$1" in
    start)
        do_start
        ;;
    restart|reload|force-reload)
        echo "Error: argument '$1' not supported" >&2
        exit 3
        ;;
    stop)
        # No-op
        ;;
    *)
        echo "Usage: $0 start|stop" >&2
        exit 3
        ;;
esac
