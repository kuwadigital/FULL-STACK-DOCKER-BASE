# Documentation ABS-WEB

Bienvenue dans la documentation du projet ABS-WEB.

## Sommaire

1. **[Guide de Démarrage](00-getting-started.md)**
   - Installation
   - Configuration initiale
   - Premier démarrage

2. **[Architecture](01-architecture.md)**
   - Vue d'ensemble
   - Schéma d'architecture
   - Réseaux Docker
   - Flux de communication

3. **[Configuration](02-configuration.md)**
   - Fichier .env global
   - Variables principales
   - Surcharge locale
   - Configuration des services

4. **[Services d'Infrastructure](03-services.md)**
   - Traefik (reverse proxy)
   - Keycloak (authentification)
   - Greenmail (email server)
   - Roundcube (webmail)
   - Inbound Parse (webhook email)

5. **[Développement](04-development.md)**
   - Workflow quotidien
   - Frontend (SvelteKit)
   - Backend (PHP)
   - Tests
   - Debugging

## Liens Rapides

### URLs de l'Application

| Service | URL |
|---------|-----|
| Frontend | https://app.local |
| Backend API | https://api.local |
| Keycloak | https://auth.local |
| Webmail | https://mail.local |
| Traefik | https://traefik.local |
| Inbound Parse | https://parse.local |

### Commandes Essentielles

```bash
# Initialisation
make init

# Démarrer
make start

# Status
make status

# Arrêter
make stop

# Aide
make help
```

## Contribuer à la Documentation

La documentation est écrite en Markdown dans le dossier `docs/`.

Pour ajouter une nouvelle page:
1. Créer un fichier `XX-nom-de-la-page.md`
2. Ajouter le lien dans ce README
3. Suivre le style des autres pages
