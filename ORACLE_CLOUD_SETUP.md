# 🚀 Guide de déploiement sur Oracle Cloud

## TP7 - OPERATE : Déploiement automatisé avec Ansible

---

## 📋 Prérequis

### Sur votre machine locale (Windows) :
1. **Ansible** : Installez via WSL2 (Windows Subsystem for Linux) ou Git Bash
2. **Compte Oracle Cloud** : https://www.oracle.com/cloud/free/
3. **SSH** : Accès SSH configuré

---

## 🌩️ ÉTAPE 1 : Créer une VM sur Oracle Cloud

### 1.1 Se connecter à Oracle Cloud
1. Allez sur : https://cloud.oracle.com/
2. Connectez-vous avec votre compte

### 1.2 Créer une instance de calcul (VM)
1. Dans le menu, allez à : **Compute** → **Instances**
2. Cliquez sur **Create Instance**

### 1.3 Configuration de l'instance

#### Nom :
```
gestion-salles-vm
```

#### Image et forme (Shape) :
- **Image** : `Ubuntu 22.04` (ou 20.04)
- **Shape** : `VM.Standard.E2.1.Micro` (Always Free - 1 CPU, 1 GB RAM)

#### Réseau :
- **VCN** : Créer un nouveau VCN ou utiliser celui par défaut
- **Subnet** : Public subnet
- **Assign a public IPv4 address** : ✅ Coché

#### Clés SSH :
1. Sélectionnez : **Generate a key pair for me**
2. **Téléchargez la clé privée** : `ssh-key-YYYY-MM-DD.key`
3. **Téléchargez la clé publique** : `ssh-key-YYYY-MM-DD.key.pub`

**⚠️ IMPORTANT : Conservez ces fichiers en lieu sûr !**

### 1.4 Créer l'instance
- Cliquez sur **Create**
- Attendez que l'instance passe à l'état **Running** (2-3 minutes)
- **Notez l'IP publique** de votre instance

---

## 🔧 ÉTAPE 2 : Configurer le pare-feu (Security Lists)

### 2.1 Ouvrir les ports nécessaires

1. Sur la page de votre instance, cliquez sur le **Subnet**
2. Cliquez sur la **Security List** par défaut
3. Cliquez sur **Add Ingress Rules**

#### Règle 1 : Frontend (React)
```
Source CIDR: 0.0.0.0/0
IP Protocol: TCP
Destination Port Range: 3000
Description: Frontend React
```

#### Règle 2 : Backend (API)
```
Source CIDR: 0.0.0.0/0
IP Protocol: TCP
Destination Port Range: 8080
Description: Backend API
```

#### Règle 3 : SSH (déjà présente normalement)
```
Source CIDR: 0.0.0.0/0
IP Protocol: TCP
Destination Port Range: 22
Description: SSH
```

### 2.2 Configurer le pare-feu Ubuntu (sur la VM)

Une fois connecté en SSH (voir étape 3), exécutez :

```bash
# Autoriser les ports
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 8080/tcp

# Activer le pare-feu
sudo ufw enable

# Vérifier
sudo ufw status
```

---

## 🔑 ÉTAPE 3 : Configurer SSH sur votre machine

### 3.1 Déplacer la clé SSH

**Sur Windows (PowerShell) :**

```powershell
# Créer le dossier .ssh si nécessaire
mkdir ~/.ssh -Force

# Déplacer la clé téléchargée
Move-Item "C:\Users\Utilisateur\Downloads\ssh-key-*.key" ~/.ssh/oracle_cloud_key

# Définir les permissions (Windows)
icacls ~/.ssh/oracle_cloud_key /inheritance:r
icacls ~/.ssh/oracle_cloud_key /grant:r "$($env:USERNAME):(R)"
```

**Sur Linux/WSL/Git Bash :**

```bash
# Créer le dossier .ssh
mkdir -p ~/.ssh

# Déplacer la clé
mv ~/Downloads/ssh-key-*.key ~/.ssh/oracle_cloud_key

# Définir les permissions
chmod 600 ~/.ssh/oracle_cloud_key
```

### 3.2 Tester la connexion SSH

Remplacez `<IP_PUBLIQUE>` par l'IP de votre VM :

```bash
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
```

**Exemple :**
```bash
ssh -i ~/.ssh/oracle_cloud_key ubuntu@132.145.123.45
```

Si la connexion fonctionne, vous verrez :
```
Welcome to Ubuntu 22.04 LTS
```

---

