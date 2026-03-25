#!/usr/bin/env bash
# Usage: pull-project <repo_name>

MAC_BASE="/Users/${WORK_ID}/dev/${WORK}"
WOJO_BASE="/home/alex/projects/${WORK}"

if [[ -z "$WORK_ID" || -z "$MAC_IP" || -z "$WORK" ]]; then
    echo "Error: WORK_ID, WORK, or MAC_IP not set."
    exit 1
fi

REPO=$1
if [ -z "$REPO" ]; then echo "Usage: pull-project <repo_name>"; exit 1; fi

echo "Pulling $REPO from Mac..."
rsync -avzP --exclude={'build/','.gradle/','.idea/','.DS_Store'} \
    "${WORK_ID}@${MAC_IP}:${MAC_BASE}/${REPO}/" "${WOJO_BASE}/${REPO}/"
