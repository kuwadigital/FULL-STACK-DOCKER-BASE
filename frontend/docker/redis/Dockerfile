# =============================================================================
# Redis Dockerfile pour le cache frontend
# =============================================================================

ARG REDIS_VERSION
FROM redis:${REDIS_VERSION}-alpine

# Créer le répertoire de configuration avec les bonnes permissions
RUN mkdir -p /usr/local/etc/redis && chmod 755 /usr/local/etc/redis

# Copie du fichier de configuration Redis
COPY redis.conf /usr/local/etc/redis/redis.conf

# S'assurer que le fichier et le répertoire sont accessibles par l'utilisateur redis
RUN chmod 644 /usr/local/etc/redis/redis.conf && \
    chown -R redis:redis /usr/local/etc/redis

# Exposition du port Redis
EXPOSE 6379

# Lancement du serveur Redis avec notre configuration
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
