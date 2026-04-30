# wohlstandsillusion.de

Statische Webseite zur Vermögensverteilung in Deutschland und ihren Folgen für Sozialstaat, Renten, Pflege und Steuergerechtigkeit.

## Technologie

- **Static Site Generator:** [Hugo Extended](https://gohugo.io/) v0.161.1
- **CSS:** Handgeschriebenes CSS mit Custom Properties, verarbeitet über Hugo Pipes
- **Fonts:** Inter (Sans-Serif, Headlines) + Source Serif 4 (Serif, Fließtext), lokal gehostet
- **Hosting:** Apache 2.4 auf Ubuntu-VPS bei Netcup
- **TLS:** Let's Encrypt via certbot (`--apache`)

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

## Deployment-Workflow

1. Lokal bauen und testen
2. Änderungen committen und nach GitHub pushen
3. Per SSH auf dem VPS das Deployment-Skript auslösen:

```bash
plink -i ~/.ssh/microloft.ppk microloft@w1tt3.de \
  bash /home/microloft/projects/wohlstandsillusion.de/deploy/deploy.sh
```

Das Skript führt aus:

1. `git pull origin main` im Repo-Verzeichnis
2. `hugo --minify` baut die Seite
3. `rsync -av --delete public/ /var/www/wohlstandsillusion.de/`
4. `chown -R www-data:www-data /var/www/wohlstandsillusion.de`

## VPS erstmalig einrichten

Befehle als User `microloft` auf `w1tt3.de` (Befehle mit `sudo` benötigen das User-Passwort).

### 1. Hugo Extended installieren (Binary aus GitHub-Releases)

```bash
HUGO_VERSION="0.161.1"
cd /tmp
wget "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
tar -xzf "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
sudo mv hugo /usr/local/bin/
hugo version
```

### 2. Repo klonen

```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/Microloft/wohlstandsillusion.de.git
cd wohlstandsillusion.de
chmod +x deploy/deploy.sh
```

### 3. DocumentRoot anlegen

```bash
sudo mkdir -p /var/www/wohlstandsillusion.de
sudo chown -R www-data:www-data /var/www/wohlstandsillusion.de
```

### 4. Erster Build

```bash
cd ~/projects/wohlstandsillusion.de
hugo --minify
sudo rsync -av --delete public/ /var/www/wohlstandsillusion.de/
sudo chown -R www-data:www-data /var/www/wohlstandsillusion.de
```

### 5. Apache-Module aktivieren (falls nicht vorhanden)

```bash
sudo a2enmod expires
# ssl, rewrite, headers, deflate sind laut Server-Audit bereits aktiv
sudo systemctl reload apache2
```

### 6. Apache-Vhost einrichten (HTTP-only)

```bash
cd ~/projects/wohlstandsillusion.de
sudo cp deploy/apache-vhost.conf /etc/apache2/sites-available/wohlstandsillusion.de.conf
sudo apache2ctl configtest
sudo a2ensite wohlstandsillusion.de.conf
sudo systemctl reload apache2
```

### 7. DNS auf VPS umstellen

In der Netcup-Oberfläche A-Record und ggf. AAAA für `wohlstandsillusion.de` und `www.wohlstandsillusion.de` auf `202.61.204.119` setzen. Propagation abwarten (`dig wohlstandsillusion.de`).

### 8. TLS-Zertifikat via certbot

```bash
sudo certbot --apache -d wohlstandsillusion.de -d www.wohlstandsillusion.de
```

certbot erzeugt automatisch `/etc/apache2/sites-available/wohlstandsillusion.de-le-ssl.conf` und richtet den HTTP→HTTPS-Redirect in der HTTP-vhost-Datei ein.

### 9. Security-Headers in den HTTPS-Vhost einfügen

Inhalt aus `deploy/security-headers.conf` in den `<VirtualHost *:443>`-Block der `wohlstandsillusion.de-le-ssl.conf` einfügen (vor `</VirtualHost>`):

```bash
sudo nano /etc/apache2/sites-available/wohlstandsillusion.de-le-ssl.conf
# Inhalt aus ~/projects/wohlstandsillusion.de/deploy/security-headers.conf einfügen
sudo apache2ctl configtest
sudo systemctl reload apache2
```

### 10. Verifikation

- `https://wohlstandsillusion.de` und `https://www.wohlstandsillusion.de` im Browser
- HTTP-Redirect: `curl -I http://wohlstandsillusion.de/` (sollte 301 auf https liefern)
- Security-Header: `curl -I https://wohlstandsillusion.de/` (HSTS, X-Content-Type-Options etc.)
- Sitemap: `curl https://wohlstandsillusion.de/sitemap.xml`

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
