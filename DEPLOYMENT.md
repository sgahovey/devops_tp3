# Guide de Déploiement et Configuration CI/CD

Ce guide vous explique comment configurer votre repository GitHub et activer le pipeline CI/CD.

## Table des matières

1. [Configuration initiale du repository](#1-configuration-initiale-du-repository)
2. [Configuration des secrets GitHub](#2-configuration-des-secrets-github)
3. [Activation du pipeline CI/CD](#3-activation-du-pipeline-cicd)
4. [Vérification du pipeline](#4-vérification-du-pipeline)
5. [Docker Hub (optionnel)](#5-docker-hub-optionnel)

## 1. Configuration initiale du repository

### Créer un repository GitHub

1. Allez sur https://github.com
2. Cliquez sur le bouton **"New"** ou **"+"** > **"New repository"**
3. Remplissez les informations :
   - **Repository name** : `tp3-gestion-salles` (ou autre nom)
   - **Description** : "Application de gestion des salles - TP3 DevOps"
   - Choisissez **Public** ou **Private**
   - Ne cochez pas "Initialize this repository with a README" (vous en avez déjà un)
4. Cliquez sur **"Create repository"**

### Pousser le code vers GitHub

```bash
# Initialiser Git dans votre projet
git init

# Ajouter tous les fichiers
git add .

# Créer le premier commit
git commit -m "Initial commit - Application de gestion des salles"

# Ajouter le remote GitHub (remplacez par votre URL)
git remote add origin https://github.com/VOTRE_USERNAME/tp3-gestion-salles.git

# Pousser le code
git push -u origin main
```

Si vous êtes sur la branche `master` au lieu de `main` :

```bash
git branch -M main
git push -u origin main
```

## 2. Configuration des secrets GitHub

Les secrets sont nécessaires pour publier les images Docker sur Docker Hub (optionnel).

### Étapes :

1. Allez sur votre repository GitHub
2. Cliquez sur **Settings** (⚙️)
3. Dans le menu de gauche, cliquez sur **Secrets and variables** > **Actions**
4. Cliquez sur **New repository secret**
5. Ajoutez les secrets suivants :

#### Secret 1 : DOCKER_USERNAME
- **Name** : `DOCKER_USERNAME`
- **Value** : Votre nom d'utilisateur Docker Hub
- Cliquez sur **Add secret**

#### Secret 2 : DOCKER_PASSWORD
- **Name** : `DOCKER_PASSWORD`
- **Value** : Votre mot de passe Docker Hub (ou un Access Token)
- Cliquez sur **Add secret**

### Créer un Access Token Docker Hub (recommandé)

Au lieu d'utiliser votre mot de passe, créez un Access Token :

1. Connectez-vous sur https://hub.docker.com
2. Allez dans **Account Settings** > **Security**
3. Cliquez sur **New Access Token**
4. Donnez un nom : "GitHub Actions CI"
5. Copiez le token généré
6. Utilisez ce token comme valeur pour `DOCKER_PASSWORD`

## 3. Activation du pipeline CI/CD

Le pipeline CI/CD est déjà configuré dans `.github/workflows/ci.yml`.

### Déclencheurs automatiques :

Le pipeline se déclenche automatiquement lors de :

- **Push** sur les branches `main` ou `develop`
- **Pull Request** vers les branches `main` ou `develop`

### Déclencher manuellement :

1. Allez sur votre repository GitHub
2. Cliquez sur l'onglet **Actions**
3. Sélectionnez le workflow **"CI/CD Pipeline - Gestion des Salles"**
4. Cliquez sur **Run workflow**

## 4. Vérification du pipeline

### Voir l'exécution du pipeline :

1. Allez sur l'onglet **Actions** de votre repository
2. Vous verrez la liste des exécutions de workflows
3. Cliquez sur une exécution pour voir les détails

### Jobs du pipeline :

Le pipeline contient 3 jobs principaux :

1. **Backend Build & Test** (🐘 PHP)
   - Setup PHP 8.1
   - Installation des dépendances Composer
   - Exécution des tests PHPUnit
   - Build de l'image Docker

2. **Frontend Build & Test** (⚛️ React)
   - Setup Node.js 18
   - Installation des dépendances npm
   - Exécution des tests
   - Build de l'application
   - Build de l'image Docker

3. **Docker Compose Test** (🐳)
   - Build de tous les services
   - Démarrage de l'application
   - Tests de santé des endpoints

4. **Publish Images** (optionnel, uniquement sur `main`)
   - Publication sur Docker Hub

### Indicateurs de statut :

- ✅ **Vert** : Le pipeline a réussi
- ❌ **Rouge** : Le pipeline a échoué
- 🟡 **Jaune** : Le pipeline est en cours

## 5. Docker Hub (optionnel)

### Créer un compte Docker Hub

Si vous n'avez pas de compte Docker Hub :

1. Allez sur https://hub.docker.com
2. Cliquez sur **Sign Up**
3. Créez votre compte

### Créer des repositories

1. Connectez-vous sur Docker Hub
2. Cliquez sur **Create Repository**
3. Créez deux repositories :
   - `gestion-salles-backend`
   - `gestion-salles-frontend`
4. Choisissez **Public** ou **Private**

### Modifier le workflow (si nécessaire)

Si vos repositories Docker Hub ont des noms différents, modifiez `.github/workflows/ci.yml` :

```yaml
# Ligne à modifier (environ ligne 125-130)
docker build -t VOTRE_USERNAME/gestion-salles-backend:latest ./backend
docker push VOTRE_USERNAME/gestion-salles-backend:latest

docker build -t VOTRE_USERNAME/gestion-salles-frontend:latest ./frontend
docker push VOTRE_USERNAME/gestion-salles-frontend:latest
```

## 🎯 Vérification finale

### Checklist :

- [ ] Repository GitHub créé
- [ ] Code poussé sur GitHub
- [ ] Secrets GitHub configurés (si Docker Hub activé)
- [ ] Pipeline CI/CD exécuté avec succès
- [ ] Tous les tests passent (backend et frontend)
- [ ] Images Docker construites
- [ ] Docker Compose test réussi
- [ ] (Optionnel) Images publiées sur Docker Hub

### Commandes de vérification locale :

```bash
# Tester le build des images
docker-compose build

# Tester l'application complète
docker-compose up

# Vérifier les endpoints
curl http://localhost:8080/api/health
curl http://localhost:3000

# Lancer les tests backend
cd backend && composer test

# Lancer les tests frontend
cd frontend && npm test
```

## 🔗 Liens utiles

- [Documentation GitHub Actions](https://docs.github.com/en/actions)
- [Documentation Docker](https://docs.docker.com)
- [Documentation Docker Compose](https://docs.docker.com/compose)
- [Docker Hub](https://hub.docker.com)

## 📊 Badge de statut

Ajoutez ce badge à votre README pour afficher le statut du pipeline :

```markdown
![CI/CD Pipeline](https://github.com/VOTRE_USERNAME/tp3-gestion-salles/workflows/CI%2FCD%20Pipeline%20-%20Gestion%20des%20Salles/badge.svg)
```

Remplacez `VOTRE_USERNAME` et `tp3-gestion-salles` par vos valeurs.

## 🆘 Dépannage

### Le pipeline échoue sur les tests

```bash
# Vérifier les tests localement
cd backend && composer test
cd frontend && npm test
```

### Erreur de connexion Docker Hub

- Vérifiez que les secrets `DOCKER_USERNAME` et `DOCKER_PASSWORD` sont correctement configurés
- Utilisez un Access Token au lieu du mot de passe
- Vérifiez que votre compte Docker Hub est actif

### L'application ne démarre pas

```bash
# Voir les logs
docker-compose logs

# Reconstruire les images
docker-compose build --no-cache
docker-compose up
```

## 📝 Notes

- Le job **Publish Images** ne s'exécute que sur la branche `main` lors d'un push
- Les Pull Requests déclenchent tous les tests mais ne publient pas les images
- Vous pouvez désactiver la publication Docker Hub en commentant le job dans `.github/workflows/ci.yml`

---

**Bon déploiement ! 🚀**


