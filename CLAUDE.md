# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ABS-WEB is a full-stack web application template with a complete development infrastructure:
- **Frontend**: SvelteKit application (Svelte 5, TypeScript, Tailwind CSS 4)
- **Backend**: PHP application (PHP 8.3, Nginx, MySQL/PostgreSQL/MongoDB)
- **Extra Services**: Development infrastructure (Traefik, Keycloak, Greenmail, Inbound Parse)

All three modules are designed as **independent applications** that work together via a **global configuration** (.env at root).

## Repository Structure

```
ABS-WEB/
├── .env                         # GLOBAL CONFIG - Central control for everything
├── Makefile                     # Global commands for all modules
├── CLAUDE.md                    # This file
│
├── frontend/                    # Frontend application
│   ├── docker/
│   │   ├── docker-compose.yml   # Uses global .env via --env-file
│   │   ├── node/Dockerfile
│   │   ├── nginx/Dockerfile
│   │   └── redis/Dockerfile
│   └── src/                     # SvelteKit application
│       ├── src/lib/             # Components
│       └── src/routes/          # Pages
│
├── backend/                     # Backend application
│   ├── docker/
│   │   ├── docker-compose.yml   # Uses global .env via --env-file
│   │   ├── php/Dockerfile
│   │   ├── nginx/Dockerfile
│   │   └── mysql/postgres/mongo/redis/
│   └── src/                     # PHP application
│
├── extra-services/              # Infrastructure services
│   └── docker/
│       ├── docker-compose.yml
│       ├── traefik/             # Reverse proxy + SSL
│       │   ├── config/
│       │   └── certs/
│       ├── keycloak/            # Identity & Access Management
│       │   └── import/          # Pre-configured realm
│       └── inbound-parse/       # SendGrid Inbound Parse simulator
│           ├── app/             # Node.js SMTP + HTTP server
│           └── config/
│
└── docs/                        # Documentation
    ├── 00-getting-started.md
    ├── 01-architecture.md
    ├── 02-configuration.md
    ├── 03-services.md
    └── 04-development.md
```

## Requirements

- **Docker Engine 24+** with Docker Compose v2 (`docker compose`, not `docker-compose`)
- Add entries to `/etc/hosts` (see Quick Start)
- Ports 80, 443, 5173, 8000, 8080 available

## Quick Start

```bash
# 1. Initialize (creates networks, certs, builds images)
make init

# 2. Add to /etc/hosts
127.0.0.1   app.local api.local auth.local mail.local traefik.local parse.local

# 3. Start everything
make start

# 4. View URLs
make urls
```

## Global Commands (from root directory)

### Essential Commands

```bash
make help                  # Show all available commands
make init                  # Full initialization (networks, certs, build)
make start                 # Start everything (services, backend, frontend)
make start-dev             # Start in development mode
make stop                  # Stop everything
make restart               # Restart everything
make status                # Show status of all containers
make urls                  # Show all application URLs
make clean                 # Full reset (WARNING: deletes all data)
```

### Individual Module Control

```bash
# Extra Services (Traefik, Keycloak, Greenmail, etc.)
make start-services
make stop-services
make logs-services

# Frontend
make start-frontend        # Development mode
make start-frontend-prod   # Production mode (Nginx)
make stop-frontend
make logs-frontend
make shell-node

# Backend
make start-backend         # MySQL (default)
make start-backend-mysql
make start-backend-postgres
make start-backend-mongo
make stop-backend
make logs-backend
make shell-php
```

### Database CLI

```bash
make db-mysql-cli
make db-postgres-cli
make db-mongo-cli
make db-redis-cli
make db-keycloak-cli       # Keycloak's PostgreSQL
```

## Application URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | https://app.local | - |
| Backend API | https://api.local | - |
| Traefik Dashboard | https://traefik.local | - |
| Keycloak | https://auth.local | admin / admin |
| Roundcube | https://mail.local | user1 / password1 |
| Inbound Parse | https://parse.local | - |

### Direct Access (Development)

| Service | URL |
|---------|-----|
| Frontend Dev | http://localhost:5173 |
| Adminer | http://localhost:8081 |
| Greenmail API | http://localhost:8082 |
| RabbitMQ | http://localhost:15672 |

## Architecture

### Technology Stack

**Frontend:**
- SvelteKit 2.x with Svelte 5 (runes syntax: `$state`, `$derived`, `$effect`)
- TypeScript
- Tailwind CSS 4.x
- Flowbite Svelte (UI components)
- Vitest + Playwright (testing)
- Node.js 22 (Docker)
- Redis 7 (cache)

