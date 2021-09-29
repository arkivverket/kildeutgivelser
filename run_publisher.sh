#!/usr/bin/env bash
docker exec kildeutgivelser_api python /app/sls_api/scripts/publisher.py stattholder --all_ids

echo $(date +"%Y-%m-%dT%H:%M:%S%z") > /tmp/run_publisher.log
