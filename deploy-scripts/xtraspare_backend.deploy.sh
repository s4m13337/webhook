#!/usr/bin/env bash
# Deployment script for xtraspare_frontend via webhook

GIT_URL="git@github.com:bikefixup/xtraspare_backend.git"
REPO="xtraspare_backend"
REPO_DIR="/srv/apps/${REPO}"
TMP_DIR="/tmp/${REPO}"
LOG_FILE="/srv/apps/webhook/webhook.log"
export GIT_SSH_COMMAND="ssh -i /srv/admin/vault/webhook-key-ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/srv/admin/vault/webhook-known_hosts"

write_log() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp --- [$REPO] $1" >> "$LOG_FILE"
}

write_log "Clearing old files"
rm -rf $REPO_DIR   # Clean up existing directory
write_log "Coning repository from github"
git clone $GIT_URL $TMP_DIR || { write_log "Failed to clone the repository" ; exit 1; }
write_log "Cloned repository successfully"
pushd "$TMP_DIR"

# Build sequence
write_log "Starting build process in $PWD"
write_log "Copying .env file"
cp /srv/admin/vault/xtraspare_backend.env .env

write_log "Installing packages"
npm install >> $LOG_FILE 2>&1 || { write_log "E: Install error" ; exit 1; }

write_log "Building standalone app"
npm run build >> $LOG_FILE 2>&1 || { write_log "E: Build error"; exit 1; }
            
write_log "Assembling build files"
cp -r .next/standalone build
cp -r public build/
cp -r .next/static build/.next/
cp .env build/.env

write_log "Installing sharp"
cd build 
npm install --legacy-peer-deps sharp >> $LOG_FILE 2>&1 
cd ..

write_log "Moving build files to target"
mv build "$REPO_DIR/"

write_log "Deleteing temporary files"
rm -rf "$TMP_DIR"

# Restart service
write_log "Restarting xtraspare_backend service"
sudo systemctl restart xtraspare_backend
popd

write_log "Deployment completed"