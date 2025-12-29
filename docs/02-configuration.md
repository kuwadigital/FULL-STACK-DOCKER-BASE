# Configuration

## Fichier .env Global

Le fichier `.env` à la racine du projet est le **centre de contrôle** de toute l'application. Toutes les variables définies ici sont automatiquement injectées dans les trois modules (frontend, backend, extra-services).

### Structure

```ini
# =============================================================================
# DOMAINES ET HOSTS
# =============================================================================
APP_DOMAIN=local
FRONTEND_HOST=app.local
BACKEND_HOST=api.local
AUTH_HOST=auth.local
MAIL_HOST=mail.local
TRAEFIK_HOST=traefik.local

# =============================================================================
# ENVIRONNEMENT
# =============================================================================
APP_ENV=development
NODE_ENV=development

# =============================================================================
# VERSIONS DES SERVICES
# =============================================================================
TRAEFIK_VERSION=latest
KEYCLOAK_VERSION=26.0
NODE_VERSION=22
PHP_VERSION=8.3
# ... etc
```

### Variables Principales

#### Domaines

| Variable | Description | Défaut |
|----------|-------------|--------|
| `APP_DOMAIN` | Domaine principal | `local` |
| `FRONTEND_HOST` | Hostname frontend | `app.local` |
| `BACKEND_HOST` | Hostname API | `api.local` |
| `AUTH_HOST` | Hostname Keycloak | `auth.local` |
| `MAIL_HOST` | Hostname webmail | `mail.local` |
| `TRAEFIK_HOST` | Hostname dashboard Traefik | `traefik.local` |

#### Ports Frontend

| Variable | Description | Défaut |
|----------|-------------|--------|
| `FRONTEND_DEV_PORT` | Port Vite dev server | `5173` |
| `FRONTEND_PREVIEW_PORT` | Port preview | `4173` |
| `FRONTEND_PROD_PORT` | Port production | `3000` |
| `REDIS_FRONTEND_PORT` | Port Redis frontend | `6380` |

#### Ports Backend

| Variable | Description | Défaut |
|----------|-------------|--------|
| `BACKEND_PORT` | Port API | `8000` |
| `MYSQL_PORT` | Port MySQL | `3306` |
| `POSTGRES_PORT` | Port PostgreSQL | `5432` |
| `MONGO_PORT` | Port MongoDB | `27017` |
| `REDIS_BACKEND_PORT` | Port Redis backend | `6379` |
| `ADMINER_PORT` | Port Adminer | `8081` |

#### Ports Extra Services

| Variable | Description | Défaut |
|----------|-------------|--------|
| `TRAEFIK_HTTP_PORT` | Port HTTP | `80` |
| `TRAEFIK_HTTPS_PORT` | Port HTTPS | `443` |
| `TRAEFIK_DASHBOARD_PORT` | Port dashboard | `8080` |
| `KEYCLOAK_PORT` | Port Keycloak | `8180` |
| `GREENMAIL_SMTP_PORT` | Port SMTP | `25` |
| `ROUNDCUBE_PORT` | Port Roundcube | `8083` |
| `INBOUND_PARSE_PORT` | Port Inbound Parse | `8084` |

#### Keycloak

| Variable | Description | Défaut |
|----------|-------------|--------|
| `KEYCLOAK_ADMIN` | Admin username | `admin` |
| `KEYCLOAK_ADMIN_PASSWORD` | Admin password | `admin` |
| `KEYCLOAK_REALM` | Nom du realm | `abs-app` |
| `KEYCLOAK_FRONTEND_CLIENT` | Client ID frontend | `abs-frontend` |
| `KEYCLOAK_BACKEND_CLIENT` | Client ID backend | `abs-backend` |

#### Base de données

| Variable | Description | Défaut |
|----------|-------------|--------|
| `MYSQL_ROOT_PASSWORD` | MySQL root password | `root_secret` |
| `MYSQL_DATABASE` | Nom de la BDD | `abs_db` |
| `MYSQL_USER` | Utilisateur MySQL | `abs_user` |
| `MYSQL_PASSWORD` | Password MySQL | `abs_secret` |

## Surcharge Locale

Les fichiers `.env` dans `frontend/docker/` et `backend/docker/` permettent de surcharger les variables globales pour des cas spécifiques.

### Exemple de surcharge

Pour activer Xdebug uniquement sur le backend:

```ini
# backend/docker/.env
XDEBUG_MODE=debug
```

## Configuration Traefik

### Fichier TLS (`extra-services/docker/traefik/config/tls.yml`)

```yaml
tls:
  stores:
    default:
      defaultCertificate:
        certFile: /certs/local.crt
        keyFile: /certs/local.key
```

### Middlewares (`extra-services/docker/traefik/config/middlewares.yml`)

```yaml
http:
  middlewares:
    cors-headers:
      headers:
        accessControlAllowMethods:
          - GET
          - POST
          - PUT
          - DELETE
          - OPTIONS
        accessControlAllowHeaders:
          - "*"
        accessControlAllowOriginList:
          - "https://app.local"
        accessControlAllowCredentials: true
```

## Configuration Inbound Parse

### Routes (`extra-services/docker/inbound-parse/config/config.json`)

```json
{
  "routes": {
    "parse.local": {
      "url": "https://api.local/webhooks/inbound-email",
      "raw": false,
      "spam_check": true
    },
    "notifications.local": {
      "url": "https://api.local/webhooks/notifications",
      "raw": false,
      "spam_check": false
    }
  },
  "defaultRoute": {
    "url": "https://api.local/webhooks/default",
    "raw": false,
    "spam_check": false
  }
}
```

### Options de Route

| Option | Description |
|--------|-------------|
| `url` | URL du webhook à appeler |
| `raw` | Inclure l'email MIME complet |
| `spam_check` | Activer la vérification spam |

## Configuration Keycloak

Le realm est pré-configuré via le fichier d'import:
`extra-services/docker/keycloak/import/realm-abs-app.json`

### Clients pré-configurés

| Client | Type | Usage |
|--------|------|-------|
| `abs-frontend` | Public | Application SvelteKit |
| `abs-backend` | Confidential | API PHP |

### Utilisateurs par défaut

| Email | Mot de passe | Rôles |
|-------|--------------|-------|
| admin@abs.local | admin12345 | admin |
| user@abs.local | user12345 | user |
| moderator@abs.local | moderator12345 | moderator |

## Réseaux

Les réseaux sont configurés dans le `.env` global:

```ini
NETWORK_FRONTEND=abs_frontend_network
NETWORK_BACKEND=abs_backend_network
NETWORK_SERVICES=abs_services_network
```

Ces réseaux sont créés automatiquement par `make init` ou `make networks-create`.
