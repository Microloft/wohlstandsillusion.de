#!/usr/bin/env bash
set -euo pipefail

# wohlstandsillusion.de - Deployment Script
# Atomischer Symlink-Switch mit Release-Rotation

SITE_DIR="/var/www/wohlstandsillusion.de"
REPO_DIR="${SITE_DIR}/repo"
RELEASES_DIR="${SITE_DIR}/releases"
CURRENT_LINK="${SITE_DIR}/current"
KEEP_RELEASES=5

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RELEASE_DIR="${RELEASES_DIR}/${TIMESTAMP}"

echo "=== Deploy wohlstandsillusion.de ==="
echo "Release: ${TIMESTAMP}"

# 1. Git pull
echo "--- Git pull ---"
cd "${REPO_DIR}"
git pull origin main

# 2. Hugo build
echo "--- Hugo build ---"
hugo --minify --cleanDestinationDir

# 3. Kopiere Build-Output in Release-Verzeichnis
echo "--- Kopiere nach ${RELEASE_DIR} ---"
mkdir -p "${RELEASE_DIR}"
cp -r "${REPO_DIR}/public/." "${RELEASE_DIR}/"

# 4. Atomischer Symlink-Switch
echo "--- Symlink-Switch ---"
ln -sfn "${RELEASE_DIR}" "${CURRENT_LINK}.new"
mv -Tf "${CURRENT_LINK}.new" "${CURRENT_LINK}"

echo "--- Aktiv: $(readlink -f ${CURRENT_LINK}) ---"

# 5. Alte Releases aufräumen
echo "--- Cleanup (behalte letzte ${KEEP_RELEASES}) ---"
cd "${RELEASES_DIR}"
ls -1d */ 2>/dev/null | head -n -${KEEP_RELEASES} | xargs -r rm -rf

echo "=== Deploy abgeschlossen ==="
