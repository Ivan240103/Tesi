#!/bin/bash 
set -x

docker container prune -f
docker volume prune -f
docker image prune -f
docker network prune -f
