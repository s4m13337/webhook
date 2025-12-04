#!/usr/bin/env bash
echo "Deploying code to server"
rsync -avz index.php bikefixup:/srv/apps/webhook/
rsync -avz deploy-scripts bikefixup:/srv/apps/
ssh bikefixup "chmod +x /srv/apps/deploy-scripts/*.sh && chown hodor:srvusers /srv/apps/deploy-scripts/*.sh"
echo "Deployment complete!"
