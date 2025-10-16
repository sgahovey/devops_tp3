# 🚂 Guide de Déploiement sur Railway

Ce guide vous explique comment déployer l'application **Gestion des Salles** sur Railway.app avec **docker-compose.yml complet** (incluant la base de données PostgreSQL dans Docker).

## ✨ Pourquoi Railway ?

✅ **Supporte docker-compose nativement** - Déploie tous vos conteneurs Docker  
✅ **Base de données dans Docker** - Utilise le conteneur PostgreSQL de votre docker-compose.yml  
✅ **Déploiement automatique** - Git push = déploiement automatique  
✅ **Plan gratuit** - $5 de crédit gratuit chaque mois  
✅ **Facile** - Configuration en 5 minutes  

## 📋 Prérequis

- Un compte GitHub avec le code du projet
- Un compte Railway.app (gratuit) : https://railway.app

---

## 🚀 Étapes de déploiement

### Étape 1️⃣ : Créer un compte Railway

1. Allez sur **https://railway.app**
2. Cliquez sur **"Login"** puis **"Login with GitHub"**
3. Autorisez Railway à accéder à votre compte GitHub
4. Vous recevez **$5 de crédit gratuit** chaque mois ! 🎁

### Étape 2️⃣ : Créer un nouveau projet

1. Sur le **Dashboard Railway**, cliquez sur **"New Project"**
2. Sélectionnez **"Deploy from GitHub repo"**
3. Choisissez votre repository **`devops_tp3`** (ou le nom de votre repo)
4. Railway va automatiquement détecter votre `docker-compose.yml` ! 🎉

### Étape 3️⃣ : Configuration des services

Railway va automatiquement créer **3 services** depuis votre docker-compose.yml :

#### Service 1 : Base de données PostgreSQL (`db`)
- ✅ Conteneur Docker avec l'image `postgres:15-alpine`
- ✅ Volume persistant pour les données
- ✅ Script d'initialisation `init.sql` exécuté automatiquement
- ⚠️ **Pas de port exposé publiquement** (sécurisé, accessible uniquement en interne)

#### Service 2 : Backend PHP (`backend`)
- ✅ Construit depuis `backend/Dockerfile`
- ✅ Connecté à la base de données via le réseau interne
- ✅ Port exposé publiquement pour l'API

#### Service 3 : Frontend React (`frontend`)
- ✅ Construit depuis `frontend/Dockerfile`
- ✅ Port exposé publiquement pour l'interface utilisateur

### Étape 4️⃣ : Ajuster les variables d'environnement

Railway utilise votre docker-compose.yml, mais vous devez vérifier/ajuster quelques variables :

#### Pour le **Backend** :

1. Cliquez sur le service **backend** dans Railway
2. Allez dans l'onglet **"Variables"**
3. Vérifiez que ces variables existent (elles sont normalement auto-détectées) :
   ```
   DB_HOST=db
   DB_NAME=gestion_salles
   DB_USER=postgres
   DB_PASSWORD=postgres
   ```

#### Pour le **Frontend** :

1. Cliquez sur le service **frontend** dans Railway
2. Allez dans l'onglet **"Variables"**
3. **IMPORTANT** : Modifiez `REACT_APP_API_URL` :
   
   ```
   REACT_APP_API_URL=https://VOTRE-BACKEND-URL.railway.app/api
   ```
   
   🔍 Pour obtenir l'URL du backend :
   - Cliquez sur le service **backend**
   - Allez dans **"Settings"**
   - Copiez l'URL sous **"Domains"**
   - Ajoutez `/api` à la fin

   Exemple : `https://gestion-salles-backend-production.up.railway.app/api`

### Étape 5️⃣ : Exposer les services publiquement

Par défaut, Railway n'expose pas les ports publiquement. Vous devez le faire manuellement :

#### Exposer le Backend :

1. Cliquez sur le service **backend**
2. Allez dans **"Settings"**
3. Scrollez jusqu'à **"Networking"**
4. Cliquez sur **"Generate Domain"**
5. Railway va créer une URL comme : `https://gestion-salles-backend-production.up.railway.app`

