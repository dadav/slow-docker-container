#!/bin/bash

CONTAINER_NAME="nginx-$RANDOM"
PORT="$RANDOM"

docker network create slow-net 2>/dev/null || true

docker run\
  --name $CONTAINER_NAME\
  --network slow-net\
  -p ${PORT}:80\
  -d\
  nginx

PID="$(docker inspect -f '{{ .State.Pid }}' $CONTAINER_NAME)"

sudo mkdir -p /var/run/netns
sudo ln -sfT /proc/$PID/ns/net /var/run/netns/$CONTAINER_NAME
sudo tc -n $CONTAINER_NAME qdisc add dev eth0 root netem delay 500ms

echo "Started container ${CONTAINER_NAME}. Checkout http://localhost:${PORT}"
