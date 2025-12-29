# Services d'Infrastructure

## Traefik 3

### Description
Traefik est le reverse proxy central qui gère tout le trafic HTTP/HTTPS entrant.

### Configuration

**Fichiers:**
- `extra-services/docker/traefik/config/tls.yml` - Configuration SSL
- `extra-services/docker/traefik/config/middlewares.yml` - Middlewares (CORS, headers)
- `extra-services/docker/traefik/certs/` - Certificats SSL

### Labels Docker

Chaque service définit son routage via des labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.frontend.rule=Host(`app.local`)"
  - "traefik.http.routers.frontend.entrypoints=websecure"
  - "traefik.http.routers.frontend.tls=true"
  - "traefik.http.services.frontend.loadbalancer.server.port=5173"
```

### Dashboard

- **URL:** https://traefik.local
- **Port direct:** http://localhost:8080

### Entrypoints

| Entrypoint | Port | Usage |
|------------|------|-------|
| `web` | 80 | HTTP (redirige vers HTTPS) |
| `websecure` | 443 | HTTPS |

---

## Keycloak

### Description
Keycloak gère l'authentification et l'autorisation via OpenID Connect.

### Accès

- **URL:** https://auth.local
- **Admin:** admin / admin

### Realm pré-configuré

Le realm `abs-app` est automatiquement importé au démarrage avec:

**Clients:**
- `abs-frontend` (public) - Pour l'app SvelteKit
- `abs-backend` (confidential) - Pour l'API PHP

**Rôles:**
- `admin` - Administrateur
- `user` - Utilisateur standard
- `moderator` - Modérateur

**Utilisateurs:**
- admin@abs.local / admin12345
- user@abs.local / user12345
- moderator@abs.local / moderator12345

### Configuration SMTP

Keycloak est configuré pour envoyer les emails via Greenmail:
- Host: `greenmail`
- Port: `25`
- From: `keycloak@auth.local`

### Intégration Frontend (SvelteKit)

```typescript
// Exemple d'intégration avec keycloak-js
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: 'https://auth.local',
  realm: 'abs-app',
  clientId: 'abs-frontend'
});
```

### Intégration Backend (PHP)

```php
// Vérification du token JWT
$token = $_SERVER['HTTP_AUTHORIZATION'];
$keycloakUrl = 'https://auth.local/realms/abs-app/protocol/openid-connect/certs';
// Valider le token avec les clés publiques
```

---

## Greenmail

### Description
Greenmail est un serveur email de développement qui capture tous les emails sortants.

### Ports

| Protocole | Port | Usage |
|-----------|------|-------|
| SMTP | 25 | Envoi d'emails |
| SMTPS | 465 | Envoi sécurisé |
| IMAP | 143 | Réception |
| IMAPS | 993 | Réception sécurisée |
| POP3 | 110 | Réception |
| POP3S | 995 | Réception sécurisée |
| API | 8082 | API REST |

### Utilisateurs par défaut

| Email | Mot de passe |
|-------|--------------|
| user1@mail.local | password1 |
| user2@mail.local | password2 |
| user3@mail.local | password3 |
| user4@mail.local | password4 |
| user5@mail.local | password5 |

### API REST

```bash
# Lister les emails
curl http://localhost:8082/api/user/user1@mail.local/messages

# Supprimer tous les emails
curl -X DELETE http://localhost:8082/api/user/user1@mail.local/messages
```

---

## Roundcube

### Description
Interface webmail pour consulter les emails capturés par Greenmail.

### Accès

- **URL:** https://mail.local
- **Connexion:** user1@mail.local / password1

### Configuration

Roundcube est pré-configuré pour se connecter à Greenmail:
- IMAP: greenmail:143
- SMTP: greenmail:25

---

## Inbound Parse Simulator

### Description
Simulateur local du SendGrid Inbound Parse Webhook. Reçoit les emails via SMTP et les transmet aux webhooks configurés.

### Fonctionnement

```
Email ──► SMTP (port 2525) ──► Parse ──► Webhook HTTP
```

### Ports

| Port | Usage |
|------|-------|
| 2525 | SMTP (réception emails) |
| 8084 | HTTP (API + Dashboard) |

### Dashboard

- **URL:** https://parse.local
- **Port direct:** http://localhost:8084

### Configuration des Routes

Fichier: `extra-services/docker/inbound-parse/config/config.json`

```json
{
  "routes": {
    "parse.local": {
      "url": "https://api.local/webhooks/inbound-email",
      "raw": false,
      "spam_check": true
    }
  }
}
```

### Format SendGrid

L'email est converti au format SendGrid Inbound Parse:

```json
{
  "headers": "{...}",
  "to": "recipient@parse.local",
  "from": "sender@example.com",
  "subject": "Test Email",
  "text": "Plain text content",
  "html": "<p>HTML content</p>",
  "envelope": "{\"to\":[...],\"from\":\"...\"}",
  "attachments": "1",
  "attachment-info": "{...}",
  "charsets": "{...}",
  "SPF": "pass",
  "spam_score": "0.5"
}
```

### API

```bash
# Health check
curl http://localhost:8084/health

# Voir la configuration
curl http://localhost:8084/api/config

# Ajouter une route
curl -X POST http://localhost:8084/api/config/routes \
  -H "Content-Type: application/json" \
  -d '{"domain": "test.local", "url": "https://api.local/webhooks/test"}'

# Supprimer une route
curl -X DELETE http://localhost:8084/api/config/routes/test.local
```

### Tester l'envoi d'email

```bash
# Via telnet
telnet localhost 2525
HELO test
MAIL FROM:<sender@example.com>
RCPT TO:<user@parse.local>
DATA
Subject: Test Email
From: sender@example.com
To: user@parse.local

This is a test email.
.
QUIT

# Via swaks
swaks --to user@parse.local \
      --from sender@example.com \
      --server localhost:2525 \
      --body "Test email content"
```

---

## Logs

### Commandes de logs

```bash
# Tous les extra-services
make logs-services

# Par service
make logs-traefik
make logs-keycloak
make logs-greenmail
```

### Emplacement des logs

- Traefik: Stdout (visible via docker-compose logs)
- Keycloak: `/opt/keycloak/data/log/`
- Greenmail: Stdout
- Inbound Parse: Stdout (format pino)
