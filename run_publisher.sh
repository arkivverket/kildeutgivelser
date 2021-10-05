#!/usr/bin/env bash

# Runs sync between Edith and git
docker run --rm \
    -v svn_sync_cache:/tmp/svn_sync_cache \
    --env-file /srv/kildeutgivelser/.env \
    --network kildeutgivelser_svn \
    kildeutgivelser/svn_sync


# Runs the publisher script. Disregard that it says "stattholder", the name does not matter that much.
docker run --rm \
    -v /srv/stattholder_files:/var/stattholder-files/ \
    -v /srv/kildeutgivelser/api/config_templates:/config_templates \
    --env-file /srv/kildeutgivelser/.env \
	--network traefik \
    kildeutgivelser/api python /app/sls_api/scripts/publisher.py stattholder --all_ids

# Just tracking that it actually works and runs through fine
echo $(date +"%Y-%m-%dT%H:%M:%S%z") > /tmp/run_publisher.log
