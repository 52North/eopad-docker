FROM snap:latest

RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends jq unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/* 

ADD calculate_ndvi.sh /usr/local/bin/calculate_ndvi.sh

ENV SCIHUB_USERNAME=
ENV SCIHUB_PASSWORD=

ENV INPUT_SOURCE=
ENV INPUT_NIR_FACTOR=1.0
ENV INPUT_NIR_SOURCE_BAND=
ENV INPUT_RED_FACTOR=1.0
ENV INPUT_RED_SOURCE_BAND=
ENV OUTPUT_RASTER=
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "/usr/local/bin/calculate_ndvi.sh" ]