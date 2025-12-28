# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ABS-WEB is a full-stack web application template with:
- **Frontend**: SvelteKit application with Docker environment
- **Backend**: PHP application with Docker environment

Both frontend and backend are designed as **independent applications** with their own Docker configurations, Makefiles, and environment variables.

## Repository Structure

```
ABS-WEB/
├── frontend/                    # Frontend application (independent)
│   ├── docker/                  # Docker configuration
│   │   ├── docker-compose.yml
│   │   ├── .env
│   │   ├── node/               # Node.js container
│   │   ├── nginx/              # Nginx container (production)
│   │   ├── redis/              # Redis container (cache)
│   │   └── logs/
│   ├── src/                    # SvelteKit application
│   │   ├── src/
│   │   │   ├── lib/           # Reusable Svelte components
│   │   │   └── routes/        # SvelteKit file-based routing
│   │   └── static/
│   ├── Makefile
│   └── README.md
│
└── backend/                    # Backend application (independent)
    ├── docker/                 # Docker configuration
    │   ├── docker-compose.yml
    │   ├── .env
    │   ├── php/               # PHP-FPM container
    │   ├── nginx/             # Nginx container
    │   ├── mysql/             # MySQL container
    │   ├── postgres/          # PostgreSQL container
    │   ├── mongo/             # MongoDB container
    │   ├── redis/             # Redis container
    │   └── logs/
    ├── src/                   # PHP application code
    ├── db/                    # SQL dump files
    ├── Makefile
    └── README.md
```

## Frontend Commands

Run from `frontend/` directory.

### Docker Commands (Recommended)

```bash
cd frontend

# Build
make docker-build              # Build Docker images

# Development
make docker-start-dev          # Start dev environment (Node + Redis)
make docker-start-dev-attached # Start with logs in terminal

# Production
make app-build                 # Build the app first
make docker-start-prod         # Start prod environment (Nginx + Redis)

# Stop/Clean
make docker-stop               # Stop containers
make docker-down               # Stop and remove containers
make docker-clean              # Reset (remove volumes too)

# Container Access
make docker-shell-node         # Shell into Node container
make docker-shell-redis        # Redis CLI
make docker-logs               # View all logs
make docker-logs-node          # Node logs only

# Application (in container)
make app-install               # pnpm install
make app-dev                   # pnpm dev
make app-build                 # pnpm build
make app-check                 # TypeScript check
make app-lint                  # Lint code
make app-format                # Format code
make app-test                  # Run all tests
make app-test-unit             # Unit tests (Vitest)
make app-test-e2e              # E2E tests (Playwright)
```

### Local Commands (without Docker)

```bash
cd frontend
make local-dev                 # pnpm dev locally
make local-build               # pnpm build locally
make local-test                # pnpm test locally
```

### Direct pnpm Commands

```bash
cd frontend/src
pnpm dev                       # Development server
pnpm build                     # Production build
pnpm preview                   # Preview build
pnpm check                     # TypeScript check
pnpm lint                      # Lint
pnpm format                    # Format
pnpm test                      # All tests
pnpm test:unit                 # Unit tests
pnpm test:e2e                  # E2E tests
```

## Backend Commands

Run from `backend/` directory.

```bash
cd backend

# Docker Environment
make docker-build              # Build Docker images
make docker-start              # Start with MySQL (default)
make docker-start-postgres     # Start with PostgreSQL
make docker-start-mongo        # Start with MongoDB
make docker-stop               # Stop containers
make docker-down               # Stop and remove containers
make docker-clean              # Reset (remove volumes too)

# Container Access
make docker-shell-php          # Shell into PHP container
make docker-logs               # View logs

# PHP Dependencies
make app-composer-install      # Install Composer dependencies
make app-composer-update       # Update Composer dependencies

# Testing
make app-test                  # Run PHPUnit tests

# Database CLI
make docker-mysql-cli          # MySQL shell
make docker-psql-cli           # PostgreSQL shell
make docker-mongo-cli          # MongoDB shell
make docker-redis-cli          # Redis shell

# Database Import/Export
make app-db-mysql-import       # Import db/db.sql to MySQL
make app-db-mysql-export       # Export MySQL to db/db.sql
make app-db-psql-import        # Import to PostgreSQL
make app-db-psql-export        # Export from PostgreSQL
```

## Architecture

### Frontend (SvelteKit with Docker)

**Stack:**
- SvelteKit 2.x with Svelte 5 (runes syntax)
- Tailwind CSS 4.x + Flowbite Svelte
- Vitest + Playwright
- Node.js 22 (Docker)
- Redis 7 (cache)
- Nginx 1.27 (production)

**Docker Services:**
| Service | Purpose | Port |
|---------|---------|------|
| `node` | Development server | 5173 |
| `nginx` | Production server | 3000 |
| `redis` | Cache | 6380 |

**Route Groups:**
- `(sidebar)` - Pages with sidebar navigation
- `(no-sidebar)` - Pages without sidebar
- `(no-layout)` - Pages with no shared layout

**Key Files:**
- `frontend/docker/docker-compose.yml` - Docker orchestration
- `frontend/docker/.env` - Docker environment variables
- `frontend/src/svelte.config.js` - SvelteKit configuration
- `frontend/src/vite.config.ts` - Vite + test configuration
- `frontend/src/eslint.config.js` - ESLint flat config

### Backend (PHP with Docker)

**Stack:**
- PHP 8.1 with FPM
- Nginx web server
- MySQL 8.0 / PostgreSQL 14 / MongoDB 5 (profiles)
- Redis 7
- Adminer, MailHog, RabbitMQ

**Docker Services:**
| Service | Purpose | Port |
|---------|---------|------|
| `php` | PHP-FPM | - |
| `nginx` | Web server | 80 |
| `mysql` | Database | 3306 |
| `postgres` | Database | 5432 |
| `mongo` | Database | 27017 |
| `redis` | Cache | 6379 |
| `adminer` | DB admin | 8081 |
| `mailhog` | Mail | 8025 |
| `rabbitmq` | Queue | 15672 |

**Database Profiles:**
- Use `make docker-start` for MySQL
- Use `make docker-start-postgres` for PostgreSQL
- Use `make docker-start-mongo` for MongoDB

**Key Files:**
- `backend/docker/docker-compose.yml` - Docker orchestration
- `backend/docker/.env` - Docker environment variables
- `backend/docker/nginx/conf.d/` - Nginx configurations

## Testing Patterns

### Frontend
- **Unit Tests**: `*.svelte.{test,spec}.{js,ts}` (jsdom environment)
- **Server Tests**: `*.{test,spec}.{js,ts}` (node environment)
- **E2E Tests**: `frontend/src/e2e/` (Playwright)
- **Setup**: `frontend/src/vitest-setup-client.ts`

### Backend
- PHPUnit tests in PHP container

## Environment Setup

### Frontend
```bash
cp frontend/docker/.env.example frontend/docker/.env
```

### Backend
```bash
cp backend/docker/.env.example backend/docker/.env
```

Add to `/etc/hosts` for backend access:
```
127.0.0.1   public.local
```

## Docker Volumes

### Frontend
- `frontend_node_modules` - Node.js dependencies
- `frontend_pnpm_store` - pnpm cache
- `frontend_redis_data` - Redis data

### Backend
- `mysql_data`, `postgres_data`, `mongo_data`, `redis_data`
- `mysql_test_data`, `postgres_test_data`, `mongo_test_data` (test DBs)
