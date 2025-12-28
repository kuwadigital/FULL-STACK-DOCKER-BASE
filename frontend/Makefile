# =============================================================================
# FRONTEND MAKEFILE
# =============================================================================
# Ce Makefile fournit des commandes pour gérer l'environnement Docker du frontend
# ainsi que les opérations courantes de développement.
# =============================================================================

# Charger les variables d'environnement Docker (si le fichier existe)
ifneq (,$(wildcard docker/.env))
include docker/.env
export $(shell sed -e 's/=.*//' docker/.env)
endif

# Configuration Docker Compose
DOCKER_COMPOSE = docker-compose -f ./docker/docker-compose.yml

# =============================================================================
# AIDE
# =============================================================================

.PHONY: help
help: ## Afficher cette aide
	@echo ""
	@echo "╔══════════════════════════════════════════════════════════════════╗"
	@echo "║                    FRONTEND - COMMANDES DISPONIBLES              ║"
	@echo "╚══════════════════════════════════════════════════════════════════╝"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""

.DEFAULT_GOAL := help

# =============================================================================
# COMMANDES DE BUILD ET DÉMARRAGE
# =============================================================================

docker-build: ## Construire les images Docker (Node, Nginx, Redis)
	$(DOCKER_COMPOSE) build

docker-build-no-cache: ## Construire les images Docker sans cache
	$(DOCKER_COMPOSE) build --no-cache

# -----------------------------------------------------------------------------
# Développement
# -----------------------------------------------------------------------------

docker-start: docker-start-dev ## Démarrer l'environnement de développement (alias)

docker-start-dev: ## Démarrer l'environnement de développement (Node + Redis)
	$(DOCKER_COMPOSE) up -d node redis
	@echo ""
	@echo "╔══════════════════════════════════════════════════════════════════╗"
	@echo "║  Frontend démarré en mode développement                          ║"
	@echo "║  URL: http://localhost:$(APP_DEV_PORT)                                     ║"
	@echo "╚══════════════════════════════════════════════════════════════════╝"
	@echo ""

docker-start-dev-attached: ## Démarrer le développement avec logs en temps réel
	$(DOCKER_COMPOSE) up node redis

# -----------------------------------------------------------------------------
# Production
# -----------------------------------------------------------------------------

docker-start-prod: ## Démarrer l'environnement de production (Nginx + Redis)
	$(DOCKER_COMPOSE) --profile production up -d
	@echo ""
	@echo "╔══════════════════════════════════════════════════════════════════╗"
	@echo "║  Frontend démarré en mode production                             ║"
	@echo "║  URL: http://localhost:$(APP_PROD_PORT)                                     ║"
	@echo "╚══════════════════════════════════════════════════════════════════╝"
	@echo ""

# -----------------------------------------------------------------------------
# Arrêt et nettoyage
# -----------------------------------------------------------------------------

docker-stop: ## Arrêter les conteneurs
	$(DOCKER_COMPOSE) --profile production stop

docker-down: ## Arrêter et supprimer les conteneurs (sans supprimer les volumes)
	$(DOCKER_COMPOSE) --profile production down

docker-clean: ## Arrêter et supprimer les conteneurs ET les volumes (reset complet)
	$(DOCKER_COMPOSE) --profile production down -v
	@echo "Environnement Docker nettoyé (volumes supprimés)."

docker-prune: ## Nettoyer les ressources Docker inutilisées
	docker system prune -f
	@echo "Ressources Docker inutilisées supprimées."

# =============================================================================
# ACCÈS AUX CONTENEURS
# =============================================================================

docker-shell-node: ## Ouvrir un shell dans le conteneur Node
	$(DOCKER_COMPOSE) exec node sh

docker-shell-redis: ## Ouvrir un client Redis (shell)
	$(DOCKER_COMPOSE) exec redis redis-cli

docker-logs: ## Suivre les logs de tous les services
	$(DOCKER_COMPOSE) --profile production logs -f --tail=100

docker-logs-node: ## Suivre les logs du conteneur Node uniquement
	$(DOCKER_COMPOSE) logs -f --tail=100 node

docker-logs-redis: ## Suivre les logs du conteneur Redis uniquement
	$(DOCKER_COMPOSE) logs -f --tail=100 redis

docker-ps: ## Lister les conteneurs en cours d'exécution
	$(DOCKER_COMPOSE) --profile production ps

# =============================================================================
# COMMANDES APPLICATIVES (dans le conteneur Node)
# =============================================================================

app-install: ## Installer les dépendances (pnpm install)
	$(DOCKER_COMPOSE) exec node pnpm install

app-update: ## Mettre à jour les dépendances (pnpm update)
	$(DOCKER_COMPOSE) exec node pnpm update

app-dev: ## Lancer le serveur de développement (pnpm dev)
	$(DOCKER_COMPOSE) exec node pnpm dev --host

app-build: ## Construire l'application pour la production (pnpm build)
	$(DOCKER_COMPOSE) exec node pnpm build

app-preview: ## Prévisualiser le build de production (pnpm preview)
	$(DOCKER_COMPOSE) exec node pnpm preview --host

app-check: ## Vérifier les types TypeScript (pnpm check)
	$(DOCKER_COMPOSE) exec node pnpm check

app-lint: ## Exécuter le linter (pnpm lint)
	$(DOCKER_COMPOSE) exec node pnpm lint

app-format: ## Formater le code (pnpm format)
	$(DOCKER_COMPOSE) exec node pnpm format

# =============================================================================
# TESTS
# =============================================================================

app-test: ## Exécuter tous les tests
	$(DOCKER_COMPOSE) exec node pnpm test

app-test-unit: ## Exécuter les tests unitaires (Vitest)
	$(DOCKER_COMPOSE) exec node pnpm test:unit

app-test-e2e: ## Exécuter les tests E2E (Playwright)
	$(DOCKER_COMPOSE) exec node pnpm test:e2e

app-test-watch: ## Exécuter les tests en mode watch
	$(DOCKER_COMPOSE) exec node pnpm test:unit --watch

# =============================================================================
# UTILITAIRES
# =============================================================================

app-clean-deps: ## Supprimer node_modules et réinstaller
	$(DOCKER_COMPOSE) exec node rm -rf node_modules
	$(DOCKER_COMPOSE) exec node pnpm install
	@echo "Dépendances réinstallées."

app-outdated: ## Afficher les dépendances obsolètes
	$(DOCKER_COMPOSE) exec node pnpm outdated

app-audit: ## Auditer les dépendances pour les vulnérabilités
	$(DOCKER_COMPOSE) exec node pnpm audit

# =============================================================================
# COMMANDES LOCALES (sans Docker)
# =============================================================================

local-install: ## Installer les dépendances localement
	cd src && pnpm install

local-dev: ## Lancer le serveur de développement localement
	cd src && pnpm dev

local-build: ## Construire l'application localement
	cd src && pnpm build

local-preview: ## Prévisualiser le build localement
	cd src && pnpm preview

local-check: ## Vérifier les types localement
	cd src && pnpm check

local-lint: ## Linter localement
	cd src && pnpm lint

local-format: ## Formater localement
	cd src && pnpm format

local-test: ## Tester localement
	cd src && pnpm test
