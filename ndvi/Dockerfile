FROM 52north/testbed-eopad-snap:latest

RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends jq unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/* 

ADD calculate_ndvi.sh /usr/local/bin/calculate_ndvi.sh

ENV SCIHUB_USERNAME= \
    SCIHUB_PASSWORD= \
    INPUT_SOURCE= \ 
    INPUT_NIR_FACTOR=1.0 \
    INPUT_NIR_SOURCE_BAND= \
    INPUT_RED_FACTOR=1.0 \
    INPUT_RED_SOURCE_BAND= \
    OUTPUT_RASTER=

ENTRYPOINT [ "/bin/bash", "-c" ]

CMD [ "/usr/local/bin/calculate_ndvi.sh" ]