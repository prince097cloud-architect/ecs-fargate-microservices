# #!/usr/bin/env bash
# set -e
# TARGET_URL="http://${SERVICE_A_HOST:-service-a.local}:8080/actuator/health"
# MAX_RETRIES=${MAX_RETRIES:-60}
# SLEEP_SEC=${SLEEP_SEC:-5}


# echo "Waiting for Service A at $TARGET_URL"
# count=0
# until curl -sf $TARGET_URL >/dev/null; do
# count=$((count+1))
# if [ "$count" -ge "$MAX_RETRIES" ]; then
# echo "Service A did not become healthy after $MAX_RETRIES attempts. Exiting."
# exit 1
# fi
# echo "Service A not ready yet (attempt: $count). Sleeping $SLEEP_SEC s..."
# sleep $SLEEP_SEC
# done


# # Start main app
# exec java -jar /app/app.jar

#!/bin/bash

# This script simulates a health check for Service A.
# You can add your health check logic here.

echo "Service B is starting..."