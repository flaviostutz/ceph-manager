# ceph-manager

[<img src="https://img.shields.io/docker/automated/flaviostutz/ceph-manager"/>](https://hub.docker.com/r/flaviostutz/ceph-manager)

Ceph Manager container image.

This image will retrieve keyring from ETCD in order to register the managers with monitors.

Attention: You need to run this daemon in a machine running Kernel >= 4.5.2

# Usage

docker-compose.yml for manager in HA (simple)

```
version: '3.5'

services:

  etcd0:
    image: quay.io/coreos/etcd:v3.2.25
    environment:
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd0:2379

  mon0:
    image: flaviostutz/ceph-monitor
    pid: host
    environment:
      - ETCD_URL=http://etcd0:2379

  mgr1:
    image: flaviostutz/ceph-manager
    pid: host
    environment:
      - MONITOR_HOSTS=mon0
      - ETCD_URL=http://etcd0:2379

  mgr2:
    image: flaviostutz/ceph-manager
    pid: host
    environment:
      - MONITOR_HOSTS=mon0
      - ETCD_URL=http://etcd0:2379

```

docker-compose.yml for a complete example (with Monitor, OSDs and Managers)

```
version: '3.5'

services:

  etcd0:
    image: quay.io/coreos/etcd
    environment:
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd0:2379

  mon0:
    image: flaviostutz/ceph-monitor
    pid: host
    environment:
      - CREATE_CLUSTER=true
      - ETCD_URL=http://etcd0:2379
      - PEER_MONITOR_HOSTS=mon1

  mon1:
    image: flaviostutz/ceph-monitor
    pid: host
    environment:
      - ETCD_URL=http://etcd0:2379
      - PEER_MONITOR_HOSTS=mon0

  mgr1:
    image: flaviostutz/ceph-manager
    pid: host
    ports:
      - 18443:8443 #dashboard https
      - 18003:8003 #restful https
      - 19283:9283 #prometheus
    environment:
      - LOG_LEVEL=0
      - MONITOR_HOSTS=mon0
      - ETCD_URL=http://etcd0:2379

  mgr2:
    image: flaviostutz/ceph-manager
    pid: host
    ports:
      - 28443:8443 #dashboard https
      - 28003:8003 #restful https
      - 29283:9283 #prometheus
    environment:
      - LOG_LEVEL=0
      - MONITOR_HOSTS=mon0
      - ETCD_URL=http://etcd0:2379

  osd1:
    image: flaviostutz/ceph-osd
    pid: host
    environment:
      - MONITOR_HOSTS=mon0
      - OSD_EXT4_SUPPORT=true
      - OSD_JOURNAL_SIZE=512
      - ETCD_URL=http://etcd0:2379

  osd2:
    image: flaviostutz/ceph-osd
    pid: host
    environment:
      - MONITOR_HOSTS=mon0
      - OSD_EXT4_SUPPORT=true
      - OSD_JOURNAL_SIZE=512
      - ETCD_URL=http://etcd0:2379

  osd3:
    image: flaviostutz/ceph-osd
    pid: host
    environment:
      - MONITOR_HOSTS=mon0
      - OSD_EXT4_SUPPORT=true
      - OSD_JOURNAL_SIZE=512
      - ETCD_URL=http://etcd0:2379

```

