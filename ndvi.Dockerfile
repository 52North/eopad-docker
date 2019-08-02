FROM snap:latest

LABEL javaps.docker.version="1.4.0" \
  javaps.docker.process.identifier="org.n52.eopad.ndvi" \
  javaps.docker.process.title="NDVI for Sentinel-2 Scenes" \
  javaps.docker.process.abstract="NDVI for Sentinel-2 Scenes using the SNAP Toolbox NDVI process" \
  javaps.docker.process.inputs.INPUT_SOURCE="Sentinel-2 Filename; String" \
  javaps.docker.process.inputs.INPUT_NIR_FACTOR="NIR Factor; double" \
  javaps.docker.process.inputs.INPUT_NIR_BAND="NIR Band; String" \
  javaps.docker.process.inputs.INPUT_RED_FACTOR="RED Factor; double" \
  javaps.docker.process.inputs.INPUT_RED_BAND="RED Band; String" \
  javaps.docker.process.outputs.OUTPUT_RASTER="RED Band; String"


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