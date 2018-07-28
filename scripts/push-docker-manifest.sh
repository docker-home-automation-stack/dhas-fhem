#!/bin/bash
set -e

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  exit 0
fi

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
sleep $[ ( $RANDOM % 10 )  + 1 ]s

for VARIANT in $( docker images | grep '^homeautomationstack/*' | grep -v "<none>" | grep -P ' dev|beta|latest ' | awk '{print $2}' | uniq | sort ); do
  echo "Creating manifest file homeautomationstack/dhas-fhem:${VARIANT} ..."
  docker manifest create homeautomationstack/dhas-fhem:${VARIANT} \
    homeautomationstack/dhas-fhem-amd64_linux:${VARIANT} \
    homeautomationstack/dhas-fhem-i386_linux:${VARIANT} \
    homeautomationstack/dhas-fhem-arm32v5_linux:${VARIANT} \
    homeautomationstack/dhas-fhem-arm32v7_linux:${VARIANT} \
    homeautomationstack/dhas-fhem-arm64v8_linux:${VARIANT}
  docker manifest annotate homeautomationstack/dhas-fhem:${VARIANT} homeautomationstack/dhas-fhem-arm32v5_linux:${VARIANT} --os linux --arch arm --variant v5
  docker manifest annotate homeautomationstack/dhas-fhem:${VARIANT} homeautomationstack/dhas-fhem-arm32v7_linux:${VARIANT} --os linux --arch arm --variant v7
  docker manifest annotate homeautomationstack/dhas-fhem:${VARIANT} homeautomationstack/dhas-fhem-arm64v8_linux:${VARIANT} --os linux --arch arm64 --variant v8
  docker manifest inspect homeautomationstack/dhas-fhem:${VARIANT}

  echo "Pushing manifest homeautomationstack/dhas-fhem:${VARIANT} to Docker Hub ..."
  docker manifest push homeautomationstack/dhas-fhem:${VARIANT}

  echo "Requesting current manifest from Docker Hub ..."
  docker run --rm mplatform/mquery homeautomationstack/dhas-fhem:${VARIANT}
done

exit 0
