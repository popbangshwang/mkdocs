#!/bin/bash
# ensure that the mkdocs container is stopped
docker compose down
# remove existing docker image for mkdocs
docker image remove mkdocs
# remove the docs directory that was a part of the original clone
rm -rf docs
# remove previous version of the git clone
rm -rf mkdocs
# clone the repo for the latest version of the docs
git clone $1
# bring up the mkdocs container using the docker-compose.yml
docker compose up -d