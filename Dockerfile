# Dockerfile principal pour orchestrer l'application complète
# Ce Dockerfile utilise Docker-in-Docker pour lancer tous les services

FROM docker:24-dind

# Installer docker-compose
RUN apk add --no-cache \
    docker-compose \
    bash \
    curl

# Créer le répertoire de travail
WORKDIR /app

# Copier tous les fichiers du projet
COPY . .

# Exposer les ports nécessaires
# Port 3000 pour le frontend (page principale)
EXPOSE 3000
# Port 8080 pour le backend API
EXPOSE 8080
# Port 5432 pour PostgreSQL
EXPOSE 5432

# Script de démarrage
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Démarrer le daemon Docker' >> /start.sh && \
    echo 'dockerd-entrypoint.sh &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Attendre que Docker soit prêt' >> /start.sh && \
    echo 'echo "⏳ Attente du démarrage de Docker..."' >> /start.sh && \
    echo 'timeout=60' >> /start.sh && \
    echo 'counter=0' >> /start.sh && \
    echo 'until docker info >/dev/null 2>&1; do' >> /start.sh && \
    echo '  if [ $counter -ge $timeout ]; then' >> /start.sh && \
    echo '    echo "❌ Timeout: Docker n'\''a pas démarré"' >> /start.sh && \
    echo '    exit 1' >> /start.sh && \
    echo '  fi' >> /start.sh && \
    echo '  sleep 1' >> /start.sh && \
    echo '  counter=$((counter + 1))' >> /start.sh && \
    echo 'done' >> /start.sh && \
    echo 'echo "✅ Docker est prêt!"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Construire et lancer les services avec docker-compose' >> /start.sh && \
    echo 'echo "🚀 Démarrage de l'\''application Gestion des Salles..."' >> /start.sh && \
    echo 'cd /app' >> /start.sh && \
    echo 'docker-compose up --build' >> /start.sh && \
    chmod +x /start.sh

# Définir le point d'entrée
CMD ["/start.sh"]

# Informations
LABEL maintainer="Expernet DevOps TP3"
LABEL description="Application de Gestion des Salles - Full Stack (React + PHP + PostgreSQL)"
LABEL version="1.0.0"

# Instructions de démarrage:
# docker build -t gestion-salles .
# docker run -p 3000:3000 -p 8080:8080 --privileged gestion-salles
#
# L'application sera accessible sur:
# - Frontend: http://localhost:3000
# - Backend API: http://localhost:8080/api

