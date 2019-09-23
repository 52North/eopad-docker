#/bin/bash

set -e

function fail() {
  echo "$@" >&2 && exit 1
}

[ -z "${SCIHUB_USERNAME}" ] && fail 'missing ${SCIHUB_USERNAME}'
[ -z "${SCIHUB_PASSWORD}" ] && fail 'missing ${SCIHUB_PASSWORD}'
[ -z "${INPUT_SOURCE}" ] && fail 'missing ${INPUT_SOURCE}'
[ -z "${INPUT_AREA_OF_INTEREST}" ] && fail 'missing ${INPUT_AREA_OF_INTEREST}'
[ -z "${OUTPUT_CLOUD_COVERAGE}" ] && fail 'missing ${OUTPUT_CLOUD_COVERAGE}'
[ -z "${INPUT_DOWNSAMPLING}" ] && INPUT_DOWNSAMPLING="Min"
[ -z "${INPUT_FLAG_DOWNSAMPLING}" ] && INPUT_FLAG_DOWNSAMPLING="First"
[ -z "${INPUT_RESOLUTION}" ] && INPUT_RESOLUTION="20"
[ -z "${INPUT_UPSAMPLING}" ] && INPUT_UPSAMPLING="Bicubic"

echo "Starting quality process."

if [ "${INPUT_SOURCE_MIME_TYPE}" = "text/plain" ]; then
  DATA_URL="$(curl -s -f -L -u "${SCIHUB_USERNAME}:${SCIHUB_PASSWORD}" -H "Accept: application/json"  "https://scihub.copernicus.eu/apihub/odata/v1/Products?\$filter=Name%20eq%20'${INPUT_SOURCE}'" | jq -r '.d.results[0].__metadata.media_src')"
  counter=1
  while [ $counter -le 3 ]; do
    echo "Downloading product (try #$counter)"
    curl --silent --speed-time 15 --speed-limit 1024 -f -L -u "${SCIHUB_USERNAME}:${SCIHUB_PASSWORD}" -o "${INPUT_SOURCE}.zip" "${DATA_URL}"
    STATUSCODE=$?
    echo "Download status code $STATUSCODE"
    if test "$STATUSCODE" != "0"; then
      echo "Download failed, retrying..."
      ((counter++))
    else
      echo "Download succeeded"
      counter=4
      break
    fi
  done
elif [ "${INPUT_SOURCE_MIME_TYPE}" = "application/zip" ]; then
  mv "${INPUT_SOURCE}" "${INPUT_SOURCE}.zip"
fi

unzip "${INPUT_SOURCE}.zip"

#snap --nosplash --nogui --modules --update-all

# Resample product
/usr/bin/gpt S2Resampling \
  -SsourceProduct=${INPUT_SOURCE} \
  -Pdownsampling=${INPUT_DOWNSAMPLING} \
  -FLAG_DOWNSAMPLING=${INPUT_FLAG_DOWNSAMPLING} \
  -Presolution=${INPUT_RESOLUTION} \
  -Pupsampling=${INPUT_UPSAMPLING} \
  -t resampled \
  -f BEAM-DIMAP

GEO_REGION="$(jq -rf /geojson-to-wkt.jq ${INPUT_AREA_OF_INTEREST})"

# Use only a subset of the scene
/usr/bin/gpt Subset \
  -SsourceProduct=resampled.dim \
  -PgeoRegion=\"${GEO_REGION}\" \
  -t subset \
  -f BEAM-DIMAP

# Identify pixels
/usr/bin/gpt Idepix.Sentinel2 \
  -Sl1cProduct=subset.dim \
  -t idepix \
  -f BEAM-DIMAP


cat > statistics.xml <<-'EOF'
  <graph id="quality-process">
    <version>1.0</version>
    <node id="statistics">
      <operator>StatisticsOp</operator>
      <sources>
        <sourceProducts>${sourceProducts}</sourceProducts>
      </sources>
      <parameters>
        <bandConfigurations>
          <bandConfiguration>
            <sourceBandName>pixel_classif_flags</sourceBandName>
            <retrieveCategoricalStatistics>true</retrieveCategoricalStatistics>
          </bandConfiguration>
        </bandConfigurations>
        <outputAsciiFile>statistics.asc</outputAsciiFile>
      </parameters>
    </node>
  </graph>
EOF

# Calculate statistics
/usr/bin/gpt /statistics.xml idepix.dim 

# Retrieve relevant info from statistics and calculate percentage of cloud coverage 
# CLOUD=$9, TOTAL=$20, INVALID=$13
awk 'NR==2{print ($9*100)/($20-$13)}' statistics.asc > ${OUTPUT_CLOUD_COVERAGE}
