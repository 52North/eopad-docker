#/bin/sh 

set -ex

docker build --pull -t 52north/testbed-eopad-snap:latest snap/
docker push 52north/testbed-eopad-snap:latest

docker build --pull -t 52north/testbed-eopad-ndvi:latest ndvi/
docker push 52north/testbed-eopad-ndvi:latest

docker build --pull -t 52north/testbed-eopad-quality:latest quality/
docker push 52north/testbed-eopad-quality:latest

#docker run --rm -it \
#  --env INPUT_SOURCE=S2B_MSIL1C_20190614T103029_N0207_R108_T32ULC_20190614T124423 \
#  --env SCIHUB_USERNAME=autermann \
#  --env SCIHUB_PASSWORD=$(pass show Web/scihub.copernicus.eu/autermann) \
#  --env INPUT_NIR_FACTOR=1.0 \
#  --env INPUT_RED_FACTOR=1.0 \
#  --env OUTPUT_RASTER=/data/outputs/raster.tiff \
#  --volume $(pwd):/data/outputs \
#  ndvi:latest

#docker run --rm -it \
#  --env INPUT_SOURCE=S2B_MSIL1C_20190614T103029_N0207_R108_T32ULC_20190614T124423 \
#  --env SCIHUB_USERNAME=autermann \
#  --env SCIHUB_PASSWORD=$(pass show Web/scihub.copernicus.eu/autermann) \
#  --env INPUT_AREA_OF_INTEREST=geoRegion.json \
#  --volume $(pwd):/data/outputs \
#  quality:latest
