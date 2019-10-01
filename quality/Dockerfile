FROM 52north/testbed-eopad-snap:6
  
ENV SCIHUB_USERNAME= \
    SCIHUB_PASSWORD= \
    INPUT_SOURCE= \
    INPUT_AREA_OF_INTEREST= \
    OUTPUT_CLOUD_COVERAGE=

COPY files/ /

CMD [ "/usr/bin/process" ]
