#!/usr/bin/env bash
# Deployment script for bf_backend via webhook

GIT_URL="git@github.com:bikefixup/crm.git"
REPO="crm"
REPO_DIR="/srv/apps/${REPO}"
TMP_DIR="/tmp/${REPO}"
LOG_FILE="/srv/apps/webhook/webhook.log"
export GIT_SSH_COMMAND="ssh -i /srv/admin/vault/webhook-key-ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/srv/admin/vault/webhook-known_hosts"

write_log() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp --- [$REPO] $1" >> "$LOG_FILE"
}

# Create a backup of existing directory
write_log "Clearing up existing files"
rm -rf $REPO_DIR || { write_log "An error occurred while clearing old files"; }

# Clone repository
write_log "Cloning repository from github"
git clone $GIT_URL $TMP_DIR || { write_log "Failed to clone the repository" ; exit 1; }
write_log "Cloned repository successfully"
pushd "${TMP_DIR}/backend"

# Build sequence
write_log "Running build"
mvn clean package >> $LOG_FILE || { write_log "An error occurred"; exit 1; }

# Move build to apps directory
write_log "Moving application to target directory"
mkdir -p "${REPO_DIR}/backend/config"
mv target/* "${REPO_DIR}/backend/"
write_log "Content of target directory"
ls "${REPO_DIR}/backend/" >> $LOG_FILE

write_log "Moving application properties file"
cp /srv/admin/vault/crm_backend.env "${REPO_DIR}/backend/config/application.yml"
write_log "Build complete"

# Restart service
sudo systemctl restart crm_backend

popd
# TODO: Build script for frontend

rm -rf $TMP_DIR
write_log "Deployment completed"