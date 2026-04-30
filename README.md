# wohlstandsillusion.de

Statische Webseite zur Vermögensverteilung in Deutschland und ihren Folgen für Sozialstaat, Renten, Pflege und Steuergerechtigkeit.

## Technologie

- **Static Site Generator:** [Hugo](https://gohugo.io/) (Extended Edition)
- **CSS:** Handgeschriebenes CSS mit Custom Properties, verarbeitet über Hugo Pipes
- **Fonts:** Inter (Sans-Serif, Headlines) + Source Serif 4 (Serif, Fließtext), lokal gehostet
- **Hosting:** Apache 2 auf Ubuntu VPS bei Netcup
- **TLS:** Let's Encrypt via certbot

## Lokaler Build

### Voraussetzungen

- Hugo Extended >= 0.161.0 ([Installation](https://gohugo.io/installation/))

### Entwicklungsserver starten

```bash
hugo server --buildDrafts
```

Die Seite ist dann unter `http://localhost:1313/` erreichbar.

### Produktions-Build

```bash
hugo --minify
```

Der Output liegt im Verzeichnis `public/`.

## Deployment

### Workflow

1. Lokal bauen und testen
2. Änderungen committen und nach GitHub pushen
3. Per SSH auf dem VPS das Deployment-Skript auslösen:

```bash
ssh vps "bash /var/www/wohlstandsillusion.de/repo/deploy/deploy.sh"
```

### Was das Skript macht

1. `git pull origin main` im Repo-Verzeichnis auf dem VPS
2. `hugo --minify` baut die Seite
3. Kopiert den Build-Output in ein Release-Verzeichnis mit Zeitstempel
4. Schaltet den Apache-DocumentRoot per atomischem Symlink-Switch um
5. Räumt alte Releases auf (behält die letzten 5)

### VPS erstmalig einrichten

```bash
# Verzeichnisse anlegen
sudo mkdir -p /var/www/wohlstandsillusion.de/{repo,releases}

# Repo klonen
sudo git clone <GITHUB_REPO_URL> /var/www/wohlstandsillusion.de/repo

# Hugo installieren
sudo snap install hugo

# Apache-Konfiguration
sudo cp /var/www/wohlstandsillusion.de/repo/deploy/apache-vhost.conf \
  /etc/apache2/sites-available/wohlstandsillusion.de.conf
sudo a2enmod ssl rewrite headers expires deflate
sudo a2ensite wohlstandsillusion.de.conf
sudo apachectl configtest
sudo systemctl reload apache2

# TLS-Zertifikat (nach DNS-Umstellung)
sudo certbot --apache -d wohlstandsillusion.de -d www.wohlstandsillusion.de

# Erster Deploy
bash /var/www/wohlstandsillusion.de/repo/deploy/deploy.sh
```

## Verzeichnisstruktur

```
content/          Markdown-Inhalte
layouts/          Hugo-Templates
assets/css/       CSS-Quelldateien (Hugo Pipes)
static/fonts/     Lokal gehostete Webfonts
static/images/    Bilder und Platzhalter
deploy/           Apache-Konfiguration und Deployment-Skript
public/           Build-Output (gitignored)
```

## Design

- Primärfarbe: Dunkelblau `#1E3A8A`
- Schriftarten: Source Serif 4 (Fließtext), Inter (Headlines)
- Mobile-first, responsive
- Keine externen Ressourcen, kein Tracking, keine Cookies
