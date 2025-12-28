# =============================================================================
# Nginx Dockerfile pour servir l'application SvelteKit en production
# =============================================================================

ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}-alpine

# Copie de la configuration Nginx personnalisée
COPY conf.d/ /etc/nginx/conf.d/

# Création du répertoire pour les logs
RUN mkdir -p /var/log/nginx

# Exposition du port HTTP
EXPOSE 80

# Commande par défaut
CMD ["nginx", "-g", "daemon off;"]
