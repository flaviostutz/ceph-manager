# ceph-manager
Ceph Manager container image.

This image will retrieve keyring from ETCD in order to register the managers with monitors.

# Usage

docker-compose.yml for manager in HA

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
    environment:
      - ETCD_URL=http://etcd0:2379

  mgr1:
    image: flaviostutz/ceph-manager
    environment:
      - PEER_MONITOR_HOST=mon0
      - ETCD_URL=http://etcd0:2379

  mgr2:
    image: flaviostutz/ceph-manager
    environment:
      - PEER_MONITOR_HOST=mon0
      - ETCD_URL=http://etcd0:2379

```
