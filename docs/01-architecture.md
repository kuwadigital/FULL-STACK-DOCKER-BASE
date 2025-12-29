# Architecture du Projet

## Vue d'Ensemble

ABS-WEB est une application full-stack composée de trois modules principaux:

```
ABS-WEB/
├── frontend/          # Application SvelteKit
├── backend/           # API PHP
├── extra-services/    # Services d'infrastructure
├── docs/              # Documentation
├── .env               # Configuration globale
└── Makefile           # Commandes globales
```

## Schéma d'Architecture

```
                                    ┌─────────────────────────────────────────┐
                                    │              INTERNET                    │
                                    └────────────────┬────────────────────────┘
                                                     │
                                    ┌────────────────▼────────────────────────┐
                                    │         TRAEFIK 3 (Reverse Proxy)       │
                                    │      Ports: 80, 443, 8080 (dashboard)   │
                                    │      SSL/TLS Termination                │
                                    └────┬─────────┬──────────┬───────────────┘
                                         │         │          │
           ┌─────────────────────────────┤         │          ├──────────────────────────────┐
           │                             │         │          │                              │
           ▼                             ▼         ▼          ▼                              ▼
┌──────────────────────┐  ┌─────────────────────┐  ┌───────────────────┐  ┌────────────────────────┐
│   app.local          │  │   api.local         │  │  auth.local       │  │  mail.local            │
│   ┌──────────────┐   │  │   ┌─────────────┐   │  │  ┌────────────┐   │  │  ┌─────────────────┐   │
│   │   FRONTEND   │   │  │   │   BACKEND   │   │  │  │  KEYCLOAK  │   │  │  │    ROUNDCUBE    │   │
│   │   SvelteKit  │   │  │   │   PHP 8.3   │   │  │  │   26.x     │   │  │  │      1.6.x      │   │
│   │   Node 22    │   │  │   │   Nginx     │   │  │  │  OpenID    │   │  │  │   Webmail UI    │   │
│   └──────────────┘   │  │   └─────────────┘   │  │  │  Connect   │   │  │  └─────────────────┘   │
│          │           │  │          │          │  │  └────────────┘   │  │           │            │
│          ▼           │  │          ▼          │  │        │          │  │           ▼            │
│   ┌──────────────┐   │  │   ┌─────────────┐   │  │        ▼          │  │  ┌─────────────────┐   │
│   │    REDIS     │   │  │   │   MySQL /   │   │  │  ┌────────────┐   │  │  │    GREENMAIL    │   │
│   │   (cache)    │   │  │   │  PostgreSQL │   │  │  │ PostgreSQL │   │  │  │   SMTP Server   │   │
│   └──────────────┘   │  │   │  MongoDB    │   │  │  │ (Keycloak) │   │  │  │   IMAP/POP3     │   │
│                      │  │   └─────────────┘   │  │  └────────────┘   │  │  └─────────────────┘   │
└──────────────────────┘  └─────────────────────┘  └───────────────────┘  └────────────────────────┘
         │                          │                                                │
         │                          │                                                │
         │                          │                       ┌────────────────────────┘
         │                          │                       │
         │                          │                       ▼
         │                          │              ┌─────────────────────┐
         │                          │              │   parse.local       │
         │                          │              │  ┌───────────────┐  │
         │                          │              │  │ INBOUND PARSE │  │
         │                          │              │  │  Simulateur   │  │
         │                          └──────────────┼─►│   SendGrid    │  │
         │                             webhooks    │  └───────────────┘  │
         │                                         └─────────────────────┘
         │
         └───────────────────────────────────────────────────────────────────────────►
                              API calls via Keycloak tokens
```

## Réseaux Docker

L'application utilise trois réseaux isolés:

### abs_frontend_network
Réseau dédié au frontend:
- Node.js (SvelteKit)
- Redis (cache sessions)
- Nginx (production)

### abs_backend_network
Réseau dédié au backend:
- PHP-FPM
- Nginx
- MySQL / PostgreSQL / MongoDB
- Redis (cache)
- RabbitMQ

### abs_services_network
Réseau partagé pour les services d'infrastructure:
- Traefik
- Keycloak + PostgreSQL
- Greenmail + Roundcube
- Inbound Parse

## Flux de Communication

### Authentification (OpenID Connect)
```
Frontend ──► Keycloak ──► Backend
   │            │            │
   │  1. Login  │            │
   │──────────►│            │
   │            │            │
   │  2. Token  │            │
   │◄──────────│            │
   │            │            │
   │  3. API call with token │
   │──────────────────────►│
   │            │            │
   │            │  4. Verify │
   │            │◄──────────│
   │            │            │
   │            │  5. Valid  │
   │            │──────────►│
   │            │            │
   │  6. Response            │
   │◄──────────────────────│
```

### Email Inbound (via Inbound Parse)
```
Email externe ──► Greenmail ──► Inbound Parse ──► Backend Webhook
                     │               │                  │
                     │  1. SMTP      │                  │
                     │◄──────────────│                  │
                     │               │                  │
                     │  2. Forward   │                  │
                     │──────────────►│                  │
                     │               │                  │
                     │               │  3. Parse email  │
                     │               │  4. POST webhook │
                     │               │─────────────────►│
                     │               │                  │
                     │               │  5. Process      │
                     │               │                  │
```

## Modules

### Frontend (`frontend/`)

```
frontend/
├── docker/
│   ├── docker-compose.yml
│   ├── node/Dockerfile
│   ├── nginx/Dockerfile
│   └── redis/Dockerfile
└── src/
    ├── src/
    │   ├── lib/
    │   └── routes/
    ├── static/
    └── package.json
```

**Technologies:**
- SvelteKit 2.x avec Svelte 5
- TypeScript
- Tailwind CSS 4
- Flowbite (composants UI)
- pnpm (gestionnaire de paquets)

### Backend (`backend/`)

```
backend/
├── docker/
│   ├── docker-compose.yml
│   ├── php/Dockerfile
│   ├── nginx/Dockerfile
│   ├── mysql/Dockerfile
│   ├── postgres/Dockerfile
│   ├── mongo/Dockerfile
│   └── redis/Dockerfile
└── src/
    └── public/
```

**Technologies:**
- PHP 8.3
- Nginx
- MySQL 8.0 / PostgreSQL 16 / MongoDB 7
- Redis 7
- RabbitMQ 4.0

### Extra Services (`extra-services/`)

```
extra-services/
└── docker/
    ├── docker-compose.yml
    ├── traefik/
    │   ├── config/
    │   └── certs/
    ├── keycloak/
    │   └── import/
    └── inbound-parse/
        ├── app/
        └── config/
```

**Services:**
- Traefik 3.2 (reverse proxy)
- Keycloak 26.0 (identity)
- PostgreSQL 16 (pour Keycloak)
- Greenmail 2.0.1 (email server)
- Roundcube 1.6 (webmail)
- Inbound Parse Simulator (SendGrid)
