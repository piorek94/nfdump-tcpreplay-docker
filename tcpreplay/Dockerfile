FROM phusion/baseimage:focal-1.0.0

ENV TCPREPLAY_DATA_DIR "/data"

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install tcpreplay && \
    mkdir "$TCPREPLAY_DATA_DIR" && \
    mkdir /entrypoint-init.d && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /usr/local/bin/
COPY 000_rewrite_pcap.sh /entrypoint-init.d/

WORKDIR "$TCPREPLAY_DATA_DIR"

ENTRYPOINT ["entrypoint.sh"]
CMD ["/sbin/my_init"]
