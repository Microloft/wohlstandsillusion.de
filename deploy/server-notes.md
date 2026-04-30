# Server-Konventionen (w1tt3.de, microloft)

Dieses Dokument hält fest, welche Server-Konfigurationen Aussagen auf der Webseite stützen — damit die Aussagen überprüfbar bleiben.

## Apache-Logs: 14-Tage-Retention

**Aussage in `content/datenschutz.md`:** „Die Server-Logs werden nach 14 Tagen automatisch gelöscht."

**Quelle:** `/etc/logrotate.d/apache2`

Relevante Direktiven:
- `daily` — rotiert täglich
- `rotate 14` — behält 14 Rotationen
- `compress` + `delaycompress` — komprimiert nach einer Karenzzeit

Damit liegen Apache-Access- und Error-Logs maximal 14 Tage in `/var/log/apache2/` vor und werden anschließend automatisch gelöscht. Die Regel ist Distributions-Default (Ubuntu Server) und gilt server-weit für alle Vhosts inklusive wohlstandsillusion.de.

**Falls geändert:** Datenschutzerklärung anpassen.

## Apache-Vhost-Konventionen

- HTTP-Vhost: `/etc/apache2/sites-available/wohlstandsillusion.de.conf`
- HTTPS-Vhost (von certbot erzeugt): `/etc/apache2/sites-available/wohlstandsillusion.de-le-ssl.conf`
- Security-Headers (eingebunden via `Include`): `/etc/apache2/conf-available/wohlstandsillusion-headers.conf`
- DocumentRoot: `/var/www/wohlstandsillusion.de/` (flach, ohne Symlink-Schema, konsistent mit anderen Domains)
- Owner: `www-data:www-data`

## TLS

- Zertifikat: Let's Encrypt via `certbot --apache`
- Renewal: `systemd certbot.timer` (täglich)
- Pfade: `/etc/letsencrypt/live/wohlstandsillusion.de/fullchain.pem` / `privkey.pem`
