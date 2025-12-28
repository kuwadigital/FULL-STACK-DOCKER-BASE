# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ABS-WEB is a full-stack web application with a Svelte/SvelteKit frontend and a PHP backend. The project uses Docker for backend services.

## Repository Structure

```
ABS-WEB/
├── frontend/
│   └── src/           # SvelteKit application (pnpm workspace)
│       ├── src/
│       │   ├── lib/   # Reusable Svelte components (admin dashboard components)
│       │   └── routes/  # SvelteKit file-based routing
│       └── static/    # Static assets
└── backend/
    ├── src/           # PHP application code
    ├── docker/        # Docker configurations (PHP, Nginx, MySQL, PostgreSQL, MongoDB, Redis)
    └── db/            # SQL dump files for import/export
```

## Frontend Commands

The frontend is located in `frontend/src/` and uses pnpm.

```bash
cd frontend/src

# Development
pnpm dev              # Start development server

# Build & Preview
pnpm build            # Build for production
pnpm preview          # Preview production build

# Type Checking
pnpm check            # Run svelte-check with TypeScript
pnpm check:watch      # Run svelte-check in watch mode

# Linting & Formatting
pnpm lint             # Check formatting (Prettier) and lint (ESLint)
pnpm format           # Format code with Prettier

# Testing
pnpm test:unit        # Run Vitest unit tests
pnpm test:e2e         # Run Playwright end-to-end tests
pnpm test             # Run all tests
```

## Backend Commands

The backend uses Docker and Make. Run from `backend/` directory.

```bash
cd backend

# Docker Environment
make docker-build           # Build Docker images
make docker-start           # Start with MySQL (default)
make docker-start-postgres  # Start with PostgreSQL
make docker-start-mongo     # Start with MongoDB
make docker-stop            # Stop containers
make docker-down            # Stop and remove containers
make docker-clean           # Reset - remove containers and volumes

# Container Access
make docker-shell-php       # Shell into PHP container
make docker-logs            # View logs

# PHP Dependencies
make app-composer-install   # Install Composer dependencies
make app-composer-update    # Update Composer dependencies

# Testing
make app-test               # Run PHPUnit tests

# Database CLI
make docker-mysql-cli       # MySQL shell
make docker-psql-cli        # PostgreSQL shell
make docker-mongo-cli       # MongoDB shell
make docker-redis-cli       # Redis shell
```

## Architecture

### Frontend (SvelteKit)

- **Framework**: SvelteKit 2.x with Svelte 5 (uses runes and modern Svelte syntax)
- **Styling**: Tailwind CSS 4.x with Flowbite Svelte components
- **Testing**: Vitest for unit tests, Playwright for E2E tests
- **UI Library**: Flowbite Svelte admin dashboard components in `src/lib/`

**Route Groups**:
- `(sidebar)` - Pages with sidebar navigation (dashboard, CRUD, settings, etc.)
- `(no-sidebar)` - Pages without sidebar
- `(no-layout)` - Pages with no shared layout

**Key files**:
- `svelte.config.js` - SvelteKit configuration with adapter-auto
- `vite.config.ts` - Vite config with Tailwind CSS plugin, test configuration
- `eslint.config.js` - ESLint flat config with TypeScript and Svelte support

### Backend (PHP with Docker)

- **Web Server**: Nginx serving PHP-FPM
- **PHP Environment**: Docker container with Composer
- **Databases**: Supports MySQL, PostgreSQL, MongoDB with Redis caching
- **Configuration**: Environment variables in `docker/.env`

The backend includes test database containers (mysql_test, postgres_test, mongo_test) for isolated testing.

## Testing Patterns

### Frontend Unit Tests
- Client-side Svelte tests: `*.svelte.{test,spec}.{js,ts}` (run with jsdom)
- Server-side tests: `*.{test,spec}.{js,ts}` (run with node)
- Setup file: `vitest-setup-client.ts`

### Frontend E2E Tests
- Located in `frontend/src/e2e/`
- Uses Playwright

## Environment Setup

### Frontend
Copy `.env.example` to `.env` in `frontend/src/`

### Backend
Copy `docker/.env.example` to `docker/.env` in `backend/`

Add `127.0.0.1 public.local` to `/etc/hosts` to access the backend at `http://public.local`
