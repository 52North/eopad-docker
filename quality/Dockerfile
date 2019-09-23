FROM 52north/testbed-eopad-snap:latest

RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends jq unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/* 

ADD calculate_quality.sh geojson-to-wkt.jq /

ENV SCIHUB_USERNAME= \
    SCIHUB_PASSWORD= \
    INPUT_SOURCE= \
    INPUT_AREA_OF_INTEREST= \
    OUTPUT_CLOUD_COVERAGE= \
    INPUT_DOWNSAMPLING=Min \
    INPUT_FLAG_DOWNSAMPLING=First \
    INPUT_RESOLUTION=20 \
    INPUT_UPSAMPLING=Bicubic

ENTRYPOINT [ "/bin/bash", "-c" ]

CMD [ "/calculate_quality.sh" ]
