#!/bin/bash
### BEGIN INIT INFO
# Provides:          bosh-init
# Required-Start:    $local_fs $network
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: runs bosh-init once.
### END INIT INFO

set -e

PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

. /lib/lsb/init-functions

do_start () {
    ONCE_FILE=/usr/local/bosh-init/run-once
    if [ -f $ONCE_FILE ] ; then
        log_action_msg "bosh-init already run. Done."
    else
        log_action_msg "Running bosh-init..."
        cd /usr/local/bosh-init

        # HOME must be set so bosh-init can locate $HOME/.bosh_init
        export HOME=/root

        #export BOSH_INIT_LOG_LEVEL=debug
        echo "$(date) Starting bosh-init..."
        ./bosh-init deploy ./bosh.yml >> /var/log/bosh-init.log 2>&1
        echo "$(date) Finished bosh-init"
        touch $ONCE_FILE
        /usr/local/bin/cfn-signal --exit-code 0 --stack "STACK_NAME" --resource "RESOURCE" --region "REGION" \
            --reason "BOSHInitInstance setup complete"
    fi
}

case "$1" in
    start)
        do_start
        ;;
    restart|reload|force-reload)
        >&2 echo "Error: argument '$1' not supported"
        exit 3
        ;;
    stop)
        # No-op
        ;;
    *)
        >&2 echo "Usage: $0 start|stop"
        exit 3
        ;;
esac
