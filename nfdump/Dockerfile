FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive
ENV NFDUMP_DATA_DIR "/data"

ARG NFDUMP_VERSION=master
ARG NFDUMP_BASE_URL=https://github.com/phaag/nfdump/archive
ARG NFDUMP_CC

RUN apt-get update && \
    apt-get install -y wget unzip apt-utils make pkg-config libtool autoconf autogen bison byacc flex libbz2-dev libpcap-dev clang && \
    wget $NFDUMP_BASE_URL/$NFDUMP_VERSION.zip && \
    unzip $NFDUMP_VERSION.zip -d /usr/src/ && \
    cd /usr/src/nfdump-$NFDUMP_VERSION && \
    ./autogen.sh && \
    env CC=$NFDUMP_CC ./configure --enable-sflow && \
    make && \
    make install && \
    ldconfig && \
    mkdir "$NFDUMP_DATA_DIR" && \
    mkdir /entrypoint-init.d && \
    rm /$NFDUMP_VERSION.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /usr/local/bin/
COPY 000_nfexpire_init.sh /entrypoint-init.d/

WORKDIR "$NFDUMP_DATA_DIR"

EXPOSE 10000/udp
VOLUME ["$NFDUMP_DATA_DIR"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"]
