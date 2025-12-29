ARG NGINX_VERSION=1.27
FROM nginx:${NGINX_VERSION}-alpine

# Copie de la configuration Nginx dans l'image
COPY conf.d/ /etc/nginx/conf.d/

# (Optionnel) on pourrait copier un nginx.conf custom si nécessaire.
# COPY nginx.conf /etc/nginx/nginx.conf