#### Exposer le Frontend :

1. Cliquez sur le service **frontend**
2. Allez dans **"Settings"**
3. Scrollez jusqu'à **"Networking"**
4. Cliquez sur **"Generate Domain"**
5. Railway va créer une URL comme : `https://gestion-salles-frontend-production.up.railway.app`

⚠️ **N'exposez PAS la base de données** - Elle doit rester privée et accessible uniquement en interne.

### Étape 6️⃣ : Redéployer le frontend

Après avoir modifié `REACT_APP_API_URL` à l'étape 4 :

1. Retournez sur le service **frontend**
2. Allez dans l'onglet **"Deployments"**
3. Cliquez sur le menu **⋮** du dernier déploiement
4. Sélectionnez **"Redeploy"**
5. Attendez 3-5 minutes que le build se termine

### Étape 7️⃣ : Vérifier que tout fonctionne

#### Test 1 : API Backend
Ouvrez dans votre navigateur :
```
https://VOTRE-BACKEND-URL.railway.app/api/health
```

Résultat attendu :
```json
{"status":"OK","message":"API de gestion des salles"}
```

#### Test 2 : Liste des salles
```
https://VOTRE-BACKEND-URL.railway.app/api/salles
```

Résultat attendu : Vous devriez voir les 4 salles de test (A101, B202, etc.) 🎉

#### Test 3 : Frontend
Ouvrez dans votre navigateur :
```
https://VOTRE-FRONTEND-URL.railway.app
```

Résultat attendu : L'interface de gestion des salles s'affiche ! 🎨

---

## 🏗️ Architecture sur Railway

```
┌─────────────────────────────────────────────┐
│           Railway Project                    │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  Service: frontend (React)           │   │
│  │  Port: 3000                          │   │
│  │  URL: https://...railway.app         │   │
│  └───────────────┬──────────────────────┘   │
│                  │ Appelle                  │
│                  ▼                          │
│  ┌──────────────────────────────────────┐   │
│  │  Service: backend (PHP)              │   │
│  │  Port: 80                            │   │
│  │  URL: https://...railway.app/api     │   │
│  └───────────────┬──────────────────────┘   │
│                  │ Se connecte              │
│                  ▼                          │
│  ┌──────────────────────────────────────┐   │
│  │  Service: db (PostgreSQL)            │   │
│  │  Port: 5432 (interne uniquement)     │   │
│  │  Conteneur Docker avec volume        │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  Réseau interne Railway                     │
│  Communication entre services par nom        │
└─────────────────────────────────────────────┘
```

## 📊 Comment Railway gère docker-compose.yml

Railway lit votre `docker-compose.yml` et :

1. ✅ **Crée un service par conteneur** défini dans le compose
2. ✅ **Build les Dockerfiles** automatiquement
3. ✅ **Configure le réseau interne** - Les services communiquent par leur nom (`db`, `backend`, `frontend`)
4. ✅ **Gère les volumes** - Les données PostgreSQL sont persistées
5. ✅ **Applique les variables d'environnement** du compose
6. ✅ **Exécute init.sql** automatiquement au démarrage de PostgreSQL

**Votre base de données PostgreSQL tourne bien dans un conteneur Docker sur Railway, pas en local ! 🐳**

## 🔄 Déploiement continu

Une fois configuré, chaque `git push` sur votre branche `main` déclenchera automatiquement :

1. 🔄 Railway détecte le push GitHub
2. 🏗️ Build des nouveaux Dockerfiles si modifiés
3. 🚀 Redéploiement automatique
4. ✅ Application mise à jour en ~5 minutes

```bash
# Sur votre machine locale
git add .
git commit -m "Update application"
git push origin main

# Railway redéploie automatiquement ! 🎉
```

## 💰 Coûts Railway

### Plan Gratuit (Hobby)
- **$5 de crédit gratuit** chaque mois
- Suffisant pour ce projet en développement
- Les services s'endorment après inactivité (comme Render)

