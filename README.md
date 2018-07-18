# ceph-manager
Ceph Manager container image

# Usage

docker-compose.yml

```
  mgr1:
    build: .
    environment:
      - LOG_LEVEL=10
      - JOIN_MONITOR_HOST=192.168.1.2
```
