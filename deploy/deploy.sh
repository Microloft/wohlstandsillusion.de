#!/usr/bin/env bash
set -euo pipefail

# wohlstandsillusion.de - Deployment Script
# =========================================
# Pull → Build → rsync zum DocumentRoot
#
# Voraussetzungen:
#   - Hugo Extended in /usr/local/bin/hugo
#   - Repo geklont nach ~/projects/wohlstandsillusion.de
#   - DocumentRoot existiert: /var/www/wohlstandsillusion.de
#   - User darf rsync mit sudo nach /var/www ausführen
#
# Ausführung (lokal von Windows-Laptop):
#   plink -i ~/.ssh/key.ppk microloft@w1tt3.de \
#     bash /home/microloft/projects/wohlstandsillusion.de/deploy/deploy.sh

REPO_DIR="${HOME}/projects/wohlstandsillusion.de"
DOCROOT="/var/www/wohlstandsillusion.de"

echo "=== Deploy wohlstandsillusion.de ==="

# 1. Git pull
echo "--- Git pull ---"
cd "${REPO_DIR}"
git pull origin main

# 2. Hugo build
echo "--- Hugo build ---"
hugo --minify --cleanDestinationDir

# 3. rsync zum DocumentRoot (atomar genug für statische Dateien)
echo "--- rsync nach ${DOCROOT} ---"
sudo rsync -av --delete "${REPO_DIR}/public/" "${DOCROOT}/"

# 4. Ownership wieder auf www-data setzen
sudo chown -R www-data:www-data "${DOCROOT}"

echo "=== Deploy abgeschlossen ==="
