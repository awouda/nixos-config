#!/usr/bin/env bash
# Usage: push-project <repo_name>

MAC_BASE="/Users/${WORK_ID}/dev/${WORK}"
WOJO_BASE="/home/alex/projects/${WORK}"

if [[ -z "$WORK_ID" || -z "$MAC_IP" || -z "$WORK" ]]; then
    echo "Error: WORK_ID, WORK, or MAC_IP not set."
    exit 1
fi

REPO=$1
if [ -z "$REPO" ]; then echo "Usage: push-project <repo_name>"; exit 1; fi

echo "Pushing $REPO to Mac..."
rsync -avzP --exclude={'*.class','*.jar','build/','.gradle/','.idea/','bin/'} \
    "${WOJO_BASE}/${REPO}/" "${WORK_ID}@${MAC_IP}:${MAC_BASE}/${REPO}/"
