# 📊 TP8 - MONITOR : Supervision & Amélioration Continue

## 🎯 Objectif

Surveiller le système et collecter des métriques avec **Prometheus** et **Grafana**.

---

## 🏗️ Architecture de monitoring

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose                            │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  PostgreSQL  │    │  Backend PHP │    │ Frontend     │  │
│  │  Port: 5432  │◄───│  Port: 8080  │◄───│ React        │  │
│  └──────────────┘    └──────┬───────┘    │ Port: 3000   │  │
│                              │             └──────────────┘  │
│                              │ /metrics                      │
│                              ▼                               │
│  ┌──────────────────────────────────────────────────┐      │
│  │         Prometheus (Collecte métriques)          │      │
│  │         Port: 9090                               │      │
│  └──────────────────────┬───────────────────────────┘      │
│                         │                                   │
│                         ▼                                   │
│  ┌──────────────────────────────────────────────────┐      │
│  │         Grafana (Visualisation)                  │      │
│  │         Port: 3001                               │      │
│  │         Login: admin / admin                     │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │   Node Exporter (Métriques système: CPU/RAM)    │      │
│  │   Port: 9100                                     │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 **ÉTAPE 1 : Démarrer les services**

### 1.1 Arrêter les conteneurs existants

```bash
docker-compose down
```

### 1.2 Démarrer tous les services (avec Prometheus et Grafana)

```bash
docker-compose up -d
```

### 1.3 Vérifier que tous les conteneurs fonctionnent

```bash
docker-compose ps
```

**Vous devriez voir 6 conteneurs :**
- ✅ `gestion_salles_db` (PostgreSQL)
- ✅ `gestion_salles_backend` (Backend PHP)
- ✅ `gestion_salles_frontend` (Frontend React)
- ✅ `gestion_salles_prometheus` (Prometheus)
- ✅ `gestion_salles_grafana` (Grafana)
- ✅ `gestion_salles_node_exporter` (Node Exporter)

---

## 🔍 **ÉTAPE 2 : Vérifier les métriques**

### 2.1 Tester l'endpoint /metrics du backend

Ouvrez dans votre navigateur :
```
http://localhost:8080/api/metrics
```

**Résultat attendu :**
```
# HELP salles_total Nombre total de salles
# TYPE salles_total gauge
salles_total 4

# HELP salles_disponibles Nombre de salles disponibles
# TYPE salles_disponibles gauge
salles_disponibles 3

# HELP db_response_time_ms Temps de réponse de la base de données en millisecondes
# TYPE db_response_time_ms gauge
db_response_time_ms 2.5
```

### 2.2 Vérifier Prometheus

Ouvrez :
```
http://localhost:9090
```

1. Cliquez sur **"Status"** → **"Targets"**
2. Vérifiez que toutes les targets sont **UP** (vertes) :
   - ✅ `prometheus`
   - ✅ `node-exporter`
   - ✅ `backend`

---

## 📊 **ÉTAPE 3 : Configurer Grafana**

### 3.1 Accéder à Grafana

Ouvrez dans votre navigateur :
```
http://localhost:3001
```

**Connexion :**
- **Username** : `admin`
- **Password** : `admin`

(Grafana demandera de changer le mot de passe, vous pouvez cliquer "Skip" ou le changer)

### 3.2 Vérifier la datasource Prometheus

1. Menu **⚙️ Configuration** → **Data Sources**
2. Vous devriez voir **"Prometheus"** déjà configuré ✅
3. Cliquez sur **"Prometheus"** → **"Test"**
4. Résultat attendu : **"Data source is working"** ✅

### 3.3 Ouvrir les dashboards

1. Menu **📊 Dashboards** → **Browse**
2. Vous devriez voir :
   - ✅ **Gestion des Salles - Monitoring TP8** (métriques système)
   - ✅ **Gestion des Salles - Métriques Application** (métriques app)

---

## 📊 **ÉTAPE 4 : Comprendre les dashboards**

### **Dashboard 1 : Métriques Système**

**Affiche :**
- ✅ **CPU** : Utilisation du processeur (%)
- ✅ **Mémoire** : Utilisation de la RAM (%)
- ✅ **Uptime** : Temps depuis le démarrage
- ✅ **Disque** : Espace disque disponible
- ✅ **Réseau** : Trafic réseau entrant
- ✅ **Load Average** : Charge système

### **Dashboard 2 : Métriques Application**

**Affiche :**
- ✅ **Nombre total de salles** : Compteur
- ✅ **Salles disponibles** : Compteur
- ✅ **Salles non disponibles** : Compteur
- ✅ **Capacité totale** : Somme des capacités
- ✅ **Temps de réponse DB** : Latence de la base de données (ms)
- ✅ **Statut API** : UP/DOWN
- ✅ **CPU** : Jauge de l'utilisation
- ✅ **Mémoire** : Jauge de l'utilisation

---

## 🎨 **ÉTAPE 5 : Personnaliser le dashboard**

### 5.1 Ajouter un nouveau panneau

