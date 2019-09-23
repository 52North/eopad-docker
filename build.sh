#/bin/sh 

set -ex

docker build --pull -t 52north/testbed-eopad-snap:latest snap/
docker push 52north/testbed-eopad-snap:latest

docker build --pull -t 52north/testbed-eopad-ndvi:latest ndvi/
docker push 52north/testbed-eopad-ndvi:latest

docker build --pull -t 52north/testbed-eopad-quality:latest quality/
docker push 52north/testbed-eopad-quality:latest

