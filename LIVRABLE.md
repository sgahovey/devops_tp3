# 📦 LIVRABLE - TP3 DevOps : Intégration Continue & Conteneurisation

## ✅ Résumé du livrable

Ce document récapitule tous les livrables du TP3 conformément aux consignes.

## 📋 Consignes du TP3

### ✅ 1. Dockerfile pour le backend PHP

**Fichier :** `backend/Dockerfile`

**Caractéristiques :**
- Image de base : `php:8.1-apache`
- Extensions installées : PDO, pdo_pgsql
- Composer intégré
- Configuration Apache optimisée
- Build multi-stage non applicable (serveur Apache nécessaire)

**Test :**
```bash
docker build -t backend-test ./backend
docker run -p 8080:80 backend-test
```

### ✅ 2. Dockerfile pour le frontend Node.js

**Fichier :** `frontend/Dockerfile`

**Caractéristiques :**
- Image de base : `node:18-alpine`
- Build multi-stage (build + production)
- Optimisation de la taille de l'image
- Serveur `serve` pour fichiers statiques
- Port 3000 exposé

**Test :**
```bash
docker build -t frontend-test ./frontend
docker run -p 3000:3000 frontend-test
```

### ✅ 3. Fichier docker-compose.yml

**Fichier :** `docker-compose.yml`

**Services configurés :**

#### 📱 Frontend (React)
- Port : 3000
- Dépend de : backend
- Réseau : app_network

#### 🔧 Backend (PHP)
- Port : 8080 (mappé depuis 80)
- Dépend de : db
- Variables d'environnement : DB_HOST, DB_NAME, DB_USER, DB_PASSWORD
- Réseau : app_network

#### 🗄️ Base de données (PostgreSQL)
- Image : postgres:15-alpine
- Port : 5432
- Volume persistant : postgres_data
- Script d'initialisation : init.sql
- Health check configuré
- Réseau : app_network

#### 🌐 Réseau
- Nom : `gestion_salles_network`
- Type : bridge
- Communication inter-conteneurs par nom de service

**Test :**
```bash
docker-compose up --build
```

**Vérification :**
```bash
# Voir les services
docker-compose ps

# Tester le backend
curl http://localhost:8080/api/health

# Tester le frontend
curl http://localhost:3000
```

### ✅ 4. Vérification du bon fonctionnement

**Scripts de démarrage fournis :**

#### Windows :
```bash
start.bat
```

#### Linux/Mac :
```bash
chmod +x start.sh
./start.sh
```

**Tests manuels :**
```bash
# Test 1 : Démarrer l'application
docker-compose up -d

# Test 2 : Vérifier les services
docker-compose ps

# Test 3 : Tester l'API
curl http://localhost:8080/api/health
curl http://localhost:8080/api/salles

# Test 4 : Tester le frontend
# Ouvrir http://localhost:3000 dans le navigateur

# Test 5 : Tester la base de données
docker-compose exec db psql -U postgres -d gestion_salles -c "SELECT * FROM salles;"
```

**Scripts de test automatisés :**
```bash
# Windows
test-api.bat

# Linux/Mac
chmod +x test-api.sh
./test-api.sh
```

### ✅ 5. Configuration GitHub Actions CI

**Fichier :** `.github/workflows/ci.yml`

**Jobs configurés :**

#### Job 1 : Backend Build & Test 🐘
- Setup PHP 8.1
- Installation Composer
- **Exécution tests PHPUnit** ✓
- Build image Docker backend
- Service PostgreSQL pour tests

#### Job 2 : Frontend Build & Test ⚛️
- Setup Node.js 18
- Installation npm
- **Exécution tests React** ✓
- Build application
- Build image Docker frontend

#### Job 3 : Docker Compose Test 🐳
- Build de tous les services
- Démarrage de l'application complète
- Health checks des endpoints
- Tests d'intégration

#### Job 4 : Publish Images 📦 (optionnel)
- Publication sur Docker Hub
- Uniquement sur la branche `main`
- Avec secrets configurés

**Déclencheurs :**
- Push sur `main` ou `develop`
- Pull Request vers `main` ou `develop`

**Test du pipeline :**
1. Pusher le code sur GitHub
2. Voir l'exécution dans l'onglet "Actions"
3. Vérifier que tous les jobs passent au vert ✅

## 📂 Structure complète du projet

