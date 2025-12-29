# Guide de Démarrage Rapide

Ce guide vous permet de démarrer l'application ABS-WEB complète en quelques minutes.

## Prérequis

- Docker 24.0+
- Docker Compose v2+
- Make
- Git
- OpenSSL (pour la génération des certificats SSL)

## Installation

### 1. Cloner le repository

```bash
git clone <repository-url>
cd ABS-WEB
```

### 2. Initialisation complète

```bash
make init
```

Cette commande va:
- Créer les réseaux Docker
- Générer les certificats SSL auto-signés
- Afficher les entrées à ajouter dans `/etc/hosts`
- Construire toutes les images Docker

### 3. Configurer /etc/hosts

Ajoutez ces entrées à votre fichier `/etc/hosts`:

```
127.0.0.1   app.local
127.0.0.1   api.local
127.0.0.1   auth.local
127.0.0.1   mail.local
127.0.0.1   traefik.local
127.0.0.1   parse.local
```

**Linux/macOS:**
```bash
sudo nano /etc/hosts
```

**Windows:**
Éditer `C:\Windows\System32\drivers\etc\hosts`

### 4. Faire confiance au certificat SSL

**Linux:**
```bash
sudo cp extra-services/docker/traefik/certs/local.crt /usr/local/share/ca-certificates/local.crt
sudo update-ca-certificates
```

**macOS:**
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain extra-services/docker/traefik/certs/local.crt
```

**Windows:**
Double-cliquez sur `local.crt` et importez-le dans "Autorités de certification racines de confiance"

### 5. Démarrer l'application

```bash
make start
```

## URLs de l'Application

| Service | URL | Identifiants |
|---------|-----|--------------|
| Frontend | https://app.local | - |
| Backend API | https://api.local | - |
| Traefik Dashboard | https://traefik.local | - |
| Keycloak | https://auth.local | admin / admin |
| Roundcube | https://mail.local | user1 / password1 |
| Inbound Parse | https://parse.local | - |

## Accès Direct (Développement)

| Service | URL |
|---------|-----|
| Frontend Dev | http://localhost:5173 |
| Adminer | http://localhost:8081 |
| Greenmail API | http://localhost:8082 |

## Commandes Utiles

```bash
# Voir le status de tous les conteneurs
make status

# Voir toutes les URLs
make urls

# Arrêter l'application
make stop

# Redémarrer
make restart

# Logs du frontend
make logs-frontend

# Logs du backend
make logs-backend

# Shell dans le conteneur Node
make shell-node

# Shell dans le conteneur PHP
make shell-php
```

## Mode Développement

Pour un démarrage optimisé pour le développement:

```bash
make start-dev
```

Cette commande démarre:
- Les extra-services (Traefik, Keycloak, etc.)
- Le backend avec MySQL
- Le frontend en mode développement (hot reload)

## Arrêt et Nettoyage

```bash
# Arrêter tous les conteneurs
make stop

# Arrêter et supprimer les conteneurs (garde les volumes)
make down

# Nettoyage complet (ATTENTION: supprime les données)
make clean
```

## Prochaines Étapes

- [Architecture du Projet](01-architecture.md)
- [Configuration](02-configuration.md)
- [Services Extra](03-services.md)
- [Développement](04-development.md)
