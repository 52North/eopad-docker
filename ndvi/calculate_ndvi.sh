#/bin/bash

set -e

function fail() {
  echo "$@" >&2 && exit 1
}

[ -z "${SCIHUB_USERNAME}" ] && fail 'missing ${SCIHUB_USERNAME}'
[ -z "${SCIHUB_PASSWORD}" ] && fail 'missing ${SCIHUB_PASSWORD}'
[ -z "${INPUT_SOURCE}" ] && fail 'missing ${INPUT_SOURCE}'
[ -z "${OUTPUT_RASTER}" ] && fail 'missing ${OUTPUT_RASTER}'
[ -z "${INPUT_NIR_FACTOR}" ] && INPUT_NIR_FACTOR=1.0
[ -z "${INPUT_RED_FACTOR}" ] && INPUT_RED_FACTOR=1.0

echo "Starting NDVI process. Result storage file: $OUTPUT_RASTER"

touch ${OUTPUT_RASTER}.meta
if [ "${INPUT_SOURCE_MIME_TYPE}" = "text/plain" ]; then
  DATA_URL="$(curl -s -f -L -u "${SCIHUB_USERNAME}:${SCIHUB_PASSWORD}" -H "Accept: application/json"  "https://scihub.copernicus.eu/apihub/odata/v1/Products?\$filter=Name%20eq%20'${INPUT_SOURCE}'" | jq -r '.d.results[0].__metadata.media_src')"

  counter=1
  while [ ${counter} -le 3 ]; do
    echo "Downloading product (try #${counter})"
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


OPERATION=NDVIop
OPTS=(-PredFactor=${INPUT_RED_FACTOR}
      -PnirFactor=${INPUT_NIR_FACTOR})

[ -n "${INPUT_RED_SOURCE_BAND}" ] && OPTS+=(-PredSourceBand=${INPUT_RED_SOURCE_BAND})
[ -n "${INPUT_NIR_SOURCE_BAND}" ] && OPTS+=(-PredSourceBand=${INPUT_NIR_SOURCE_BAND})

OPTS+=(-Ssource=${INPUT_SOURCE}.SAFE)
OPTS+=(-f GeoTIFF -t ${OUTPUT_RASTER})

#snap --nosplash --nogui --modules --update-all

if [ $# -eq 0 ]; then
  echo "Running /usr/bin/gpt ${OPERATION} ${OPTS[@]}"
  /usr/bin/gpt "${OPERATION}" "${OPTS[@]}"
  mv "${OUTPUT_RASTER}.tif" "${OUTPUT_RASTER}"
else
  exec /usr/bin/gpt $*
fi
