#!/usr/bin/env bash
# Deployment script for partner-app-backend via webhook

GIT_URL="git@github.com:bikefixup/partner-app-backend.git"
REPO="partner-app-backend"
REPO_DIR="/srv/apps/${REPO}"
LOG_FILE="/srv/apps/webhook/webhook.log"
export GIT_SSH_COMMAND="ssh -i /srv/admin/vault/webhook-key-ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/srv/admin/vault/webhook-known_hosts"

write_log() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp --- [$REPO] $1" >> "$LOG_FILE"
}

# Create a backup of existing directory
# NOTE: An error is possible if some of the files in $REPO_DIR were altered manually on the server/
# In this case the directory has to be removed manually.
write_log "Clearing up existing files"
rm -rf $REPO_DIR || { write_log "An error occurred while clearing old files"; }

# Clone repository
write_log "Cloning repository from github"
git clone $GIT_URL $REPO_DIR >> $LOG_FILE || { write_log "Failed to clone the repository" ; exit 1; }
write_log "Cloned repository successfully"

# Change working directory
pushd "$REPO_DIR"
write_log "Channged working directory to $PWD"

# Build sequence
write_log "Copying .env file"
cp /srv/admin/vault/partner-app-backend.env .env
write_log "Running composer update & install"
composer update >> $LOG_FILE  2>&1  || { write_log "Composer update failed"; exit 1; }
composer install --prefer-dist --no-dev --optimize-autoloader >> $LOG_FILE || { write_log "Composer packages installation failed"; exit 1; }

write_log "Running npm install & build"
npm install >> $LOG_FILE || { write_log "npm install failed"; exit 1; }
npm run build >> $LOG_FILE || { write_log "npm build failed"; exit 1; }

write_log "Linking storage" 
php artisan storage:link || { write_log "Failed linking storage"; exit 1; }

popd

write_log "Deployment completed"