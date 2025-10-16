# Dockerfile pour Railway - Lance docker-compose
FROM docker/compose:latest

# Installer les outils nécessaires
RUN apk add --no-cache docker-cli bash curl

# Copier tous les fichiers
WORKDIR /app
COPY . .

# Donner les permissions d'exécution
RUN chmod +x docker-compose.yml

# Exposer les ports
EXPOSE 3000 8080

# Script de démarrage avec gestion d'erreurs
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo 'echo "Starting docker-compose..."' >> /start.sh && \
    echo 'docker-compose --version' >> /start.sh && \
    echo 'docker --version' >> /start.sh && \
    echo 'echo "Using Railway-compatible docker-compose.yml"' >> /start.sh && \
    echo 'docker-compose -f docker-compose.railway.yml up --build' >> /start.sh && \
    chmod +x /start.sh

# Lancer le script
CMD ["/start.sh"]
