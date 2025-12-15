#!/bin/bash

REPO="$1"
GIT_URL="git@github.com:bikefixup/${REPO}.git"
if [ "$REPO" = "bf_backend" ]; then
    REPO_DIR="/srv/apps/${REPO}_dev"
else
    REPO_DIR="/srv/apps/${REPO}"
    TMP_DIR="/tmp/${REPO}"
fi;

LOG_FILE="/srv/apps/webhook/webhook.log"
export GIT_SSH_COMMAND="ssh -i /srv/admin/vault/webhook-key-ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/srv/admin/vault/webhook-known_hosts"

write_log() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp --- [$REPO] $1" >> "$LOG_FILE"
}

write_log "Clearing up existing files"
rm -rf $REPO_DIR || { write_log "An error occurred while clearing old files"; }

write_log "Cloning repository from github"
if [ "$REPO" = "bf_backend" ]; then
    git clone -b dev --single-branch $GIT_URL $REPO_DIR >> $LOG_FILE || { write_log "Failed to clone the repository" ; exit 1; }
else 
    git clone $GIT_URL $TMP_DIR || { write_log "Failed to clone the repository" ; exit 1; }
fi;
write_log "Cloned repository successfully"

if [ "$REPO" = "bf_backend" ]; then
    pushd "$REPO_DIR"
else
    pushd "$TMP_DIR"
fi;
write_log "Working directory is $PWD"
ls -lah >> $LOG_FILE
write_log "Executing deploy script"
chmod +x deploy.sh
./deploy.sh "$REPO_DIR" "$LOG_FILE"
write_log "Deployment execution complete"
rm -rf $TMP_DIR
popd