FROM 52north/testbed-eopad-snap:latest

ADD process.sh /usr/local/bin/process

ENV SCIHUB_USERNAME= \
    SCIHUB_PASSWORD= \
    INPUT_SOURCE= \ 
    INPUT_NIR_FACTOR=1.0 \
    INPUT_NIR_SOURCE_BAND= \
    INPUT_RED_FACTOR=1.0 \
    INPUT_RED_SOURCE_BAND= \
    OUTPUT_RASTER=

CMD [ "/usr/local/bin/process" ]