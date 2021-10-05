#!/usr/bin/env bash

# Runs sync between Edith and git
docker run --rm \
    --env-file /srv/kildeutgivelser/.env \
    -v svn_sync_cache:/tmp/svn_sync_cache \
    --network kildeutgivelser_svn \
    kildeutgivelser/svn_sync

# Runs the publisher script. Disregard that it says "stattholder", the name does not matter that much.
docker exec kildeutgivelser_api python /app/sls_api/scripts/publisher.py stattholder --all_ids

# Just tracking that it actually works and runs through fine
echo $(date +"%Y-%m-%dT%H:%M:%S%z") > /tmp/run_publisher.log
