FROM flaviostutz/ceph-base

ENV CLUSTER_NAME 'ceph'
ENV PEER_MONITOR_HOST ''
ENV ETCD_URL ''
ENV LOG_LEVEL 0

ADD startup.sh /
ADD ceph.conf.template /

CMD [ "/startup.sh" ]


