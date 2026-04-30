#!/usr/bin/env bash
set -euo pipefail

# Lokales Deployment-Skript: triggert Build + Deploy auf w1tt3.de.
#
# Voraussetzung: Sudo-Passwort des Users microloft liegt in
#   ~/.config/wohlstandsillusion-vps.secret  (chmod 600)
#
# Einrichten (einmalig):
#   mkdir -p ~/.config
#   echo 'DEIN_PASSWORT' > ~/.config/wohlstandsillusion-vps.secret
#   chmod 600 ~/.config/wohlstandsillusion-vps.secret
#
# Aufruf:
#   ./deploy-remote.sh

KEY="$HOME/OneDrive/Dokumente/KEYS/rsa-key-hauptserver-privat.ppk"
HOST="microloft@w1tt3.de"
PLINK="/c/Program Files/PuTTY/plink"
SECRET_FILE="$HOME/.config/wohlstandsillusion-vps.secret"
REMOTE_DEPLOY="/home/microloft/projects/wohlstandsillusion.de/deploy/deploy.sh"

if [[ ! -f "$SECRET_FILE" ]]; then
  echo "Fehler: $SECRET_FILE nicht gefunden." >&2
  echo "Einrichten:" >&2
  echo "  mkdir -p ~/.config" >&2
  echo "  echo 'DEIN_PASSWORT' > $SECRET_FILE" >&2
  echo "  chmod 600 $SECRET_FILE" >&2
  exit 1
fi

if [[ ! -f "$KEY" ]]; then
  echo "Fehler: SSH-Key nicht gefunden: $KEY" >&2
  exit 1
fi

echo "=== Deploy nach $HOST startet ==="

# Passwort via stdin an plink, dort von 'read' empfangen und an sudo -Sv weitergegeben
# Anschließend deploy.sh aufrufen (sudo-Timestamp ist dann frisch)
cat "$SECRET_FILE" | "$PLINK" -batch -i "$KEY" "$HOST" \
  "read PW && echo \"\$PW\" | sudo -Sv && bash $REMOTE_DEPLOY"

echo "=== Fertig: https://wohlstandsillusion.de/ ==="
