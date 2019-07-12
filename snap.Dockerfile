FROM debian:latest

RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends 'curl' \
  && rm -rf /var/lib/apt/lists/* 

# download snap installer version 6.0
RUN set -ex \
  && curl -q http://step.esa.int/downloads/6.0/installers/esa-snap_sentinel_unix_6_0.sh \
        -o esa-snap_sentinel_unix_6_0.sh \
  && chmod +x esa-snap_sentinel_unix_6_0.sh \
  && ./esa-snap_sentinel_unix_6_0.sh -q \
  && ln -s /usr/local/snap/bin/gpt /usr/bin/gpt \
  && sed -i -e 's/-Xmx1G/-Xmx4G/g' /usr/local/snap/bin/gpt.vmoptions 

ENTRYPOINT ["/usr/local/snap/bin/gpt"]
CMD ["-h"]
