# Guide de Développement

## Workflow Quotidien

### Démarrage

```bash
# Démarrer en mode développement
make start-dev

# Vérifier le status
make status
```

### Arrêt

```bash
# Arrêter tout
make stop
```

## Frontend (SvelteKit)

### Structure

```
frontend/src/
├── src/
│   ├── lib/           # Composants et utilitaires
│   ├── routes/        # Pages et routes
│   └── app.html       # Template HTML
├── static/            # Assets statiques
├── svelte.config.js   # Configuration Svelte
└── vite.config.ts     # Configuration Vite
```

### Commandes

```bash
# Shell dans le conteneur Node
make shell-node

# Installer les dépendances
make frontend-install

# Linter
make frontend-lint

# Tests
make frontend-test

# Build production
make frontend-build
```

### Développement local (sans Docker)

```bash
make local-frontend-install
make local-frontend-dev
```

### Variables d'environnement

Les variables Vite sont injectées automatiquement:

```typescript
// Accessibles dans le code via import.meta.env
const apiUrl = import.meta.env.VITE_API_URL;      // https://api.local
const authUrl = import.meta.env.VITE_AUTH_URL;    // https://auth.local
const realm = import.meta.env.VITE_KEYCLOAK_REALM; // abs-app
```

### Hot Reload

Le hot reload est actif par défaut en mode développement. Les modifications sont visibles instantanément.

---

## Backend (PHP)

### Structure

```
backend/src/
├── public/
│   └── index.php      # Point d'entrée
├── src/               # Code source
├── tests/             # Tests
└── composer.json      # Dépendances
```

### Commandes

```bash
# Shell dans le conteneur PHP
make shell-php

# Shell en root (pour installer des paquets système)
make shell-php-root

# Installer les dépendances
make backend-composer-install

# Mettre à jour les dépendances
make backend-composer-update

# Tests
make backend-test
```

### Variables d'environnement

Accessibles dans PHP via `$_ENV` ou `getenv()`:

```php
$dbHost = getenv('DB_HOST');
$keycloakUrl = getenv('KEYCLOAK_URL');
```

### Xdebug

Pour activer Xdebug:

1. Modifier le `.env` global:
```ini
XDEBUG_MODE=debug
```

2. Redémarrer le backend:
```bash
make stop-backend
make start-backend
```

3. Configurer votre IDE pour écouter sur le port 9003.

---

## Base de Données

### Profils disponibles

Le backend supporte trois bases de données via des profils Docker:

```bash
# MySQL (défaut)
make start-backend-mysql

# PostgreSQL
make start-backend-postgres

# MongoDB
make start-backend-mongo
```

### Accès CLI

```bash
# MySQL
make db-mysql-cli

# PostgreSQL
make db-postgres-cli

# MongoDB
make db-mongo-cli

# Redis
make db-redis-cli
```

### Adminer

Interface web pour gérer les bases de données:
- **URL:** http://localhost:8081

---

## Email

### Envoyer un email de test

Depuis le backend PHP:

```php
mail(
    'user1@mail.local',
    'Test Subject',
    'Test Body',
    'From: noreply@api.local'
);
```

Depuis la ligne de commande:

```bash
make shell-php
echo "Test" | mail -s "Test" user1@mail.local
```

### Consulter les emails

1. **Roundcube:** https://mail.local
2. **API Greenmail:** http://localhost:8082/api/user/user1@mail.local/messages

### Tester l'Inbound Parse

```bash
# Envoyer un email au simulateur
swaks --to user@parse.local \
      --from test@example.com \
      --server localhost:2525 \
      --header "Subject: Test Inbound" \
      --body "Test email for inbound parse"
```

---

## Debugging

### Logs

```bash
# Frontend
make logs-node

# Backend PHP
make logs-php

# Backend Nginx
make logs-nginx-backend

# Tous les logs
make logs-all
```

### Health Check

```bash
make health
```

### Inspecter un conteneur

```bash
docker inspect abs_frontend_node
docker inspect abs_backend_php
```

### Réseau

```bash
# Tester la connectivité entre services
make shell-node
ping greenmail
curl -I https://api.local
```

---

## Tests

### Frontend

```bash
# Dans le conteneur
make shell-node
pnpm test

# Avec couverture
pnpm test:coverage
```

### Backend

```bash
# Tests unitaires
make backend-test

# Avec la base de test
make shell-php
php vendor/bin/phpunit --testsuite unit
```

---

## Production

### Build

```bash
# Build toutes les images
make build-all

# Build sans cache
make build-no-cache
```

### Déploiement local en production

```bash
# Frontend avec Nginx
make start-frontend-prod

# Vérifier les URLs
make urls
```

### Variables de production

Modifier le `.env` global:

```ini
APP_ENV=production
NODE_ENV=production
```

---

## Troubleshooting

### Le conteneur ne démarre pas

```bash
# Voir les logs
docker-compose -f frontend/docker/docker-compose.yml --env-file .env logs node

# Reconstruire l'image
make build-frontend
```

### Erreur de certificat SSL

```bash
# Régénérer les certificats
make certs-generate
```

### Port déjà utilisé

Vérifier les ports dans le `.env` global et s'assurer qu'ils ne sont pas déjà utilisés:

```bash
lsof -i :5173
lsof -i :8000
```

### Problème de réseau Docker

```bash
# Recréer les réseaux
make networks-remove
make networks-create
```

### Reset complet

```bash
# ATTENTION: Supprime toutes les données
make clean
make init
make start
```
