FROM debian:latest

ARG SNAP_MAJOR_VERSION=6
ARG SNAP_MINOR_VERSION=0
ENV SNAP_VERSION=${SNAP_MAJOR_VERSION}_${SNAP_MINOR_VERSION}
ENV DOWNLOAD_URL=http://step.esa.int/downloads/${SNAP_MAJOR_VERSION}.${SNAP_MINOR_VERSION}/installers/esa-snap_sentinel_unix_${SNAP_VERSION}.sh

RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    bc \
    ca-certificates \
    curl \
    jq \
    unzip \
  && rm -rf /var/lib/apt/lists/* \
  && curl -q ${DOWNLOAD_URL} -o esa-snap_sentinel_unix_${SNAP_VERSION}.sh \
  && chmod +x esa-snap_sentinel_unix_${SNAP_VERSION}.sh \
  && ./esa-snap_sentinel_unix_${SNAP_VERSION}.sh -q \
  && ln -s /usr/local/snap/bin/gpt /usr/bin/gpt \
  && sed -i -e 's/-Xmx\d+G/-Xmx4G/g' /usr/local/snap/bin/gpt.vmoptions  \
  && rm -rf esa-snap_sentinel_unix_${SNAP_VERSION}.sh \
  && mkdir /snap

WORKDIR /snap

COPY files/ /