1. Dans un dashboard, cliquez sur **"Add panel"**
2. Sélectionnez **"Add a new panel"**
3. Dans **"Metrics browser"**, entrez une requête :
   - `salles_total` : Nombre de salles
   - `db_response_time_ms` : Temps de réponse
   - `node_memory_MemAvailable_bytes` : Mémoire disponible

### 5.2 Exemples de requêtes Prometheus

**Taux de changement des salles :**
```promql
rate(salles_total[5m])
```

**Pourcentage de salles disponibles :**
```promql
(salles_disponibles / salles_total) * 100
```

**Moyenne du temps de réponse sur 5 minutes :**
```promql
avg_over_time(db_response_time_ms[5m])
```

---

## 📸 **ÉTAPE 6 : Captures d'écran pour le livrable**

Prenez des captures d'écran de :

### 1️⃣ **Dashboard Grafana - Vue d'ensemble**
- Montrez le dashboard complet avec tous les panneaux
- Assurez-vous que les données s'affichent

### 2️⃣ **Métriques de l'application**
- Nombre de salles
- Temps de réponse de la base de données
- Statut de l'API

### 3️⃣ **Métriques système**
- CPU
- Mémoire
- Uptime

### 4️⃣ **Prometheus Targets**
- Allez sur http://localhost:9090/targets
- Montrez que toutes les targets sont UP

### 5️⃣ **Endpoint /metrics**
- http://localhost:8080/api/metrics
- Montrez les métriques brutes

---

## 📝 **ÉTAPE 7 : Tester l'impact des actions**

### Test 1 : Créer une nouvelle salle

1. Allez sur http://localhost:3000
2. Créez une nouvelle salle
3. Retournez sur Grafana
4. Le **"Nombre total de salles"** devrait augmenter

### Test 2 : Marquer une salle comme non disponible

1. Modifiez une salle et décochez "Disponible"
2. Sur Grafana :
   - **"Salles disponibles"** diminue
   - **"Salles non disponibles"** augmente

---

## 🛠️ **Commandes utiles**

### Redémarrer tous les services

```bash
docker-compose restart
```

### Voir les logs de Prometheus

```bash
docker-compose logs -f prometheus
```

### Voir les logs de Grafana

```bash
docker-compose logs -f grafana
```

### Accéder au shell de Prometheus

```bash
docker exec -it gestion_salles_prometheus sh
```

---

## 📊 **URLs importantes**

| Service | URL | Login |
|---------|-----|-------|
| **Application** | http://localhost:3000 | - |
| **API** | http://localhost:8080/api | - |
| **Métriques** | http://localhost:8080/api/metrics | - |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3001 | admin / admin |
| **Node Exporter** | http://localhost:9100/metrics | - |

---

## ✅ **Livrables TP8**

### Fichiers :
1. ✅ `docker-compose.yml` mis à jour (avec Prometheus et Grafana)
2. ✅ `monitoring/prometheus.yml` (configuration Prometheus)
3. ✅ `monitoring/grafana/provisioning/` (configuration Grafana)
4. ✅ `backend/index.php` (avec endpoint /metrics)

### Captures d'écran :
1. ✅ Dashboard Grafana - Vue générale
2. ✅ Métriques de l'application (nombre de salles, temps de réponse)
3. ✅ Métriques système (CPU, RAM)
4. ✅ Prometheus Targets (toutes UP)

---

## 🎯 **Métriques exposées**

### **Métriques application (backend) :**
- `salles_total` : Nombre total de salles
- `salles_disponibles` : Nombre de salles disponibles
- `salles_non_disponibles` : Nombre de salles non disponibles
- `salles_capacite_totale` : Capacité totale
- `db_response_time_ms` : Temps de réponse de la base de données
- `api_up` : Statut de l'API (1 = up, 0 = down)

### **Métriques système (node-exporter) :**
- CPU, RAM, Disque, Réseau, Load Average, etc.

---

## 🐛 **Dépannage**

### Problème : "No data" dans Grafana

**Solution :**
1. Vérifiez que Prometheus fonctionne : http://localhost:9090
2. Vérifiez les targets : http://localhost:9090/targets
3. Vérifiez l'endpoint metrics : http://localhost:8080/api/metrics

### Problème : Prometheus ne collecte pas les métriques du backend

**Solution :**
```bash
# Vérifier les logs
docker-compose logs prometheus

# Redémarrer Prometheus
docker-compose restart prometheus
```

### Problème : Grafana ne démarre pas

**Solution :**
```bash
# Vérifier les logs
docker-compose logs grafana

# Vérifier les permissions
sudo chown -R 472:472 monitoring/grafana
```

---

## 🎉 **Félicitations !**

Vous avez maintenant :
- ✅ Prometheus qui collecte les métriques
- ✅ Grafana qui visualise les données
- ✅ Dashboards pré-configurés
- ✅ Métriques customisées de votre application
- ✅ Métriques système (CPU, RAM, etc.)

**Votre système de monitoring est opérationnel !** 🚀

---

## 📚 **Documentation**

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)

