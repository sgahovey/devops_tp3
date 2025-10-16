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

# Lancer docker-compose
CMD ["docker-compose", "up", "--build"]
