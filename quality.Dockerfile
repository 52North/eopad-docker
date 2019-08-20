FROM snap:latest

LABEL javaps.docker.version="1.4.0" \
  javaps.docker.process.identifier="org.n52.eopad.quality" \
  javaps.docker.process.title="Calculation of quality of an area of interest for Sentinel-2" \
  javaps.docker.process.abstract="Calculation of quality of an area of interest for Sentinel-2" \
  javaps.docker.process.inputs.INPUT_SOURCE="Sentinel-2 Filename; String" \
  javaps.docker.process.inputs.Pdownsampling="Aggregation method of down sampling; String; Value must be one of 'First', 'Min', 'Max', 'Mean', 'Median'" \
  javaps.docker.process.inputs.PflagDownsampling="Aggregation method of flags; String; Value must be one of 'First', 'FlagAnd', 'FlagOr', 'FlagMedianAnd', 'FlagMedianOr'" \
  javaps.docker.process.inputs.Presolution="Resolution; String; Value must be one of '10', '20', '60'" \
  javaps.docker.process.inputs.Pupsampling="Interpolation method of up sampling; String; Value must be one of 'Nearest', 'Bilinear', 'Bicubic'" 

RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends jq unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/* 

ADD calculate_quality.sh /usr/local/bin/calculate_quality.sh
ADD statistics.xml /usr/local/bin/statistics.xml

ENV SCIHUB_USERNAME=
ENV SCIHUB_PASSWORD=

ENV INPUT_SOURCE=
ENTRYPOINT [ "/bin/bash", "-c" ]

CMD [ "/usr/local/bin/calculate_quality.sh" ]
