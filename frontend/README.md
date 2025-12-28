# Frontend - SvelteKit Application

Application frontend basée sur SvelteKit avec un environnement Docker complet pour le développement et la production.

## Sommaire

- [Prérequis](#prérequis)
- [Installation](#installation)
- [Démarrage de l'environnement](#démarrage-de-lenvironnement)
- [Commandes disponibles](#commandes-disponibles)
- [Structure Docker](#structure-docker)
- [Configuration](#configuration)

---

## Prérequis

- [Docker](https://docs.docker.com/get-docker/) (>= 20.10)
- [Docker Compose](https://docs.docker.com/compose/install/) (>= 2.0)
- [Make](https://www.gnu.org/software/make/)

```bash
docker --version
docker-compose --version
```

---

## Installation

1. **Configurer les variables d'environnement**

```bash
cp docker/.env.example docker/.env
```

Modifiez `docker/.env` selon vos besoins.

2. **Construire les images Docker**

```bash
make docker-build
```

---

## Démarrage de l'environnement

### Mode développement

```bash
make docker-start-dev
```

L'application sera accessible sur `http://localhost:5173`

### Mode production

```bash
# D'abord, construire l'application
make app-build

# Puis démarrer en mode production
make docker-start-prod
```

L'application sera accessible sur `http://localhost:3000`

### Arrêt

```bash
make docker-stop    # Arrêter les conteneurs
make docker-down    # Arrêter et supprimer les conteneurs
make docker-clean   # Reset complet (supprime aussi les volumes)
```

---

## Commandes disponibles

Exécutez `make help` pour voir toutes les commandes disponibles.

### Docker

| Commande | Description |
|----------|-------------|
| `make docker-build` | Construire les images Docker |
| `make docker-start-dev` | Démarrer en mode développement |
| `make docker-start-prod` | Démarrer en mode production |
| `make docker-stop` | Arrêter les conteneurs |
| `make docker-down` | Arrêter et supprimer les conteneurs |
| `make docker-clean` | Reset complet |
| `make docker-shell-node` | Shell dans le conteneur Node |
| `make docker-logs` | Voir les logs |

### Application (dans Docker)

| Commande | Description |
|----------|-------------|
| `make app-install` | Installer les dépendances |
| `make app-dev` | Serveur de développement |
| `make app-build` | Build de production |
| `make app-preview` | Preview du build |
| `make app-check` | Vérifier les types TypeScript |
| `make app-lint` | Linter le code |
| `make app-format` | Formater le code |
| `make app-test` | Exécuter les tests |

### Local (sans Docker)

| Commande | Description |
|----------|-------------|
| `make local-dev` | Serveur de développement local |
| `make local-build` | Build local |
| `make local-test` | Tests locaux |

---

## Structure Docker

```
frontend/
├── docker/
│   ├── docker-compose.yml    # Orchestration des services
│   ├── .env                  # Variables d'environnement
│   ├── .env.example          # Template des variables
│   ├── node/
│   │   └── Dockerfile        # Image Node.js pour SvelteKit
│   ├── nginx/
│   │   ├── Dockerfile        # Image Nginx pour production
│   │   └── conf.d/
│   │       └── default.conf  # Configuration Nginx
│   ├── redis/
│   │   ├── Dockerfile        # Image Redis pour cache
│   │   └── redis.conf        # Configuration Redis
│   └── logs/
│       └── nginx/            # Logs Nginx
├── src/                      # Code source SvelteKit
├── Makefile                  # Commandes Make
└── README.md                 # Ce fichier
```

### Services

| Service | Description | Port |
|---------|-------------|------|
| `node` | Application SvelteKit (dev) | 5173 |
| `nginx` | Serveur web (prod) | 3000 |
| `redis` | Cache | 6380 |

---

## Configuration

### Variables d'environnement (.env)

```env
# Versions
NODE_VERSION=22
REDIS_VERSION=7
NGINX_VERSION=1.27

# Ports
APP_DEV_PORT=5173
APP_PREVIEW_PORT=4173
APP_PROD_PORT=3000
REDIS_PORT=6380

# Node
NODE_ENV=development
```

### Volumes Docker

| Volume | Description |
|--------|-------------|
| `frontend_node_modules` | Dépendances Node.js |
| `frontend_pnpm_store` | Cache pnpm |
| `frontend_redis_data` | Données Redis |

---

## Astuces

### Voir toutes les commandes

```bash
make help
```

### Reconstruire une image spécifique

```bash
docker-compose -f docker/docker-compose.yml build node
```

### Accéder au shell d'un conteneur

```bash
make docker-shell-node
```

### Nettoyer les dépendances

```bash
make app-clean-deps
```
