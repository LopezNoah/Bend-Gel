#!/bin/sh
set -eu

image="${BEND_GEL_IMAGE:-bend-gel-sandbox}"

docker build --tag "$image" .
docker run --rm \
  --network=none \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  --pids-limit=256 \
  --memory=1g \
  "$image"