**Backend:**
- PHP 8.3 with PHP-FPM
- Nginx 1.27
- MySQL 8.0 / PostgreSQL 16 / MongoDB 7 (selectable via profiles)
- Redis 7 (cache)
- RabbitMQ 4.0 (queues)

**Extra Services:**
- Traefik latest (reverse proxy, SSL termination)
- Keycloak 26.0 (OpenID Connect, authentication)
- Greenmail 2.0.1 (email server for development)
- Roundcube 1.6.x (webmail interface)
- Inbound Parse Simulator (SendGrid webhook simulation)

### Docker Networks

| Network | Purpose |
|---------|---------|
| `abs_frontend_network` | Frontend services |
| `abs_backend_network` | Backend services |
| `abs_services_network` | Shared infrastructure (Traefik, Keycloak, etc.) |

All modules connect to `abs_services_network` to access shared infrastructure.

## Configuration

### Global .env (Root)

The `.env` file at root is the **central control** for all configuration:

```ini
# Domains
FRONTEND_HOST=app.local
BACKEND_HOST=api.local
AUTH_HOST=auth.local

# Versions
TRAEFIK_VERSION=latest
NODE_VERSION=22
PHP_VERSION=8.3

# Ports
FRONTEND_DEV_PORT=5173
BACKEND_PORT=8000

# Keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
KEYCLOAK_REALM=abs-app

# Database
MYSQL_DATABASE=abs_db
MYSQL_USER=abs_user
MYSQL_PASSWORD=abs_secret
```

### Local Overrides

Local `.env` files in `frontend/docker/` and `backend/docker/` can override global values for specific use cases.

## Frontend Development

### Key Patterns

**Svelte 5 Runes:**
```svelte
<script lang="ts">
  let count = $state(0);
  let doubled = $derived(count * 2);

  $effect(() => {
    console.log('Count changed:', count);
  });
</script>
```

**Route Groups:**
- `(sidebar)` - Pages with sidebar navigation
- `(no-sidebar)` - Pages without sidebar
- `(no-layout)` - Pages with no shared layout

**API Integration:**
```typescript
// Environment variables for API URLs
const apiUrl = import.meta.env.VITE_API_URL;      // https://api.local
const authUrl = import.meta.env.VITE_AUTH_URL;    // https://auth.local
```

### Testing

```bash
make shell-node
pnpm test              # All tests
pnpm test:unit         # Vitest
pnpm test:e2e          # Playwright
```

## Backend Development

### Database Profiles

```bash
make start-backend-mysql     # MySQL (default)
make start-backend-postgres  # PostgreSQL
make start-backend-mongo     # MongoDB
```

### Xdebug

Enable in `.env`:
```ini
XDEBUG_MODE=debug
```

Then restart: `make restart`

## Extra Services

### Keycloak

Pre-configured realm `abs-app` with:
- Clients: `abs-frontend` (public), `abs-backend` (confidential)
- Roles: admin, user, moderator
- Users:
  - admin@abs.local / admin12345
  - user@abs.local / user12345
  - moderator@abs.local / moderator12345

### Inbound Parse

SendGrid Inbound Parse simulator:
- SMTP: port 2525
- HTTP API: port 8084
- Routes emails to webhooks based on recipient domain

Configuration: `extra-services/docker/inbound-parse/config/config.json`

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

### Greenmail

Email server with 5 pre-configured users:
- user1 / password1 (email: user1@mail.local)
- user2 / password2 (email: user2@mail.local)
- user3 / password3 (email: user3@mail.local)
- user4 / password4 (email: user4@mail.local)
- user5 / password5 (email: user5@mail.local)

## File Reference

### Important Files

| File | Purpose |
|------|---------|
| `.env` | Global configuration (central control) |
| `Makefile` | Global commands |
| `extra-services/docker/docker-compose.yml` | Infrastructure services |
| `frontend/docker/docker-compose.yml` | Frontend services |
| `backend/docker/docker-compose.yml` | Backend services |
| `extra-services/docker/traefik/certs/generate-certs.sh` | SSL certificate generation |
| `extra-services/docker/keycloak/import/realm-abs-app.json` | Keycloak realm configuration |
| `extra-services/docker/inbound-parse/config/config.json` | Email routing configuration |

### Documentation

See `docs/` folder for detailed documentation:
- `00-getting-started.md` - Quick start guide
- `01-architecture.md` - Architecture overview
- `02-configuration.md` - Configuration details
- `03-services.md` - Extra services documentation
- `04-development.md` - Development guide
