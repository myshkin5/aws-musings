#!/usr/bin/env bash

#set -e -x TODO: Add back -e if it can be made to work with the retry function
set -x

retry() {
    TRIES=$1
    shift

    COUNT=0
    while $(true) ; do
# TODO:        set +e
        eval $* && break
# TODO:        set -e
        (( COUNT++ ))
        if (( $COUNT >= $TRIES )) ; then
            echo "Giving up after $COUNT tries"
            break
        fi
        echo "Failed try $COUNT"
    done
}

STEMCELL_SOURCE=https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
STEMCELL_FILE=/tmp/latest-bosh-lite-stemcell-warden.tgz

export HOME=/root
HOME_BIN=$HOME/bin
mkdir $HOME_BIN
curl --location --output $HOME_BIN/spiff --silent \
    https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64
chmod +x $HOME_BIN/spiff
export PATH=$PATH:$HOME_BIN

WORKSPACE=/mnt/workspace
BOSH_LITE_DIR=$WORKSPACE/bosh-lite
CF_DIR=$WORKSPACE/cf-release

mkdir $WORKSPACE
cd $WORKSPACE

git clone https://github.com/cloudfoundry/bosh-lite.git
git clone https://github.com/cloudfoundry/cf-release.git

cd bosh-lite

curl --location --output $STEMCELL_FILE --silent $STEMCELL_SOURCE

retry 5 bosh -n target localhost
export COLUMNS=120
retry 5 bosh -n -u admin -p admin upload stemcell --skip-if-exists $STEMCELL_FILE

cd $CF_DIR
./scripts/update

bundle install --frozen

./scripts/generate-bosh-lite-dev-manifest
MANIFEST=$CF_DIR/bosh-lite/deployments/cf.yml
sed -i -e "s/bosh-lite.com/BOSH_LITE_URL/g" $MANIFEST
sed -i -e "s/admin|admin|scim.write/admin|BOSH_LITE_CF_ADMIN_PASSWORD|scim.write/g" $MANIFEST
bosh status

retry 5 bosh -n create release --force

retry 5 bosh -n -u admin -p admin upload release --skip-if-exists
retry 5 bosh -n -u admin -p admin deploy

ssh-keygen -f $HOME/.ssh/id_rsa -N ""
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
ssh-keyscan localhost >> $HOME/.ssh/known_hosts
IP_ADDR=$(ifconfig eth0 | grep "inet addr" | cut -d : -f 2 | cut -d \  -f 1)
#nohup ssh -L $IP_ADDR:443:10.244.0.34:443 localhost grep xxx \
#    >> /var/log/ssh-port-forward.log 2>&1 &
#cf passwd # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
