FROM centos

RUN yum -y update \
 && yum -y install openssl pciutils wget \
 && curl -O https://linux.dell.com/repo/hardware/dsu/bootstrap.cgi \
 && bash bootstrap.cgi \
 && dnf install srvadmin-idracadm7.x86_64 -y \
 && ln -s  /usr/lib64/libssl.so.1.1 /usr/lib64/libssl.so \
 && yum -y clean all

COPY boot-from-iso.sh /boot-from-iso.sh
#ENTRYPOINT ["/opt/dell/srvadmin/bin/idracadm7"]
ENTRYPOINT ["/boot-from-iso.sh"]
