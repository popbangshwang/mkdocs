#!/bin/sh

set -e

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

# perform the initial clone and build for mkdocs
GIT_REPO=$(echo $CRYPT_GIT_REPO | openssl enc -aes-256-ctr -pbkdf2 -a -k $RAND_VAR -d)
git clone $GIT_REPO /opt/mkdocs && cd /opt/mkdocs && mkdocs build

# run the weblistner on port 8080 for github pushes
cd /opt/webhook && python webhook.py &

ME=$(basename "$0")

entrypoint_log "$ME: info: Mkdocs build in /opt/mkdocs"

exit 0