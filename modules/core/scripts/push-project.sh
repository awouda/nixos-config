#!/usr/bin/env bash
# Usage: push-project [-n|--dry-run] <repo_name>

MAC_BASE="/Users/${WORK_ID}/dev/${WORK}"
WOJO_BASE="/home/alex/projects/${WORK}"

# Default: No dry run
DRY_RUN=""

# Check for dry-run flag
if [[ "$1" == "-n" || "$1" == "--dry-run" ]]; then
    DRY_RUN="--dry-run"
    shift # Remove the flag from arguments, so $1 becomes the repo name
fi

REPO=$1
if [ -z "$REPO" ]; then echo "Usage: push-project [-n] <repo_name>"; exit 1; fi

if [[ -z "$WORK_ID" || -z "$MAC_IP" || -z "$WORK" ]]; then
    echo "Error: WORK_ID, WORK, or MAC_IP not set."
    exit 1
fi

echo "Syncing $REPO to Mac (Excluding Aider/Git)..."
[[ -n "$DRY_RUN" ]] && echo "--- DRY RUN ONLY: No files will be changed ---"

# The rsync command
rsync -avzP $DRY_RUN \
    --exclude={'.git/','.aider*','.aider.tags.cache.v4/','.aiderignore'} \
    --exclude={'*.class','*.jar','build/','.gradle/','.idea/','bin/'} \
    "${WOJO_BASE}/${REPO}/" "${WORK_ID}@${MAC_IP}:${MAC_BASE}/${REPO}/"
