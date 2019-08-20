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

if [ -z ${Pdownsampling} ]; then
  Pdownsampling=Min
fi

if [ -z ${PflagDownsampling} ]; then
  PflagDownsampling=First
fi

if [ -z ${Presolution} ]; then
  Presolution=20
fi

if [ -z ${Pupsampling} ]; then
  Pupsampling=Bicubic
fi

echo "Starting quality process."

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

#snap --nosplash --nogui --modules --update-all

# Resample product
gpt S2Resampling -SsourceProduct=${INPUT_SOURCE} -Pdownsampling=${Pdownsampling} -PflagDownsampling=${PflagDownsampling} -Presolution=${Presolution} -Pupsampling=${Pupsampling} -t resampled -f BEAM-DIMAP

# Identify pixels
gpt Idepix.Sentinel2 -Sl1cProduct=resampled.dim -t idepix -f BEAM-DIMAP

# Use only a subset of the scene
# gpt Subset ...

# Calculate statistics
gpt statistics.xml idepix.dim 

# Retrieve relevant info from statistics and calculate percentage of cloud coverage 
CLOUD=$(awk 'NR==2{print $9}' statistics.asc)  
TOTAL=$(awk 'NR==2{print $20}' statistics.asc) 
INVALID=$(awk 'NR==2{print $13}' statistics.asc) 
CLOUD_COVERAGE=$(( ${CLOUD} * 100 / (${TOTAL}-${INVALID}) ))





