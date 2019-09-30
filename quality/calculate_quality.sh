#/bin/bash

set -ex

function fail() {
  echo "$@" >&2 && exit 1
}

cat > geojson-to-wkt.jq <<-'EOF'
  def join: map(tostring) | join(",");
  def wrap: "(\(.))";
  def wrap(t): t + wrap;
  def wkt:
    if .type == "Polygon" then
      .coordinates | map(flatten | join | wrap) | join | wrap("POLYGON")
    else
      error("Error: unsupported type \(.type)\n")
    end;
  . | wkt
EOF

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
            <expression>pixel_classif_flags.IDEPIX_INVALID</expression>
            <validPixelExpression>not IDEPIX_INVALID</validPixelExpression>
          </bandConfiguration>
          <bandConfiguration>
            <expression>pixel_classif_flags.IDEPIX_CLOUD</expression>
            <validPixelExpression>IDEPIX_CLOUD and not IDEPIX_INVALID</validPixelExpression>
          </bandConfiguration>
        </bandConfigurations>
        <outputAsciiFile>statistics.asc</outputAsciiFile>
      </parameters>
    </node>
  </graph>

EOF


[ -z "${SCIHUB_USERNAME}" ] && fail 'missing ${SCIHUB_USERNAME}'
[ -z "${SCIHUB_PASSWORD}" ] && fail 'missing ${SCIHUB_PASSWORD}'
[ -z "${INPUT_SOURCE}" ] && fail 'missing ${INPUT_SOURCE}'
[ -z "${INPUT_AREA_OF_INTEREST}" ] && fail 'missing ${INPUT_AREA_OF_INTEREST}'
[ -z "${OUTPUT_CLOUD_COVERAGE}" ] && fail 'missing ${OUTPUT_CLOUD_COVERAGE}'

echo "Starting quality process."

if [ "${INPUT_SOURCE_MIME_TYPE}" = "text/plain" ]; then
  INPUT_SOURCE=$(cat "${INPUT_SOURCE}")
  DATA_URL="$(curl -s -f -L -u "${SCIHUB_USERNAME}:${SCIHUB_PASSWORD}" -H "Accept: application/json"  "https://scihub.copernicus.eu/apihub/odata/v1/Products?\$filter=Name%20eq%20'${INPUT_SOURCE}'" | jq -r '.d.results[0].__metadata.media_src')"
  counter=1
  while [ $counter -le 3 ]; do
    echo "Downloading product (try #$counter)"
    STATUSCODE=$?
    echo "Download status code $STATUSCODE"
    if curl --silent --speed-time 15 --speed-limit 1024 -f -L -u "${SCIHUB_USERNAME}:${SCIHUB_PASSWORD}" -o "${INPUT_SOURCE}.zip" "${DATA_URL}"; then
      echo "Download succeeded"
      counter=4
      break
    else
      echo "Download failed, retrying..."
      ((counter++))
    fi
  done
elif [ "${INPUT_SOURCE_MIME_TYPE}" = "application/zip" ]; then
  mv "${INPUT_SOURCE}" "${INPUT_SOURCE}.zip"
fi

unzip "${INPUT_SOURCE}.zip"

#snap --nosplash --nogui --modules --update-all

# Resample product
gpt S2Resampling \
  -SsourceProduct=${INPUT_SOURCE}.SAFE \
  -Pdownsampling=${INPUT_DOWNSAMPLING:-Min} \
  -PflagDownsampling=${INPUT_FLAG_DOWNSAMPLING:-First} \
  -Presolution=${INPUT_RESOLUTION:-60} \
  -Pupsampling=${INPUT_UPSAMPLING:-Bilinear} \
  -t resampled \
  -f BEAM-DIMAP

GEO_REGION="$(jq -rf geojson-to-wkt.jq ${INPUT_AREA_OF_INTEREST})"

# Use only a subset of the scene
gpt Subset \
  -SsourceProduct=resampled.dim \
  -PgeoRegion=\"${GEO_REGION}\" \
  -t subset \
  -f BEAM-DIMAP

# Identify pixels
gpt Idepix.Sentinel2 \
  -Sl1cProduct=subset.dim \
  -t idepix \
  -f BEAM-DIMAP

# Calculate statistics
gpt statistics.xml idepix.dim 

# Retrieve relevant info from statistics and calculate percentage of cloud coverage 
CLOUD=$(awk 'NR==3{print $11}' <statistics.asc)
TOTAL=$(awk 'NR==2{print $11}' <statistics.asc)
echo "scale=2;(${CLOUD}*100)/(${TOTAL})" | bc > ${OUTPUT_CLOUD_COVERAGE}
