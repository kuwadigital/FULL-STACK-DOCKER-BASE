# =============================================================================
# Node.js Dockerfile pour SvelteKit
# =============================================================================

ARG NODE_VERSION=22
FROM node:${NODE_VERSION}-alpine

# Installation des dépendances système nécessaires
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    libc6-compat

# Installation de pnpm globalement
RUN corepack enable && corepack prepare pnpm@latest --activate

# Configuration de pnpm pour le cache
RUN pnpm config set store-dir /root/.local/share/pnpm

# Création du répertoire de travail
WORKDIR /app

# L'image node:alpine contient déjà un utilisateur 'node' (UID/GID 1000)
# On utilise cet utilisateur existant pour les permissions
RUN chown -R node:node /app

# Exposition des ports (dev: 5173, preview: 4173)
EXPOSE 5173 4173

# Commande par défaut (sera remplacée dans docker-compose)
CMD ["pnpm", "dev", "--host"]
