#!/usr/bin/env bash
set -euo pipefail

# Validate arguments
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <ip> <password> [ssh_user] [dest_dir]"
  echo "Example: $0 192.168.1.100 mypassword dietpi /home/dietpi/webapp"
  exit 1
fi

IP=$1
PASSWORD=$2
SSH_USER=${3:-dietpi}                # Defaults to 'dietpi'
DEST_DIR=${4:-/home/dietpi/webapp}   # Defaults to '/home/dietpi/webapp'

# Ensure sshpass is installed on the host
if ! command -v sshpass &> /dev/null; then
  echo "❌ Error: 'sshpass' is required but not installed on this host."
  echo "   Please install it (e.g., 'sudo apt install sshpass')."
  exit 1
fi

echo "=========================================="
echo "==> 1. Cleaning and Building Web (Debug/Profile)"
echo "=========================================="
fvm flutter clean

# Build in Profile mode with Source Maps enabled for full debugging
fvm flutter build web --profile --wasm --source-maps

echo "==> 2. Applying aggressive Gzip compression..."
# Compress files larger than 1KB, including your debug source maps!
find build/web -type f -size +1k \( -name "*.wasm" -o -name "*.js" -o -name "*.mjs" -o -name "*.html" -o -name "*.css" -o -name "*.json" -o -name "*.map" \) -exec gzip -k -f -9 {} \;

echo "=========================================="
echo "==> 3. Deploying to Target via Rsync"
echo "=========================================="
echo "Connecting to $SSH_USER@$IP..."

# Step 1: Force delete and recreate the target folder to ensure 100% clean state
echo "Wiping and recreating target folder: $DEST_DIR..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SSH_USER@$IP" \
  "rm -rf \"$DEST_DIR\" && mkdir -p \"$DEST_DIR\""

# Step 2: Sync the contents of build/web/ directly to the destination
echo "Transferring debug assets..."
sshpass -p "$PASSWORD" rsync -avz --delete \
  -e "ssh -o StrictHostKeyChecking=no" \
  build/web/ \
  "$SSH_USER@$IP:$DEST_DIR/"

# Step 3: Create the system link to make it "live" for the backend
echo "Updating live system symlink..."
# We use sudo as requested because /var/lib/smirror is a protected system directory
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SSH_USER@$IP" \
  "sudo ln -sfn \"$DEST_DIR/\" /var/lib/smirror/webapp/live"

echo "=========================================="
echo "✅ Debug deployment completed successfully!"
echo "   Target Folder: $SSH_USER@$IP:$DEST_DIR"
echo "   Live Symlink:  /var/lib/smirror/webapp/live -> $DEST_DIR"
echo "=========================================="