```
TP3/
├── .github/
│   └── workflows/
│       └── ci.yml                 # ✅ GitHub Actions CI/CD
│
├── backend/
│   ├── tests/
│   │   └── ApiTest.php            # ✅ Tests unitaires backend
│   ├── index.php                  # API REST principale
│   ├── init.sql                   # Script initialisation DB
│   ├── Dockerfile                 # ✅ Dockerfile backend PHP
│   ├── composer.json              # Dépendances PHP
│   ├── phpunit.xml                # Configuration tests
│   └── .dockerignore              # Optimisation build
│
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── App.js                 # Application React
│   │   ├── App.css
│   │   ├── App.test.js            # ✅ Tests unitaires frontend
│   │   ├── index.js
│   │   ├── index.css
│   │   └── setupTests.js
│   ├── Dockerfile                 # ✅ Dockerfile frontend Node.js
│   ├── package.json               # Dépendances npm
│   └── .dockerignore              # Optimisation build
│
├── docker-compose.yml             # ✅ Orchestration des services
├── .gitignore                     # Fichiers à ignorer
│
├── README.md                      # 📖 Documentation principale
├── DEPLOYMENT.md                  # 🚀 Guide de déploiement
├── COMMANDS.md                    # 📝 Commandes utiles
├── FAQ.md                         # ❓ Questions fréquentes
├── ARCHITECTURE.md                # 🏗️ Architecture technique
├── LIVRABLE.md                    # 📦 Ce fichier
│
├── start.sh                       # Script démarrage Linux/Mac
├── start.bat                      # Script démarrage Windows
├── test-api.sh                    # Tests API Linux/Mac
├── test-api.bat                   # Tests API Windows
└── postman-collection.json        # Collection Postman
```

## 🎯 Points de vérification

### ✅ Dockerfiles fonctionnels

- [x] `backend/Dockerfile` construit sans erreur
- [x] `frontend/Dockerfile` construit sans erreur
- [x] Build multi-stage pour le frontend
- [x] Images optimisées (Alpine Linux)
- [x] Extensions PHP installées (pdo_pgsql)
- [x] Composer installé dans le backend

### ✅ docker-compose.yml fonctionnel

- [x] 3 services configurés (frontend, backend, db)
- [x] Réseau commun (`gestion_salles_network`)
- [x] Variables d'environnement configurées
- [x] Volumes persistants pour PostgreSQL
- [x] Health check pour la base de données
- [x] Dépendances entre services (depends_on)
- [x] Ports correctement mappés

### ✅ GitHub Actions CI

- [x] Workflow configuré (`.github/workflows/ci.yml`)
- [x] Build des images Docker (backend + frontend)
- [x] Tests unitaires backend (PHPUnit)
- [x] Tests unitaires frontend (Jest)
- [x] Tests d'intégration (Docker Compose)
- [x] Déclenchement automatique (push/PR)
- [x] Publication Docker Hub (optionnel)

### ✅ Tests unitaires

- [x] Tests backend PHPUnit (`backend/tests/ApiTest.php`)
- [x] Tests frontend Jest (`frontend/src/App.test.js`)
- [x] Exécution dans le pipeline CI
- [x] Commandes locales documentées

## 🔗 Lien vers le pipeline CI GitHub Actions

**⚠️ À COMPLÉTER PAR L'ÉTUDIANT ⚠️**

Une fois le code poussé sur GitHub, ajoutez le lien ici :

```
https://github.com/VOTRE_USERNAME/VOTRE_REPO/actions
```

**Badge de statut (optionnel) :**
```markdown
![CI/CD Pipeline](https://github.com/VOTRE_USERNAME/VOTRE_REPO/workflows/CI%2FCD%20Pipeline%20-%20Gestion%20des%20Salles/badge.svg)
```

## 📸 Captures d'écran suggérées

Pour compléter le livrable, prenez des captures d'écran de :