### Consommation estimée pour ce projet :
- Frontend : ~$1-2/mois
- Backend : ~$1-2/mois  
- PostgreSQL : ~$1-2/mois
- **Total : ~$3-6/mois** (dans votre crédit gratuit !)

### Plan Pro ($20/mois)
- Pas de mise en veille
- Plus de ressources
- Support prioritaire

## ⚙️ Configuration avancée

### Modifier les ressources allouées

Pour chaque service, dans **Settings** :
- **Memory** : 512 MB par défaut (suffisant)
- **CPU** : Partagé (suffisant pour le plan gratuit)

### Voir les logs en temps réel

1. Cliquez sur un service
2. Allez dans l'onglet **"Deployments"**
3. Cliquez sur le déploiement actif
4. Les logs s'affichent en temps réel 📊

### Accéder à la base de données

Railway ne fournit pas de shell web pour PostgreSQL, mais vous pouvez :

#### Option 1 : Utiliser Railway CLI

```bash
# Installer Railway CLI
npm install -g @railway/cli

# Se connecter
railway login

# Se connecter à la base de données
railway connect postgres
```

#### Option 2 : Connexion locale avec les credentials

1. Dans le service **db**, allez dans **"Variables"**
2. Notez les credentials PostgreSQL
3. Utilisez un client comme **pgAdmin** ou **DBeaver**

## 🐛 Dépannage

### Le frontend ne se connecte pas au backend

**Solution** : Vérifiez que `REACT_APP_API_URL` pointe vers la bonne URL du backend.

1. Copiez l'URL du backend depuis **Settings** > **Domains**
2. Mettez à jour la variable dans le frontend : `https://votre-backend.railway.app/api`
3. Redéployez le frontend

### La base de données ne s'initialise pas

**Solution** : Le script `init.sql` devrait s'exécuter automatiquement. Si ce n'est pas le cas :

1. Connectez-vous via Railway CLI : `railway connect postgres`
2. Exécutez manuellement le contenu de `backend/init.sql`

### Erreur "out of memory"

**Solution** : Le plan gratuit a des limites de mémoire.

1. Optimisez vos Dockerfiles (déjà fait avec alpine)
2. Ou passez au plan Pro

### Les services s'endorment

Avec le plan gratuit, les services s'endorment après ~15 minutes d'inactivité.

**Solutions** :
- Utilisez un service de ping (UptimeRobot)
- Passez au plan Pro ($20/mois)

## 🔗 Liens utiles

- [Documentation Railway](https://docs.railway.app)
- [Railway CLI](https://docs.railway.app/develop/cli)
- [Railway Community](https://discord.gg/railway)
- [Pricing Railway](https://railway.app/pricing)

## ✅ Checklist de déploiement

- [ ] Compte Railway créé et connecté à GitHub
- [ ] Projet créé depuis le repository GitHub
- [ ] 3 services détectés automatiquement (db, backend, frontend)
- [ ] Variables d'environnement vérifiées pour le backend
- [ ] URL du backend copiée
- [ ] Variable `REACT_APP_API_URL` mise à jour dans le frontend
- [ ] Domaines générés pour backend et frontend
- [ ] Frontend redéployé après modification des variables
- [ ] Test `/api/health` : ✅ OK
- [ ] Test `/api/salles` : ✅ Retourne les salles
- [ ] Frontend accessible et fonctionnel
- [ ] Test CRUD complet : Créer/Lire/Modifier/Supprimer une salle

## 🎉 Application déployée !

Votre application complète (avec base de données PostgreSQL dans Docker) est maintenant déployée sur Railway !

**URLs finales :**
- Frontend : `https://gestion-salles-frontend-production.up.railway.app`
- Backend : `https://gestion-salles-backend-production.up.railway.app/api`
- Base de données : Conteneur Docker privé (accessible uniquement en interne)

**La base de données PostgreSQL tourne dans un conteneur Docker sur Railway, exactement comme votre docker-compose.yml local ! 🐳🎯**

---

**Bon déploiement ! 🚂🚀**

