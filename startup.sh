#!/bin/bash
set -e
# set -x

echo "Defining default values for ENVs..."
if [ "$CLUSTER_NAME" == "" ]; then
    echo "CLUSTER_NAME cannot be empty"
    exit 1
fi

if [ "$JOIN_MONITOR_HOST" == "" ]; then
    echo "JOIN_MONITOR_HOST cannot be empty"
    exit 1
fi

if [ "$MANAGER_NAME" == "" ]; then
    export MANAGER_NAME=$(hostname)
fi

if [ ! -f /initialized ]; then 
    echo "Creating ceph.conf..."
    cat /ceph.conf.template | envsubst > /etc/ceph/ceph.conf
    cat /etc/ceph/ceph.conf
    mkdir -p /var/lib/ceph/mgr/$CLUSTER_NAME-$MANAGER_NAME
    touch /initialized

else
    echo "Manager already initialized before. Reusing state."
fi

echo ""
echo "Starting Ceph Manager $CLUSTER_NAME-$MANAGER_NAME..."
ceph-mgr -d --debug_ms $LOG_LEVEL --id=$MANAGER_NAME --cluster=$CLUSTER_NAME
