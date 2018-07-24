FROM flaviostutz/ceph-base:ubuntu-luminous-12.2.4.0

ENV CLUSTER_NAME 'ceph'
ENV PEER_MONITOR_HOST ''
ENV ETCD_URL ''
ENV LOG_LEVEL 0

ADD startup.sh /
ADD ceph.conf.template /

EXPOSE 8443 9283 8003

CMD [ "/startup.sh" ]