## 📝 ÉTAPE 4 : Configurer l'inventaire Ansible

Éditez le fichier `inventory.ini` :

```ini
[oracle_cloud]
oracle-vm ansible_host=<IP_PUBLIQUE> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/oracle_cloud_key

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

**Exemple avec une vraie IP :**
```ini
[oracle_cloud]
oracle-vm ansible_host=132.145.123.45 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/oracle_cloud_key
```

---

## 🚀 ÉTAPE 5 : Installer Ansible

### Sur Windows (via WSL2 - recommandé)

#### Installer WSL2 :
```powershell
wsl --install
```

#### Dans WSL2, installer Ansible :
```bash
sudo apt update
sudo apt install -y ansible
ansible --version
```

### Alternative : Via Python (Windows natif)

```powershell
# Installer Python si nécessaire
python --version

# Installer Ansible
pip install ansible

# Vérifier
ansible --version
```

---

## ⚡ ÉTAPE 6 : Déployer avec Ansible

### 6.1 Tester la connexion Ansible

```bash
ansible oracle_cloud -m ping
```

**Résultat attendu :**
```
oracle-vm | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 6.2 Exécuter le playbook de déploiement

```bash
ansible-playbook deploy.yml -i inventory.ini
```

**Ou si vous ciblez spécifiquement Oracle Cloud :**
```bash
ansible-playbook deploy.yml --limit oracle_cloud
```

### 6.3 Suivre l'exécution

Le playbook va :
1. ✅ Mettre à jour le système
2. ✅ Installer Docker et Docker Compose
3. ✅ Cloner votre repository GitHub
4. ✅ Lancer `docker-compose up -d`
5. ✅ Vérifier que l'application fonctionne

**Temps d'exécution estimé : 5-10 minutes**

---

## 🎯 ÉTAPE 7 : Accéder à votre application

Une fois le déploiement terminé, accédez à :

### Frontend :
```
http://<IP_PUBLIQUE>:3000
```

### API :
```
http://<IP_PUBLIQUE>:8080/api/health
```

**Exemple :**
- Frontend : http://132.145.123.45:3000
- API : http://132.145.123.45:8080/api/health

---

## 📊 Commandes utiles

### Voir les logs en temps réel
```bash
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
cd /opt/gestion-salles
docker-compose logs -f
```

### Redémarrer l'application
```bash
ansible-playbook deploy.yml --limit oracle_cloud --tags deploy
```

### Vérifier l'état des conteneurs
```bash
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
docker ps
```

---

## 🐛 Dépannage

### Erreur : "Permission denied (publickey)"
```bash
# Vérifier les permissions de la clé
chmod 600 ~/.ssh/oracle_cloud_key

# Tester la connexion SSH
ssh -vvv -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
```

### Erreur : "Connection timeout"
- Vérifiez que les **Security Lists** autorisent le port 22
- Vérifiez que l'IP publique est correcte
- Vérifiez que la VM est en état **Running**

### Les ports 3000/8080 ne sont pas accessibles
- Vérifiez les **Ingress Rules** dans Oracle Cloud
- Vérifiez le pare-feu Ubuntu : `sudo ufw status`

---

## 📸 Captures d'écran pour le livrable

Prenez des captures d'écran de :

1. ✅ **Exécution du playbook Ansible** :
   ```bash
   ansible-playbook deploy.yml --limit oracle_cloud
   ```

2. ✅ **Résultat final** : Message "DÉPLOIEMENT RÉUSSI !"

3. ✅ **Application accessible** :
   - Frontend dans le navigateur (http://<IP>:3000)
   - API health check (http://<IP>:8080/api/health)

4. ✅ **Docker ps** sur la VM :
   ```bash
   ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
   docker ps
   ```

---

## ✅ Livrable TP7

### Fichiers à rendre :
1. ✅ `deploy.yml` (playbook commenté)
2. ✅ `inventory.ini` (inventaire)
3. ✅ `ansible.cfg` (configuration)
4. ✅ Captures d'écran de l'exécution réussie
5. ✅ Ce guide `ORACLE_CLOUD_SETUP.md`

### Démonstration :
- Application accessible via l'IP publique Oracle Cloud
- Déploiement automatisé reproductible

---

## 🎉 Félicitations !

Vous avez maintenant :
- ✅ Une VM Oracle Cloud configurée
- ✅ Un déploiement automatisé avec Ansible
- ✅ Une application en production accessible publiquement
- ✅ Une infrastructure as code complète

**Bon courage pour votre TP !** 🚀

