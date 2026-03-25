#!/usr/bin/env bash
# Usage: sync-gradle-cache

MAC_GRADLE="/Users/${WORK_ID}/.gradle"
WOJO_GRADLE="/home/alex/.gradle"

if [[ -z "$WORK_ID" || -z "$MAC_IP" ]]; then
    echo "Error: WORK_ID or MAC_IP not set."
    exit 1
fi

echo "Syncing Gradle libraries..."
rsync -avzP -u --delete \
    --exclude={'daemon/','native/','workers/','*.lock','*.lck','jdks/'} \
    "${WORK_ID}@${MAC_IP}:${MAC_GRADLE}/caches/modules-2/" "${WOJO_GRADLE}/caches/modules-2/"

rsync -avzP -u \
    "${WORK_ID}@${MAC_IP}:${MAC_GRADLE}/wrapper/dists/" "${WOJO_GRADLE}/wrapper/dists/"
