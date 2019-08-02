#/bin/bash

set -e

if [ -z "${SCIHUB_USERNAME}" ]; then
  echo 'missing ${SCIHUB_USERNAME}' >&2 && exit 1
fi

if [ -z "${SCIHUB_PASSWORD}" ]; then
  echo 'missing ${SCIHUB_PASSWORD}' >&2 && exit 1
fi

if [ -z "${INPUT_SOURCE}" ]; then
   echo 'missing ${INPUT_SOURCE}' >&2 && exit 1
fi

if [ -z "${OUTPUT_RASTER}" ]; then
   echo 'missing ${OUTPUT_RASTER}' >&2 && exit 1
fi

if [ -z ${INPUT_NIR_FACTOR} ]; then
  INPUT_NIR_FACTOR=1.0
fi

if [ -z ${INPUT_RED_FACTOR} ]; then
  INPUT_RED_FACTOR=1.0
fi

touch ${OUTPUT_RASTER}.meta

DATA_URL="$(curl -s -f -L -u "${SCIHUB_USERNAME}:${SCIHUB_PASSWORD}" -H "Accept: application/json"  "https://scihub.copernicus.eu/apihub/odata/v1/Products?\$filter=Name%20eq%20'${INPUT_SOURCE}'" | jq -r '.d.results[0].__metadata.media_src')"

counter=1
while [ $counter -le 3 ]
do
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

unzip ${INPUT_SOURCE}.zip


OPERATION=NDVIop
OPTS=(-PredFactor=${INPUT_RED_FACTOR} -PnirFactor=${INPUT_NIR_FACTOR})

if [ -n "${INPUT_RED_SOURCE_BAND}" ]; then
  OPTS+=(-PredSourceBand=${INPUT_RED_SOURCE_BAND})
fi

if [ -n "${INPUT_NIR_SOURCE_BAND}" ]; then
  OPTS+=(-PredSourceBand=${INPUT_NIR_SOURCE_BAND})
fi

OPTS+=(-Ssource=${INPUT_SOURCE}.SAFE)
OPTS+=(-f GeoTIFF -t ${OUTPUT_RASTER})

#snap --nosplash --nogui --modules --update-all

if [ $# -eq 0 ]; then
  echo "Running /usr/bin/gpt $OPERATION ${OPTS[@]}"
  /usr/bin/gpt "$OPERATION" "${OPTS[@]}"
  mv "${OUTPUT_RASTER}.tif" "${OUTPUT_RASTER}"
else
  exec /usr/bin/gpt $*
fi
