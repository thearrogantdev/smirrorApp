#!/usr/bin/env bash
set -euo pipefail

# Validate arguments
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <ip> <password> [ssh_user] [dest_root]"
  echo "Example: $0 192.168.1.100 mypassword dietpi /var/lib/smirror/webapp"
  exit 1
fi

IP=$1
PASSWORD=$2
SSH_USER=${3:-dietpi}                     # Defaults to 'dietpi'
DEST_ROOT=${4:-/var/lib/smirror/webapp}   # Defaults to '/var/lib/smirror/webapp'

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

# Change target folder to be under the system webapp versions path
VERSION_DIR="${DEST_ROOT}/versions/test"

# Step 1: Force delete, recreate, and temporarily grant ownership to SSH_USER (e.g. dietpi)
# so the rsync command doesn't hit "Permission Denied" errors!
echo "Wiping and preparing target folder: $VERSION_DIR..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SSH_USER@$IP" \
  "sudo rm -rf \"$VERSION_DIR\" && sudo mkdir -p \"$VERSION_DIR\" && sudo chown -R $SSH_USER \"$VERSION_DIR\""

# Step 2: Sync the contents of build/web/ directly to the destination
echo "Transferring debug assets..."
sshpass -p "$PASSWORD" rsync -avz --delete \
  -e "ssh -o StrictHostKeyChecking=no" \
  build/web/ \
  "$SSH_USER@$IP:$VERSION_DIR/"

# Step 3: Restore proper ownership back to 'smirror' so the backend can read and serve the files
echo "Restoring ownership of $VERSION_DIR to smirror:smirror..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SSH_USER@$IP" \
  "sudo chown -R smirror:smirror \"$VERSION_DIR\""

# Step 4: Create the system link and atomically set its ownership to smirror:smirror using chown -h
echo "Updating live system symlink..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SSH_USER@$IP" \
  "sudo ln -sfn \"versions/test\" \"${DEST_ROOT}/live\" && sudo chown -h smirror:smirror \"${DEST_ROOT}/live\""

echo "=========================================="
echo "✅ Debug deployment completed successfully!"
echo "   Target Folder: $SSH_USER@$IP:$VERSION_DIR"
echo "   Live Symlink:  ${DEST_ROOT}/live -> versions/test"
echo "=========================================="