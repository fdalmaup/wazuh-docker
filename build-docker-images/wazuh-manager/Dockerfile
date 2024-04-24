# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
FROM selutario/wazuh-dev-req

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ARG WAZUH_VERSION
ARG WAZUH_TAG_REVISION
ARG FILEBEAT_TEMPLATE_BRANCH
ARG FILEBEAT_CHANNEL=filebeat-oss
ARG FILEBEAT_VERSION=7.10.2
ARG WAZUH_FILEBEAT_MODULE
ARG S6_VERSION="v2.2.0.3"

RUN apt update
RUN apt install gcc g++ make libc6-dev curl policycoreutils automake autoconf libtool libssl-dev -y &&\
    apt clean all

COPY config/check_repository.sh /
COPY config/filebeat_module.sh /
COPY config/permanent_data.env config/permanent_data.sh /

# RUN chmod 775 /check_repository.sh
# RUN source /check_repository.sh

# Should install from sources...
# RUN yum install wazuh-manager-${WAZUH_VERSION}-${WAZUH_TAG_REVISION} -y 
# RUN yum update -y
# RUN yum install git make gcc gcc-c++ policycoreutils-python automake autoconf libtool centos-release-scl openssl-devel wget bzip2 devtoolset-7 -y
# RUN curl -OL http://packages.wazuh.com/utils/gcc/gcc-9.4.0.tar.gz && tar xzf gcc-9.4.0.tar.gz  && cd gcc-9.4.0/ && ./contrib/download_prerequisites && ./configure --enable-languages=c,c++ --prefix=/usr --disable-multilib --disable-libsanitizer && make -j$(nproc) && make install && ln -fs /usr/bin/g++ /bin/c++ && ln -fs /usr/bin/gcc /bin/cc && cd .. && rm -rf gcc-* && scl enable devtoolset-7 bash

# RUN curl -OL https://packages.wazuh.com/utils/cmake/cmake-3.18.3.tar.gz && tar -zxf cmake-3.18.3.tar.gz && cd cmake-3.18.3 && ./bootstrap --no-system-curl && make -j$(nproc) && make install
# RUN cd .. && rm -rf cmake-*

RUN git clone https://github.com/wazuh/wazuh -b spike/23068-vd-state-sync
COPY config/preloaded-vars.conf /wazuh/etc/
COPY config/entrypoint.sh /scripts/
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN /wazuh/install.sh

RUN apt clean all && \
    # chmod 775 /filebeat_module.sh && \
    # source /filebeat_module.sh && \
    # rm /filebeat_module.sh && \
    apt-get -y install filebeat && \
    curl --fail --silent -L https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz \
    -o /tmp/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin && \
    rm  /tmp/s6-overlay-amd64.tar.gz

COPY config/etc/ /etc/
COPY --chown=root:wazuh config/create_user.py /var/ossec/framework/scripts/create_user.py

COPY config/filebeat.yml /etc/filebeat/

RUN chmod go-w /etc/filebeat/filebeat.yml

ADD https://raw.githubusercontent.com/wazuh/wazuh/4.8.0/extensions/elasticsearch/7.x/wazuh-template.json /etc/filebeat
RUN chmod go-w /etc/filebeat/wazuh-template.json

# Prepare permanent data
# Sync calls are due to https://github.com/docker/docker/issues/9547

#Make mount directories for keep permissions

RUN mkdir -p /var/ossec/var/multigroups && \
    chown root:wazuh /var/ossec/var/multigroups && \
    chmod 770 /var/ossec/var/multigroups && \
    mkdir -p /var/ossec/agentless && \
    chown root:wazuh /var/ossec/agentless && \
    chmod 770 /var/ossec/agentless && \
    mkdir -p /var/ossec/active-response/bin && \
    chown root:wazuh /var/ossec/active-response/bin && \
    chmod 770 /var/ossec/active-response/bin && \
    chmod 755 /permanent_data.sh && \
    sync && /permanent_data.sh && \
    sync && rm /permanent_data.sh

# Services ports
EXPOSE 55000/tcp 1514/tcp 1515/tcp 514/udp 1516/tcp

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
