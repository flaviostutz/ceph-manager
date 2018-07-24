#!/bin/bash
set -e
set -x

echo "Defining default values for ENVs..."
if [ "$CLUSTER_NAME" == "" ]; then
    echo "CLUSTER_NAME cannot be empty"
    exit 1
fi

if [ "$PEER_MONITOR_HOST" == "" ]; then
    echo "JOIN_MONITOR_HOST cannot be empty"
    exit 1
fi

if [ "$ETCD_URL" == "" ]; then
    echo "ETCD_URL cannot be empty. It is used to retrieve the keyring"
    exit 1
fi

if [ "$MANAGER_NAME" == "" ]; then
    export MANAGER_NAME=$(hostname)
fi

MANAGER_PATH=/var/lib/ceph/mgr/$CLUSTER_NAME-$MANAGER_NAME

resolveKeyring() {
    if [ -f /etc/ceph/keyring ]; then
        echo "Monitor key already known"
        return 0
    elif [ "$ETCD_URL" != "" ]; then 
        echo "Retrieving monitor key from ETCD..."
        KEYRING=$(etcdctl --endpoints $ETCD_URL get "/$CLUSTER_NAME/keyring")
        if [ $? -eq 0 ]; then
            echo $KEYRING > /tmp/base64keyring
            base64 -d -i /tmp/base64keyring > /etc/ceph/keyring
            return 0
        else
            return 2
        fi
    else
        echo "Monitor key doesn't exist and ETCD was not defined. Cannot retrieve keys."
        return 1
    fi
}

if [ ! -f /initialized ]; then
    echo "Creating ceph.conf..."
    cat /ceph.conf.template | envsubst > /etc/ceph/ceph.conf
    cat /etc/ceph/ceph.conf
    mkdir -p ${MANAGER_PATH}

    echo "Retrieving keyring for connecting to monitors..."
    while true; do
        resolveKeyring && break
        if [ $? -eq 1 ]; then
            exit 2
        fi
        echo "Retrying in 1s..."
        sleep 1
    done
    cp /etc/ceph/keyring ${MANAGER_PATH}/keyring

    echo "Creating mgr.${MANAGER_NAME} key..."
    MGR_KEY=$(ceph auth get-or-create mgr.${MANAGER_NAME} mon 'allow profile mgr' osd 'allow *' mds 'allow *' -i ${MANAGER_PATH}/keyring)
    echo "${MGR_KEY}" >> ${MANAGER_PATH}/keyring

    cat ${MANAGER_PATH}/keyring

    touch /initialized

else
    echo "Manager already initialized before. Reusing state."
fi

echo ""
echo "Starting Manager Daemon $CLUSTER_NAME-$MANAGER_NAME..."

enableModules() {
    echo "Waiting 5s before enabling modules..."
    sleep 5
    ceph mgr module enable prometheus
    ceph mgr module enable dashboard
    ceph dashboard create-self-signed-cert
    ceph mgr module disable dashboard
    ceph mgr module enable dashboard
    echo "Modules prometheus and dashboard enabled"
}

enableModules &
ceph-mgr -d --debug_ms $LOG_LEVEL --id $MANAGER_NAME --cluster $CLUSTER_NAME --mgr-data ${MANAGER_PATH} --keyring ${MANAGER_PATH}/keyring
