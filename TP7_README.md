# TP7 - OPERATE : Exploitation & Maintenance

## 🎯 Objectif

Automatiser le déploiement de l'application de gestion des salles via un playbook Ansible sur une VM Oracle Cloud.

---

## 📦 Contenu du projet

```
.
├── deploy.yml                 # Playbook Ansible principal
├── inventory.ini              # Inventaire des serveurs
├── ansible.cfg                # Configuration Ansible
├── ORACLE_CLOUD_SETUP.md      # Guide détaillé Oracle Cloud
├── TP7_README.md              # Ce fichier
└── docker-compose.yml         # Configuration Docker Compose
```

---

## 🚀 Déploiement rapide

### 1. Prérequis

- Compte Oracle Cloud (gratuit)
- Ansible installé sur votre machine
- Clé SSH configurée

### 2. Configuration

Éditez `inventory.ini` avec l'IP de votre VM :

```ini
[oracle_cloud]
oracle-vm ansible_host=<VOTRE_IP_PUBLIQUE> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/oracle_cloud_key
```

### 3. Test de connexion

```bash
ansible oracle_cloud -m ping
```

### 4. Déploiement

```bash
ansible-playbook deploy.yml --limit oracle_cloud
```

---

## 📋 Ce que fait le playbook

Le playbook `deploy.yml` automatise les tâches suivantes :

1. ✅ **Mise à jour du système** : `apt update`
2. ✅ **Installation de Docker** : Docker CE + Docker Compose
3. ✅ **Clone du repository** : `git clone` depuis GitHub
4. ✅ **Déploiement** : `docker-compose up -d`
5. ✅ **Vérification** : Health check de l'API
6. ✅ **Affichage des URLs** : Frontend et Backend

---

## 🌐 Accès à l'application

Après le déploiement, accédez à :

- **Frontend** : `http://<IP_PUBLIQUE>:3000`
- **Backend API** : `http://<IP_PUBLIQUE>:8080/api`
- **Health Check** : `http://<IP_PUBLIQUE>:8080/api/health`

---

## 📊 Commandes utiles

### Redéployer l'application

```bash
ansible-playbook deploy.yml --limit oracle_cloud
```

### Exécuter uniquement certaines étapes

```bash
# Seulement l'installation de Docker
ansible-playbook deploy.yml --limit oracle_cloud --tags docker

# Seulement le déploiement
ansible-playbook deploy.yml --limit oracle_cloud --tags deploy
```

### Voir les logs Ansible

```bash
tail -f ansible.log
```

### Se connecter à la VM

```bash
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
```

### Voir les conteneurs Docker

```bash
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
cd /opt/gestion-salles
docker-compose ps
docker-compose logs -f
```

---

## 🏗️ Architecture du déploiement

```
Oracle Cloud VM (Ubuntu 22.04)
├── Docker Engine
│   ├── Container PostgreSQL (port 5432)
│   ├── Container Backend PHP (port 8080)
│   └── Container Frontend React (port 3000)
├── /opt/gestion-salles (répertoire de l'application)
└── UFW Firewall (ports 22, 3000, 8080 ouverts)
```

---

## 📸 Captures d'écran requises

Pour le livrable, incluez :

1. **Exécution du playbook** : Terminal montrant `ansible-playbook deploy.yml`
2. **Résultat PLAY RECAP** : Statistiques d'exécution (ok, changed, failed)
3. **Frontend accessible** : Navigateur sur `http://<IP>:3000`
4. **API health check** : Navigateur sur `http://<IP>:8080/api/health`
5. **Docker containers** : `docker ps` montrant les 3 conteneurs

---

## 🐛 Dépannage

### Problème : "unreachable" lors du ping Ansible

**Solution :**
```bash
# Vérifier la clé SSH
chmod 600 ~/.ssh/oracle_cloud_key

# Tester SSH manuellement
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
```

### Problème : "Permission denied" pour Docker

**Solution :** Le playbook ajoute automatiquement l'utilisateur au groupe `docker`. Reconnectez-vous en SSH :
```bash
exit
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<IP_PUBLIQUE>
```

### Problème : Ports non accessibles

**Solution :** Vérifiez les Security Lists dans Oracle Cloud et le firewall Ubuntu :
```bash
sudo ufw status
sudo ufw allow 3000/tcp
sudo ufw allow 8080/tcp
```

---

## ✅ Critères de validation

- [ ] VM Oracle Cloud créée et accessible
- [ ] Ansible installé et fonctionnel
- [ ] Playbook `deploy.yml` commenté
- [ ] Déploiement réussi (tous les tasks en vert)
- [ ] Application accessible via IP publique
- [ ] Captures d'écran fournies
- [ ] Documentation complète

---

## 🎓 Compétences démontrées

- ✅ **Infrastructure as Code** : Ansible playbook
- ✅ **Cloud Computing** : Oracle Cloud (IaaS)
- ✅ **Automatisation** : Déploiement reproductible
- ✅ **DevOps** : CI/CD avec Ansible
- ✅ **Conteneurisation** : Docker + Docker Compose
- ✅ **Administration système** : Linux, SSH, Firewall

---

## 📚 Ressources

- [Documentation Ansible](https://docs.ansible.com/)
- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)
- [Docker Documentation](https://docs.docker.com/)
- [Guide Oracle Cloud détaillé](./ORACLE_CLOUD_SETUP.md)

---

## 👨‍💻 Auteur

**Projet** : Gestion des Salles  
**TP** : TP7 - OPERATE  
**Date** : Octobre 2025  
**Repository** : https://github.com/sgahovey/devops_tp3

---

## 🎉 Conclusion

Vous avez maintenant une infrastructure complète :
- ✅ Code versionné (GitHub)
- ✅ Déploiement automatisé (Ansible)
- ✅ Application conteneurisée (Docker)
- ✅ Hébergement cloud (Oracle Cloud)
- ✅ Production accessible (IP publique)

**Félicitations pour votre travail !** 🚀

