# 🚀 Déploiement avec Ansible sur WSL2 (Local)

## TP7 - OPERATE : Solution locale sans cloud

---

## ✅ **Pourquoi WSL2 ?**

- ✅ Pas besoin de compte cloud
- ✅ Installation rapide (10 minutes)
- ✅ Fonctionne 100% en local
- ✅ Parfait pour tester Ansible
- ✅ Utilise Docker Desktop déjà installé

---

## 📋 **ÉTAPE 1 : Installer WSL2**

### 1.1 Ouvrir PowerShell en administrateur

Clic droit sur le menu Démarrer → **Windows PowerShell (Admin)**

### 1.2 Installer WSL2

```powershell
wsl --install
```

### 1.3 Redémarrer le PC

Après le redémarrage, Ubuntu s'ouvrira automatiquement.

### 1.4 Configurer Ubuntu

```
Enter new UNIX username: votreNom
New password: ******
Retype new password: ******
```

---

## 📋 **ÉTAPE 2 : Préparer WSL2**

### 2.1 Mettre à jour Ubuntu

Dans le terminal WSL2 :

```bash
sudo apt update
sudo apt upgrade -y
```

### 2.2 Installer Ansible et dépendances

```bash
sudo apt install -y ansible git python3-pip
```

### 2.3 Vérifier l'installation

```bash
ansible --version
```

Vous devriez voir :
```
ansible [core 2.x.x]
```

---

## 📋 **ÉTAPE 3 : Accéder au projet dans WSL2**

### 3.1 Naviguer vers le projet

Dans WSL2, votre lecteur C: est accessible via `/mnt/c/` :

```bash
cd /mnt/c/Users/Utilisateur/Desktop/Expernet/DEVOPS/TP3
```

### 3.2 Vérifier les fichiers

```bash
ls -la
```

Vous devriez voir : `deploy.yml`, `inventory.ini`, `ansible.cfg`

---

## 📋 **ÉTAPE 4 : Tester Ansible**

### 4.1 Test de connexion localhost

```bash
ansible localhost -m ping
```

**Résultat attendu :**
```
local | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 4.2 Vérifier la syntaxe du playbook

```bash
ansible-playbook deploy.yml --syntax-check
```

**Résultat attendu :**
```
playbook: deploy.yml
```

---

## 📋 **ÉTAPE 5 : Exécuter le déploiement**

### 5.1 Déploiement en mode dry-run (simulation)

```bash
ansible-playbook deploy.yml --check --limit localhost
```

Cela simule sans rien installer.

### 5.2 Déploiement réel

```bash
ansible-playbook deploy.yml --limit localhost
```

**⏱️ Temps d'exécution : 10-15 minutes**

Le playbook va :
1. ✅ Installer Docker (si pas déjà fait)
2. ✅ Installer Docker Compose
3. ✅ Cloner le repository
4. ✅ Lancer `docker-compose up -d`
5. ✅ Vérifier que l'application fonctionne

---

## 📋 **ÉTAPE 6 : Accéder à l'application**

Après le déploiement, ouvrez votre navigateur Windows :

### Frontend :
```
http://localhost:3000
```

### Backend API :
```
http://localhost:8080/api/health
```

---

## 📊 **Commandes utiles**

### Voir les logs Ansible

```bash
tail -f ansible.log
```

### Voir les conteneurs Docker

```bash
cd /opt/gestion-salles
docker-compose ps
docker-compose logs -f
```

### Redémarrer l'application

```bash
ansible-playbook deploy.yml --limit localhost --tags deploy
```

### Arrêter l'application

```bash
cd /opt/gestion-salles
docker-compose down
```

---

## 📸 **Captures d'écran pour le livrable**

Prenez des captures d'écran de :

1. ✅ **Terminal WSL2** : `ansible --version`
2. ✅ **Exécution du playbook** :
   ```bash
   ansible-playbook deploy.yml --limit localhost
   ```
3. ✅ **PLAY RECAP** : Résultat final avec statistiques
4. ✅ **Frontend** : Navigateur sur `http://localhost:3000`
5. ✅ **API Health** : `http://localhost:8080/api/health`
6. ✅ **Docker containers** :
   ```bash
   docker ps
   ```

---

## 🐛 **Dépannage**

### Problème : "docker: command not found"

Si Docker n'est pas détecté dans WSL2, vérifiez Docker Desktop :

1. Ouvrez **Docker Desktop**
2. Allez dans **Settings** → **Resources** → **WSL Integration**
3. Activez l'intégration avec Ubuntu
4. Redémarrez Docker Desktop

### Problème : "Permission denied" pour Docker

```bash
# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Redémarrer WSL2
exit
# Puis rouvrez WSL2
```

### Problème : Ports déjà utilisés

Si les ports 3000 ou 8080 sont déjà utilisés :

```bash
# Arrêter les conteneurs existants
cd /opt/gestion-salles
docker-compose down

# Ou arrêter Docker Desktop complètement
```

---

## ✅ **Avantages de cette solution**

| Critère | WSL2 Local | Oracle Cloud |
|---------|-----------|--------------|
| **Installation** | 10 min | 30 min |
| **Besoin Internet** | Première fois | Toujours |
| **Espace disque** | 3-5 GB | 0 GB |
| **IP publique** | ❌ Non | ✅ Oui |
| **Gratuit** | ✅ Oui | ✅ Oui |
| **Pour le TP** | ✅✅✅ | ✅✅✅ |

---

## 🎯 **Ce que vous démontrez**

Même en local, vous démontrez :
- ✅ Maîtrise d'Ansible
- ✅ Infrastructure as Code
- ✅ Automatisation du déploiement
- ✅ Docker & Docker Compose
- ✅ Linux (WSL2)

---

## 📝 **Pour le rendu TP7**

### Livrables :
1. ✅ `deploy.yml` (playbook commenté) ✅ Déjà fait !
2. ✅ `inventory.ini` (configuré pour localhost) ✅ Déjà fait !
3. ✅ Captures d'écran de l'exécution
4. ✅ Application fonctionnelle sur localhost

### Note importante :
**Le TP demande "une VM Linux ou container local"**  
→ WSL2 = VM Linux intégrée à Windows = ✅ **VALIDE !**

---

## 🎉 **Étapes suivantes**

1. **Installer WSL2** (si pas déjà fait)
2. **Installer Ansible dans WSL2**
3. **Aller dans votre projet** : `cd /mnt/c/Users/...`
4. **Tester** : `ansible localhost -m ping`
5. **Déployer** : `ansible-playbook deploy.yml --limit localhost`
6. **Prendre des captures d'écran**
7. **Rendre le TP !** 🚀

---

## 💡 **Besoin d'aide ?**

Si vous avez des erreurs pendant l'installation ou le déploiement, notez :
- Le message d'erreur complet
- La commande qui a échoué
- La sortie de `ansible --version`

**Bon courage !** 💪

