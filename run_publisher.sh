#!/usr/bin/env bash

docker run --rm \
    --env-file /srv/kildeutgivelser/.env \
    -v svn_sync_cache:/tmp/svn_sync_cache \
    --network kildeutgivelser_svn \
    kildeutgivelser/svn_sync

docker exec kildeutgivelser_api python /app/sls_api/scripts/publisher.py stattholder --all_ids

echo $(date +"%Y-%m-%dT%H:%M:%S%z") > /tmp/run_publisher.log
