# FROM flaviostutz/ceph-base:latest
FROM cd319cebcf35

ENV CLUSTER_NAME 'ceph'
ENV JOIN_MONITOR_HOST ''
ENV MANAGER_NAME ''

ADD startup.sh /
ADD ceph.conf.template /

EXPOSE 6789

CMD [ "/startup.sh" ]


