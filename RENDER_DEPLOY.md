# 🚀 Guide de Déploiement sur Render

Ce guide vous explique comment déployer l'application **Gestion des Salles** sur Render.com.

## 📋 Prérequis

- Un compte GitHub avec le code du projet
- Un compte Render.com (gratuit) : https://render.com

## 🎯 Architecture sur Render

Sur Render, l'application est décomposée en 3 services :

1. **Base de données PostgreSQL** (PostgreSQL Database)
2. **Backend PHP** (Web Service avec Docker)
3. **Frontend React** (Web Service avec Docker)

## 📝 Étapes de déploiement

### Option 1 : Déploiement automatique avec render.yaml (RECOMMANDÉ) ✅

Le fichier `render.yaml` à la racine du projet configure automatiquement tous les services.

1. **Créer un compte Render**
   - Allez sur https://render.com
   - Créez un compte (gratuit)
   - Connectez votre compte GitHub

2. **Créer un nouveau Blueprint**
   - Dans le dashboard Render, cliquez sur **"New"** > **"Blueprint"**
   - Sélectionnez votre repository GitHub
   - Render détectera automatiquement le fichier `render.yaml`
   - Cliquez sur **"Apply"**

3. **Attendre le déploiement**
   - Render va automatiquement :
     - Créer la base de données PostgreSQL
     - Déployer le backend PHP
     - Déployer le frontend React
   - Le processus prend environ 5-10 minutes

4. **Accéder à l'application**
   - Une fois le déploiement terminé, vous recevrez les URLs :
   - Frontend : `https://gestion-salles-frontend.onrender.com`
   - Backend : `https://gestion-salles-backend.onrender.com/api/health`

---

### Option 2 : Déploiement manuel (étape par étape)

Si vous préférez créer chaque service manuellement :

#### Étape 1 : Créer la base de données PostgreSQL

1. Dans Render, cliquez sur **"New"** > **"PostgreSQL"**
2. Configurez :
   - **Name** : `gestion-salles-db`
   - **Database** : `gestion_salles`
   - **User** : `postgres` (par défaut)
   - **Region** : Frankfurt (ou autre)
   - **Plan** : Free
3. Cliquez sur **"Create Database"**
4. Attendez que la base soit créée (1-2 minutes)
5. **Important** : Copiez l'**Internal Database URL** (commence par `postgresql://...`)

#### Étape 2 : Initialiser la base de données

1. Dans la page de la base de données, allez dans l'onglet **"Shell"**
2. Copiez-collez le contenu du fichier `backend/init.sql` :

```sql
CREATE TABLE IF NOT EXISTS salles (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    capacite INTEGER NOT NULL,
    equipement TEXT,
    disponible BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO salles (nom, capacite, equipement, disponible) VALUES
    ('Salle A101', 30, 'Projecteur, Tableau blanc', true),
    ('Salle B202', 50, 'Projecteur, Ordinateurs', true),
    ('Amphithéâtre C', 200, 'Projecteur, Sonorisation, Vidéo', false),
    ('Salle de réunion D1', 10, 'Tableau blanc, Visio-conférence', true)
ON CONFLICT DO NOTHING;
```

3. Exécutez le script

#### Étape 3 : Déployer le Backend PHP

1. Dans Render, cliquez sur **"New"** > **"Web Service"**
2. Sélectionnez votre repository GitHub
3. Configurez :
   - **Name** : `gestion-salles-backend`
   - **Region** : Frankfurt (même que la DB)
   - **Branch** : `main`
   - **Root Directory** : `backend`
   - **Environment** : `Docker`
   - **Dockerfile Path** : `backend/Dockerfile`
   - **Docker Build Context Directory** : `backend`
   - **Plan** : Free

4. **Variables d'environnement** :
   Cliquez sur **"Advanced"** > **"Add Environment Variable"** :
   
   | Key | Value |
   |-----|-------|
   | `DATABASE_URL` | Collez l'Internal Database URL de l'étape 1 |

5. **Health Check Path** : `/api/health`

6. Cliquez sur **"Create Web Service"**

7. Attendez le déploiement (5-7 minutes)

8. Une fois déployé, testez : `https://votre-backend.onrender.com/api/health`
   Vous devriez voir : `{"status":"OK","message":"API de gestion des salles"}`

#### Étape 4 : Déployer le Frontend React

1. Dans Render, cliquez sur **"New"** > **"Web Service"**
2. Sélectionnez votre repository GitHub
3. Configurez :
   - **Name** : `gestion-salles-frontend`
   - **Region** : Frankfurt
   - **Branch** : `main`
   - **Root Directory** : `frontend`
   - **Environment** : `Docker`
   - **Dockerfile Path** : `frontend/Dockerfile`
   - **Docker Build Context Directory** : `frontend`
   - **Plan** : Free

