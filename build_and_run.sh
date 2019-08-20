#/bin/sh -e

docker build -t snap:latest -f snap.Dockerfile .
docker build -t ndvi:latest -f ndvi.Dockerfile .
docker build -t quality:latest -f quality.Dockerfile .

docker run --rm -it \
  --env INPUT_SOURCE=S2B_MSIL1C_20190614T103029_N0207_R108_T32ULC_20190614T124423 \
  --env SCIHUB_USERNAME=autermann \
  --env SCIHUB_PASSWORD=$(pass show Web/scihub.copernicus.eu/autermann) \
  --env INPUT_NIR_FACTOR=1.0 \
  --env INPUT_RED_FACTOR=1.0 \
  --env OUTPUT_RASTER=/data/outputs/raster.tiff \
  --volume $(pwd):/data/outputs \
  ndvi:latest

docker run --rm -it \
  --env INPUT_SOURCE=S2B_MSIL1C_20190614T103029_N0207_R108_T32ULC_20190614T124423 \
  --env SCIHUB_USERNAME=autermann \
  --env SCIHUB_PASSWORD=$(pass show Web/scihub.copernicus.eu/autermann) \
  --env Pdownsampling=Min \
  --env PflagDownsampling=First \
  --env Presolution=20 \
  --env Pupsampling=Bicubic \
  --volume $(pwd):/data/outputs \
  quality:latest
