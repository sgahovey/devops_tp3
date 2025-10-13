# Application de Gestion des Salles

Application web pour gérer les salles de réunion développée pour le TP3 DevOps.

## Technologies utilisées

- **Frontend** : React 18.2
- **Backend** : PHP 8.1 avec Apache
- **Base de données** : PostgreSQL 15
- **Conteneurisation** : Docker & Docker Compose
- **CI/CD** : GitHub Actions

## Installation et démarrage

### Prérequis
- Docker Desktop installé et lancé
- Git

### Lancer l'application

```bash
# Cloner le projet
git clone https://github.com/sgahovey/devops_tp3.git
cd devops_tp3

# Démarrer avec Docker Compose
docker-compose up --build
```

Attendez quelques secondes que tous les services démarrent.

### Accès à l'application

- **Frontend** : http://localhost:3000
- **API Backend** : http://localhost:8080/api
- **Base de données** : localhost:5432

## Architecture

L'application est composée de 3 services Docker :

1. **Frontend React** (port 3000)
   - Interface utilisateur pour gérer les salles
   - Communication avec l'API via Axios

2. **Backend PHP** (port 8080)
   - API REST pour les opérations CRUD
   - Connexion à PostgreSQL via PDO

3. **Base de données PostgreSQL** (port 5432)
   - Stockage des données des salles
   - Initialisation automatique avec données de test

Tous les services communiquent via un réseau Docker commun.

## Endpoints API

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/salles` | Liste toutes les salles |
| GET | `/api/salles/{id}` | Détails d'une salle |
| POST | `/api/salles` | Créer une nouvelle salle |
| PUT | `/api/salles/{id}` | Modifier une salle |
| DELETE | `/api/salles/{id}` | Supprimer une salle |
| GET | `/api/health` | Health check |

### Exemple de requête

```bash
# Créer une salle
curl -X POST http://localhost:8080/api/salles \
  -H "Content-Type: application/json" \
  -d '{"nom":"Salle A101","capacite":30,"equipement":"Projecteur","disponible":true}'
```

## Tests

### Tests backend (PHPUnit)
```bash
docker-compose exec backend vendor/bin/phpunit tests
```

### Tests frontend (Jest)
```bash
docker-compose exec frontend npm test
```

## CI/CD

Le pipeline GitHub Actions s'exécute automatiquement à chaque push et effectue :

1. **Backend** :
   - Installation des dépendances PHP
   - Exécution des tests PHPUnit
   - Build de l'image Docker

2. **Frontend** :
   - Installation des dépendances npm
   - Exécution des tests Jest
   - Build de l'application
   - Build de l'image Docker

3. **Intégration** :
   - Lancement de docker-compose
   - Vérification du bon fonctionnement des services

## Commandes Docker utiles

```bash
# Démarrer les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down

# Tout supprimer (y compris les volumes)
docker-compose down -v

# Reconstruire les images
docker-compose build --no-cache
```

## Base de données

### Schéma de la table `salles`

| Colonne | Type | Description |
|---------|------|-------------|
| id | SERIAL | Clé primaire auto-incrémentée |
| nom | VARCHAR(255) | Nom de la salle |
| capacite | INTEGER | Capacité en nombre de personnes |
| equipement | TEXT | Équipements disponibles |
| disponible | BOOLEAN | Statut de disponibilité |
| created_at | TIMESTAMP | Date de création |
| updated_at | TIMESTAMP | Date de modification |

### Accéder à la base de données

```bash
docker-compose exec db psql -U postgres -d gestion_salles
```

## Développement

### Structure du projet

```
.
├── backend/           # API PHP
├── frontend/          # Application React
├── .github/           # Configuration CI/CD
└── docker-compose.yml # Orchestration des services
```

### Fichiers Docker

- `backend/Dockerfile` : Image PHP 8.1 + Apache avec extensions PDO PostgreSQL
- `frontend/Dockerfile` : Build multi-stage Node.js 18 + serve
- `docker-compose.yml` : Orchestration des 3 services

## Fonctionnalités

- Lister toutes les salles
- Voir les détails d'une salle
- Créer une nouvelle salle
- Modifier une salle existante
- Supprimer une salle
- Interface responsive
- Gestion des erreurs
- Validation des données

## Licence

Projet réalisé dans le cadre du TP3 DevOps - Expernet 2025
