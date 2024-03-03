#!/bin/sh
# vim:sw=4:ts=4:et

set -e

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

# perform the initial clone and build for mkdocs
cd /opt/mkdocs
mkdocs build

# run the weblistner on port 8080 for github pushes
node /opt/webhook/webhook.js &

ME=$(basename "$0")

entrypoint_log "$ME: info: Mkdocs build in /opt/mkdocs"

exit 0