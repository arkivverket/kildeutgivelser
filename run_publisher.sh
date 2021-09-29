#!/usr/bin/env bash

docker run --rm -it \
    --env-file /srv/kildeutgivelser/.env \
    -v svn_sync_cache:/tmp/svn_sync_cache \
    kildeutgivelser/svn_sync

docker exec kildeutgivelser_api python /app/sls_api/scripts/publisher.py stattholder --all_ids

echo $(date +"%Y-%m-%dT%H:%M:%S%z") > /tmp/run_publisher.log
