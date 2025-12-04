#!/usr/bin/env bash
# Deployment script for webhook-test via webhook

GIT_URL="git@github.com:bikefixup/webhook-test.git"
REPO="webhook-test"
REPO_DIR="/srv/apps/${REPO}"
LOG_FILE="/srv/apps/deploy-scripts/webhook.log"
export GIT_SSH_COMMAND="ssh -i /srv/admin/vault/webhook-key-ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/srv/admin/vault/webhook-known_hosts"

write_log() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp --- [$REPO] $1" >> "$LOG_FILE"
}

# Check if directory exists
if [ -d "$REPO_DIR" ]; then
    write_log "Directory ${REPO} exists; pulling latest changes"
    pushd "$REPO_DIR"
    git pull $GIT_ULR || { write_log "Failed to pull latest updates" ; exit 1; }
    write_log "Pulled latest changes successfully"
# Create directory if not found
else
    write_log "Directory ${REPO} does not exist; cloning from github"
    git clone $GIT_URL $REPO_DIR || { write_log "Failed to clone the repository" ; exit 1; }
    pushd "$REPO_DIR"
    write_log "Cloned repository successfully"
fi

write_log "Starting build process in $PWD"
# Build sequence
# Restart service
popd
