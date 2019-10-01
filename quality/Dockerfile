FROM 52north/testbed-eopad-snap:latest
  
ADD calculate_quality.sh /usr/local/bin/process

ENV SCIHUB_USERNAME= \
    SCIHUB_PASSWORD= \
    INPUT_SOURCE= \
    INPUT_AREA_OF_INTEREST= \
    OUTPUT_CLOUD_COVERAGE=

COPY statistics.xml geosjon-to-wkt.jq /snap/

CMD [ "/usr/local/bin/process" ]