4. **Variables d'environnement** :
   | Key | Value |
   |-----|-------|
   | `REACT_APP_API_URL` | `https://gestion-salles-backend.onrender.com/api` |
   
   ⚠️ **Remplacez par l'URL réelle de votre backend !**

5. Cliquez sur **"Create Web Service"**

6. Attendez le déploiement (5-7 minutes)

7. Une fois déployé, accédez à votre frontend : `https://votre-frontend.onrender.com`

## 🔧 Configuration des Variables d'Environnement

### Backend

Le backend supporte maintenant deux modes de configuration :

1. **DATABASE_URL** (Render, Heroku, production)
   ```
   DATABASE_URL=postgresql://user:password@host:port/dbname
   ```

2. **Variables séparées** (Docker Compose local)
   ```
   DB_HOST=db
   DB_NAME=gestion_salles
   DB_USER=postgres
   DB_PASSWORD=postgres
   DB_PORT=5432
   ```

### Frontend

```
REACT_APP_API_URL=https://gestion-salles-backend.onrender.com/api
```

## ⚠️ Points importants

### 1. CORS
Le backend autorise déjà tous les domaines (`Access-Control-Allow-Origin: *`). Pas de configuration CORS nécessaire.

### 2. Plan gratuit Render
- ✅ Les services gratuits s'endorment après 15 minutes d'inactivité
- ⏱️ Le premier chargement après inactivité prend 30-60 secondes
- 🔄 Les services se réveillent automatiquement lors d'une requête
- 💡 Solution : Utilisez un service de ping (UptimeRobot) pour garder les services actifs

### 3. Build time
- Backend PHP : ~3-5 minutes
- Frontend React : ~5-7 minutes
- Base de données : ~1-2 minutes

### 4. URLs finales

Vos URLs Render seront du format :
- Backend : `https://gestion-salles-backend.onrender.com`
- Frontend : `https://gestion-salles-frontend.onrender.com`
- Database : URL interne uniquement (non accessible publiquement)

## 🐛 Dépannage

### Erreur : "could not translate host name 'db'"

✅ **Solution** : Assurez-vous que la variable `DATABASE_URL` est bien configurée dans le backend.

Le code backend a été modifié pour supporter `DATABASE_URL`. Redéployez le backend.

### Le frontend ne se connecte pas au backend

1. Vérifiez que `REACT_APP_API_URL` pointe vers l'URL correcte du backend
2. Testez le backend directement : `https://votre-backend.onrender.com/api/health`
3. Vérifiez les logs du backend sur Render

### Base de données vide

1. Allez dans la **Shell** de la base de données sur Render
2. Exécutez le script `backend/init.sql`

### Service très lent au premier chargement

C'est normal avec le plan gratuit. Le service s'endort après 15 minutes d'inactivité.

**Solutions** :
- Upgrade vers un plan payant
- Utilisez UptimeRobot pour ping le service toutes les 5 minutes

## 🔄 Redéploiement

### Automatique (avec GitHub)

Render se redéploie automatiquement à chaque `git push` sur la branche `main` !

```bash
git add .
git commit -m "Update application"
git push origin main
```

### Manuel

1. Allez dans le service sur Render
2. Cliquez sur **"Manual Deploy"** > **"Deploy latest commit"**

## 📊 Monitoring

### Voir les logs

1. Allez sur votre service dans Render
2. Cliquez sur **"Logs"**
3. Les logs en temps réel s'affichent

### Métriques

1. Allez sur votre service
2. Cliquez sur **"Metrics"**
3. Vous verrez :
   - CPU usage
   - Memory usage
   - Request count
   - Response times

## 💰 Coûts

### Plan gratuit
- PostgreSQL : 1 base de données gratuite
- Web Services : 750 heures/mois gratuites
- Limitations :
  - Services s'endorment après 15 min d'inactivité
  - CPU/RAM limités

### Plan payant
- Web Service : $7/mois
- PostgreSQL : $7/mois
- Pas de mise en veille
- Meilleures performances

## 🔗 Liens utiles

- [Documentation Render](https://render.com/docs)
- [Render Status](https://status.render.com)
- [Render Community](https://community.render.com)

## ✅ Checklist de déploiement

- [ ] Compte Render créé
- [ ] Repository GitHub connecté
- [ ] Base de données PostgreSQL créée
- [ ] Script init.sql exécuté
- [ ] Backend déployé avec DATABASE_URL
- [ ] Backend accessible : `/api/health` retourne OK
- [ ] Frontend déployé avec REACT_APP_API_URL
- [ ] Frontend accessible et fonctionnel
- [ ] Test CRUD : Créer/Lire/Modifier/Supprimer une salle

## 🎉 Application déployée !

Votre application est maintenant en ligne et accessible 24/7 (avec réveils pour le plan gratuit).

**Exemple d'URLs finales** :
- Frontend : https://gestion-salles-frontend.onrender.com
- Backend : https://gestion-salles-backend.onrender.com/api

---

**Bon déploiement ! 🚀**

