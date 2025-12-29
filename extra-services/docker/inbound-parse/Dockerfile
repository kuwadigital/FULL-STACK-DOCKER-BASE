# =============================================================================
# Inbound Parse - Simulateur SendGrid Inbound Parse Webhook
# =============================================================================

FROM node:22-alpine

# Installation des dépendances système
RUN apk add --no-cache \
    python3 \
    make \
    g++

# Création du répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY app/package.json ./

# Installation des dépendances
RUN npm install --omit=dev

# Copie du code source
COPY app/ ./

# Création des répertoires nécessaires
RUN mkdir -p /app/data /app/config

# Exposition des ports
EXPOSE 8080 2525

# Utiliser l'utilisateur 'node' existant dans l'image node:alpine
RUN chown -R node:node /app

USER node

# Démarrage de l'application
CMD ["node", "server.js"]
