# =============================================================================
# ABS-WEB - MAKEFILE GLOBAL
# =============================================================================
# Ce Makefile contrôle l'ensemble de l'application:
# - Frontend (SvelteKit)
# - Backend (PHP)
# - Extra Services (Traefik, Keycloak, Greenmail, etc.)
# =============================================================================

# Charger les variables d'environnement globales
ifneq (,$(wildcard .env))
include .env
export $(shell sed 's/=.*//' .env)
endif

# Chemins des docker-compose (utilise docker compose v2)
DC_FRONTEND = docker compose -f frontend/docker/docker-compose.yml --env-file .env
DC_BACKEND = docker compose -f backend/docker/docker-compose.yml --env-file .env
DC_SERVICES = docker compose -f extra-services/docker/docker-compose.yml --env-file .env

# Couleurs pour l'affichage
CYAN = \033[36m
GREEN = \033[32m
YELLOW = \033[33m
RED = \033[31m
RESET = \033[0m
BOLD = \033[1m

# =============================================================================
# AIDE
# =============================================================================

.PHONY: help
help: ## Afficher cette aide
	@echo ""
	@echo "$(BOLD)$(CYAN)╔══════════════════════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(CYAN)║                         ABS-WEB - COMMANDES DISPONIBLES                      ║$(RESET)"
	@echo "$(BOLD)$(CYAN)╚══════════════════════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(CYAN)%-35s$(RESET) %s\n", $$1, $$2}'
	@echo ""

.DEFAULT_GOAL := help

# =============================================================================
# INITIALISATION ET SETUP
# =============================================================================

init: ## Initialisation complète du projet (certificats, réseaux, builds)
	@echo "$(BOLD)$(GREEN)=== Initialisation du projet ABS-WEB ===$(RESET)"
	@$(MAKE) networks-create
	@$(MAKE) certs-generate
	@$(MAKE) hosts-info
	@$(MAKE) build-all
	@echo "$(BOLD)$(GREEN)=== Initialisation terminée ===$(RESET)"

networks-create: ## Créer les réseaux Docker
	@echo "$(YELLOW)Création des réseaux Docker...$(RESET)"
	@docker network create $(NETWORK_FRONTEND) 2>/dev/null || true
	@docker network create $(NETWORK_BACKEND) 2>/dev/null || true
	@docker network create $(NETWORK_SERVICES) 2>/dev/null || true
	@echo "$(GREEN)Réseaux créés$(RESET)"

networks-remove: ## Supprimer les réseaux Docker
	@echo "$(YELLOW)Suppression des réseaux Docker...$(RESET)"
	@docker network rm $(NETWORK_FRONTEND) 2>/dev/null || true
	@docker network rm $(NETWORK_BACKEND) 2>/dev/null || true
	@docker network rm $(NETWORK_SERVICES) 2>/dev/null || true

certs-generate: ## Générer les certificats SSL auto-signés
	@echo "$(YELLOW)Génération des certificats SSL...$(RESET)"
	@chmod +x extra-services/docker/traefik/certs/generate-certs.sh
	@cd extra-services/docker/traefik/certs && ./generate-certs.sh

hosts-info: ## Afficher les entrées à ajouter dans /etc/hosts
	@echo ""
	@echo "$(BOLD)$(YELLOW)=== Ajoutez ces entrées à votre fichier /etc/hosts ===$(RESET)"
	@echo ""
	@echo "127.0.0.1   app.local"
	@echo "127.0.0.1   api.local"
	@echo "127.0.0.1   auth.local"
	@echo "127.0.0.1   mail.local"
	@echo "127.0.0.1   traefik.local"
	@echo "127.0.0.1   parse.local"
	@echo ""
	@echo "$(YELLOW)Sur Linux/macOS: sudo nano /etc/hosts$(RESET)"
	@echo "$(YELLOW)Sur Windows: C:\\Windows\\System32\\drivers\\etc\\hosts$(RESET)"
	@echo ""

# =============================================================================
# BUILD
# =============================================================================

build-all: build-services build-frontend build-backend ## Construire toutes les images Docker

build-services: ## Construire les images des extra-services
	@echo "$(YELLOW)Construction des images extra-services...$(RESET)"
	$(DC_SERVICES) build

build-frontend: ## Construire les images du frontend
	@echo "$(YELLOW)Construction des images frontend...$(RESET)"
	$(DC_FRONTEND) build

build-backend: ## Construire les images du backend
	@echo "$(YELLOW)Construction des images backend...$(RESET)"
	$(DC_BACKEND) build

build-no-cache: ## Construire toutes les images sans cache
	@echo "$(YELLOW)Construction sans cache...$(RESET)"
	$(DC_SERVICES) build --no-cache
	$(DC_FRONTEND) build --no-cache
	$(DC_BACKEND) build --no-cache

# =============================================================================
# DÉMARRAGE COMPLET
# =============================================================================

start: start-services start-backend start-frontend status ## Démarrer toute l'application
	@echo ""
	@echo "$(BOLD)$(GREEN)=== Application démarrée ===$(RESET)"
	@$(MAKE) urls

start-dev: start-services start-backend-mysql start-frontend-dev status ## Démarrer en mode développement

stop: ## Arrêter toute l'application
	@echo "$(YELLOW)Arrêt de l'application...$(RESET)"
	$(DC_FRONTEND) stop
	$(DC_BACKEND) --profile mysql --profile postgres --profile mongo stop
	$(DC_SERVICES) stop
	@echo "$(GREEN)Application arrêtée$(RESET)"

down: ## Arrêter et supprimer les conteneurs (garde les volumes)
	@echo "$(YELLOW)Arrêt et suppression des conteneurs...$(RESET)"
	$(DC_FRONTEND) down
	$(DC_BACKEND) --profile mysql --profile postgres --profile mongo down
	$(DC_SERVICES) down
	@echo "$(GREEN)Conteneurs supprimés$(RESET)"

restart: stop start ## Redémarrer toute l'application

clean: ## Arrêter, supprimer les conteneurs ET les volumes (reset complet)
	@echo "$(RED)ATTENTION: Suppression de toutes les données!$(RESET)"
	@read -p "Êtes-vous sûr? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	$(DC_FRONTEND) down -v
	$(DC_BACKEND) --profile mysql --profile postgres --profile mongo down -v
	$(DC_SERVICES) down -v
	@$(MAKE) networks-remove
	@echo "$(GREEN)Nettoyage complet effectué$(RESET)"

# =============================================================================
# EXTRA SERVICES (Traefik, Keycloak, Greenmail, etc.)
# =============================================================================

start-services: networks-create ## Démarrer les extra-services
	@echo "$(YELLOW)Démarrage des extra-services...$(RESET)"
	$(DC_SERVICES) up -d
	@echo "$(GREEN)Extra-services démarrés$(RESET)"

stop-services: ## Arrêter les extra-services
	$(DC_SERVICES) stop

down-services: ## Arrêter et supprimer les extra-services
	$(DC_SERVICES) down

logs-services: ## Voir les logs des extra-services
	$(DC_SERVICES) logs -f --tail=100

logs-traefik: ## Voir les logs de Traefik
	$(DC_SERVICES) logs -f traefik

logs-keycloak: ## Voir les logs de Keycloak
	$(DC_SERVICES) logs -f keycloak

logs-greenmail: ## Voir les logs de Greenmail
	$(DC_SERVICES) logs -f greenmail

shell-traefik: ## Shell dans le conteneur Traefik
	$(DC_SERVICES) exec traefik sh

# =============================================================================
# FRONTEND
# =============================================================================

start-frontend: networks-create ## Démarrer le frontend (production)
	@echo "$(YELLOW)Démarrage du frontend...$(RESET)"
	$(DC_FRONTEND) up -d node redis

start-frontend-dev: networks-create ## Démarrer le frontend (développement)
	@echo "$(YELLOW)Démarrage du frontend en mode dev...$(RESET)"
	$(DC_FRONTEND) up -d node redis
	@echo "$(GREEN)Frontend démarré: http://localhost:$(FRONTEND_DEV_PORT)$(RESET)"

start-frontend-prod: networks-create ## Démarrer le frontend (production avec Nginx)
	@echo "$(YELLOW)Démarrage du frontend en production...$(RESET)"
	$(DC_FRONTEND) --profile production up -d

stop-frontend: ## Arrêter le frontend
	$(DC_FRONTEND) --profile production stop

down-frontend: ## Arrêter et supprimer le frontend
	$(DC_FRONTEND) --profile production down

logs-frontend: ## Voir les logs du frontend
	$(DC_FRONTEND) logs -f --tail=100

logs-node: ## Voir les logs du conteneur Node
	$(DC_FRONTEND) logs -f node

shell-node: ## Shell dans le conteneur Node
	$(DC_FRONTEND) exec node sh

frontend-install: ## Installer les dépendances frontend
	$(DC_FRONTEND) exec node pnpm install

frontend-build: ## Build du frontend
	$(DC_FRONTEND) exec node pnpm build

frontend-lint: ## Linter le frontend
	$(DC_FRONTEND) exec node pnpm lint

frontend-test: ## Tests du frontend
	$(DC_FRONTEND) exec node pnpm test

# =============================================================================
# BACKEND
# =============================================================================

start-backend: start-backend-mysql ## Démarrer le backend (MySQL par défaut)

start-backend-mysql: networks-create ## Démarrer le backend avec MySQL
	@echo "$(YELLOW)Démarrage du backend avec MySQL...$(RESET)"
	COMPOSE_PROFILES=mysql $(DC_BACKEND) up -d

start-backend-postgres: networks-create ## Démarrer le backend avec PostgreSQL
	@echo "$(YELLOW)Démarrage du backend avec PostgreSQL...$(RESET)"
	COMPOSE_PROFILES=postgres $(DC_BACKEND) up -d

start-backend-mongo: networks-create ## Démarrer le backend avec MongoDB
	@echo "$(YELLOW)Démarrage du backend avec MongoDB...$(RESET)"
	COMPOSE_PROFILES=mongo $(DC_BACKEND) up -d

stop-backend: ## Arrêter le backend
	COMPOSE_PROFILES=mysql,postgres,mongo $(DC_BACKEND) stop

down-backend: ## Arrêter et supprimer le backend
	COMPOSE_PROFILES=mysql,postgres,mongo $(DC_BACKEND) down

logs-backend: ## Voir les logs du backend
	COMPOSE_PROFILES=mysql,postgres,mongo $(DC_BACKEND) logs -f --tail=100

logs-php: ## Voir les logs PHP
	$(DC_BACKEND) logs -f php

logs-nginx-backend: ## Voir les logs Nginx backend
	$(DC_BACKEND) logs -f nginx

shell-php: ## Shell dans le conteneur PHP
	$(DC_BACKEND) exec php bash

shell-php-root: ## Shell root dans le conteneur PHP
	$(DC_BACKEND) exec --user root php bash

backend-composer-install: ## Installer les dépendances PHP
	$(DC_BACKEND) exec php composer install

backend-composer-update: ## Mettre à jour les dépendances PHP
	$(DC_BACKEND) exec php composer update

backend-test: ## Tests PHP
	$(DC_BACKEND) exec php php vendor/bin/phpunit

# =============================================================================
# BASE DE DONNÉES
# =============================================================================

db-mysql-cli: ## CLI MySQL
	$(DC_BACKEND) exec mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

db-postgres-cli: ## CLI PostgreSQL
	$(DC_BACKEND) exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

db-mongo-cli: ## CLI MongoDB
	$(DC_BACKEND) exec mongo mongosh -u $(MONGO_INITDB_ROOT_USERNAME) -p $(MONGO_INITDB_ROOT_PASSWORD)

db-redis-cli: ## CLI Redis
	$(DC_BACKEND) exec redis redis-cli

db-keycloak-cli: ## CLI PostgreSQL Keycloak
	$(DC_SERVICES) exec postgres-keycloak psql -U $(KEYCLOAK_DB_USER) -d $(KEYCLOAK_DB_NAME)

# =============================================================================
# STATUS ET MONITORING
# =============================================================================

status: ## Afficher le status de tous les conteneurs
	@echo ""
	@echo "$(BOLD)$(CYAN)=== Extra Services ===$(RESET)"
	@$(DC_SERVICES) ps
	@echo ""
	@echo "$(BOLD)$(CYAN)=== Frontend ===$(RESET)"
	@$(DC_FRONTEND) --profile production ps
	@echo ""
	@echo "$(BOLD)$(CYAN)=== Backend ===$(RESET)"
	@COMPOSE_PROFILES=mysql,postgres,mongo $(DC_BACKEND) ps
	@echo ""

ps: status ## Alias pour status

urls: ## Afficher les URLs de l'application
	@echo ""
	@echo "$(BOLD)$(GREEN)╔══════════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(GREEN)║                         URLS DE L'APPLICATION                     ║$(RESET)"
	@echo "$(BOLD)$(GREEN)╚══════════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(BOLD)Application:$(RESET)"
	@echo "  Frontend:        $(CYAN)https://app.local$(RESET)"
	@echo "  Backend API:     $(CYAN)https://api.local$(RESET)"
	@echo ""
	@echo "$(BOLD)Services:$(RESET)"
	@echo "  Traefik:         $(CYAN)https://traefik.local$(RESET) (Dashboard)"
	@echo "  Keycloak:        $(CYAN)https://auth.local$(RESET) (admin/admin)"
	@echo "  Roundcube:       $(CYAN)https://mail.local$(RESET)"
	@echo "  Inbound Parse:   $(CYAN)https://parse.local$(RESET)"
	@echo ""
	@echo "$(BOLD)Développement (accès direct):$(RESET)"
	@echo "  Frontend Dev:    $(CYAN)http://localhost:$(FRONTEND_DEV_PORT)$(RESET)"
	@echo "  Adminer:         $(CYAN)http://localhost:$(ADMINER_PORT)$(RESET)"
	@echo "  Greenmail API:   $(CYAN)http://localhost:$(GREENMAIL_API_PORT)$(RESET)"
	@echo ""

health: ## Vérifier la santé des services
	@echo "$(YELLOW)Vérification de la santé des services...$(RESET)"
	@echo ""
	@echo "Traefik: $$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$(TRAEFIK_DASHBOARD_PORT)/ping 2>/dev/null || echo 'DOWN')"
	@echo "Keycloak: $$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$(KEYCLOAK_PORT)/health 2>/dev/null || echo 'DOWN')"
	@echo "Frontend: $$(curl -s -o /dev/null -w '%{http_code}' http://localhost:$(FRONTEND_DEV_PORT) 2>/dev/null || echo 'DOWN')"
	@echo ""

# =============================================================================
# DÉVELOPPEMENT LOCAL (sans Docker)
# =============================================================================

local-frontend-dev: ## Lancer le frontend localement
	cd frontend/src && pnpm dev

local-frontend-build: ## Build le frontend localement
	cd frontend/src && pnpm build

local-frontend-install: ## Installer les dépendances frontend localement
	cd frontend/src && pnpm install

# =============================================================================
# UTILITAIRES
# =============================================================================

prune: ## Nettoyer les ressources Docker inutilisées
	@echo "$(YELLOW)Nettoyage des ressources Docker...$(RESET)"
	docker system prune -f
	docker volume prune -f
	@echo "$(GREEN)Nettoyage terminé$(RESET)"

logs-all: ## Voir tous les logs
	@echo "Utilisez Ctrl+C pour arrêter"
	$(DC_SERVICES) logs -f &
	$(DC_FRONTEND) logs -f &
	COMPOSE_PROFILES=mysql $(DC_BACKEND) logs -f

env-check: ## Vérifier les variables d'environnement
	@echo "$(BOLD)Variables d'environnement chargées:$(RESET)"
	@echo "APP_DOMAIN: $(APP_DOMAIN)"
	@echo "NODE_ENV: $(NODE_ENV)"
	@echo "FRONTEND_HOST: $(FRONTEND_HOST)"
	@echo "BACKEND_HOST: $(BACKEND_HOST)"
	@echo "AUTH_HOST: $(AUTH_HOST)"
