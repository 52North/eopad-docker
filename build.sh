#/bin/sh 

set -ex

docker build --pull -t 52north/testbed-eopad-snap:latest -t 52north/testbed-eopad-snap:6 snap/
docker build -t 52north/testbed-eopad-ndvi:latest ndvi/
docker build -t 52north/testbed-eopad-quality:latest quality/

docker push 52north/testbed-eopad-snap:latest
docker push 52north/testbed-eopad-snap:6
docker push 52north/testbed-eopad-ndvi:latest
docker push 52north/testbed-eopad-quality:latest

