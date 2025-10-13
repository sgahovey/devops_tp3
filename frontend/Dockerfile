# Build stage
FROM node:18-alpine AS build

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm install --silent

# Copier le reste des fichiers
COPY . .

# Build de l'application
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Installer serve pour servir l'application
RUN npm install -g serve

# Copier les fichiers buildés depuis le stage précédent
COPY --from=build /app/build ./build

# Exposer le port 3000
EXPOSE 3000

# Démarrer l'application
CMD ["serve", "-s", "build", "-l", "3000"]