1. **Application en fonctionnement**
   - Interface frontend (http://localhost:3000)
   - Liste des salles
   - Formulaire d'ajout de salle

2. **Docker**
   - Résultat de `docker-compose ps`
   - Images construites (`docker images`)

3. **GitHub Actions**
   - Pipeline CI en succès (onglet Actions)
   - Détails des jobs exécutés

4. **Tests**
   - Résultat des tests backend
   - Résultat des tests frontend

## 🚀 Commandes de démonstration

### Démarrage rapide
```bash
# 1. Cloner le projet
git clone <votre-repo>
cd TP3

# 2. Démarrer l'application
docker-compose up --build

# 3. Tester l'API
curl http://localhost:8080/api/health

# 4. Ouvrir le frontend
# Navigateur → http://localhost:3000
```

### Vérification des services
```bash
# Voir les conteneurs
docker-compose ps

# Voir les logs
docker-compose logs -f

# Tester la base de données
docker-compose exec db psql -U postgres -d gestion_salles -c "SELECT * FROM salles;"
```

### Exécuter les tests
```bash
# Tests backend
docker-compose exec backend vendor/bin/phpunit tests

# Tests frontend
docker-compose exec frontend npm test -- --watchAll=false
```

## 📚 Documentation complète

### Fichiers de documentation fournis :

1. **README.md** - Documentation principale et guide utilisateur
2. **DEPLOYMENT.md** - Guide de déploiement et configuration GitHub
3. **COMMANDS.md** - Liste exhaustive des commandes utiles
4. **FAQ.md** - Questions fréquentes et dépannage
5. **ARCHITECTURE.md** - Architecture technique détaillée
6. **LIVRABLE.md** - Ce fichier (récapitulatif du livrable)

### Fichiers de configuration :

- `.github/workflows/ci.yml` - Pipeline CI/CD
- `docker-compose.yml` - Orchestration
- `backend/Dockerfile` - Image backend
- `frontend/Dockerfile` - Image frontend
- `backend/phpunit.xml` - Configuration tests PHP
- `frontend/package.json` - Configuration tests React

### Scripts utilitaires :

- `start.sh` / `start.bat` - Démarrage facile
- `test-api.sh` / `test-api.bat` - Tests API
- `postman-collection.json` - Collection Postman

## ✨ Fonctionnalités de l'application

### CRUD complet sur les salles :
- ✅ Lister toutes les salles
- ✅ Voir les détails d'une salle
- ✅ Créer une nouvelle salle
- ✅ Modifier une salle existante
- ✅ Supprimer une salle

### Données stockées :
- Nom de la salle
- Capacité (nombre de personnes)
- Équipement disponible
- Statut de disponibilité
- Timestamps (création/modification)

### Interface utilisateur :
- Design moderne et responsive
- Animations et transitions fluides
- Validation des formulaires
- Gestion des erreurs
- États de chargement

## 🎓 Conformité aux consignes

| Consigne | Status | Fichier(s) |
|----------|--------|------------|
| Dockerfile backend PHP | ✅ | `backend/Dockerfile` |
| Dockerfile frontend Node.js | ✅ | `frontend/Dockerfile` |
| docker-compose.yml avec 3 services | ✅ | `docker-compose.yml` |
| Réseau commun | ✅ | `docker-compose.yml` (app_network) |
| Vérification fonctionnement | ✅ | Scripts `start.*`, `test-api.*` |
| GitHub Actions CI | ✅ | `.github/workflows/ci.yml` |
| Build images Docker | ✅ | Jobs backend-build-and-test, frontend-build-and-test |
| Tests unitaires backend | ✅ | `backend/tests/ApiTest.php` |
| Lien pipeline CI | ⚠️ | À compléter après push sur GitHub |

## 📝 Instructions pour la soumission

### 1. Pousser sur GitHub
```bash
git init
git add .
git commit -m "TP3 - Application de gestion des salles"
git remote add origin https://github.com/VOTRE_USERNAME/VOTRE_REPO.git
git push -u origin main
```

### 2. Vérifier le pipeline CI
- Aller sur GitHub → Onglet "Actions"
- Vérifier que le workflow s'exécute
- Attendre que tous les jobs passent au vert ✅

### 3. Configurer Docker Hub (optionnel)
- Settings → Secrets and variables → Actions
- Ajouter `DOCKER_USERNAME` et `DOCKER_PASSWORD`

### 4. Compléter le livrable
- Copier le lien du pipeline dans ce fichier
- Prendre des captures d'écran
- Créer un document de présentation (optionnel)

### 5. Soumettre le travail
- Lien vers le repository GitHub
- Lien vers le pipeline CI/CD
- (Optionnel) Captures d'écran
- (Optionnel) Document de présentation

## ✅ Checklist finale

Avant de soumettre, vérifiez que :

- [ ] Le code est poussé sur GitHub
- [ ] Le pipeline CI passe au vert
- [ ] `docker-compose up` fonctionne sans erreur
- [ ] Le frontend est accessible (http://localhost:3000)
- [ ] L'API répond (http://localhost:8080/api/health)
- [ ] Les tests backend passent
- [ ] Les tests frontend passent
- [ ] La documentation est complète
- [ ] Le lien du pipeline est ajouté
- [ ] (Optionnel) Secrets Docker Hub configurés

## 🎉 Conclusion

Ce projet démontre la maîtrise complète de :

- 🐳 **Conteneurisation** avec Docker
- 🔧 **Orchestration** avec Docker Compose
- 🚀 **CI/CD** avec GitHub Actions
- 🧪 **Tests automatisés** (backend et frontend)
- 📦 **Build automatisé** d'images Docker
- 🏗️ **Architecture microservices**
- 📚 **Documentation complète**

---

**TP3 - DevOps - Expernet 2025**  
**Étudiant :** [VOTRE NOM]  
**Date :** [DATE]  
**Lien GitHub :** [VOTRE_LIEN]  
**Lien Pipeline CI :** [LIEN_ACTIONS]

