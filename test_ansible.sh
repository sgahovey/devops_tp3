#!/bin/bash
# Script de test Ansible pour le TP7
# Vérifie que tout est correctement configuré avant le déploiement

echo "=========================================="
echo "🧪 TEST ANSIBLE - TP7"
echo "=========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1 : Vérifier qu'Ansible est installé
echo -n "1️⃣  Ansible installé... "
if command -v ansible &> /dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -n1)
    echo -e "${GREEN}✅ OK${NC} ($ANSIBLE_VERSION)"
else
    echo -e "${RED}❌ ERREUR${NC} - Ansible n'est pas installé"
    echo "   Installez-le avec : sudo apt install ansible (Linux) ou pip install ansible"
    exit 1
fi

# Test 2 : Vérifier que les fichiers existent
echo -n "2️⃣  Fichiers présents... "
FILES_OK=true
for file in deploy.yml inventory.ini ansible.cfg; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ $file manquant${NC}"
        FILES_OK=false
    fi
done
if [ "$FILES_OK" = true ]; then
    echo -e "${GREEN}✅ OK${NC}"
else
    exit 1
fi

# Test 3 : Vérifier la syntaxe du playbook
echo -n "3️⃣  Syntaxe deploy.yml... "
if ansible-playbook deploy.yml --syntax-check &> /dev/null; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${RED}❌ ERREUR${NC} - Syntaxe invalide"
    ansible-playbook deploy.yml --syntax-check
    exit 1
fi

# Test 4 : Vérifier l'inventaire
echo -n "4️⃣  Inventaire configuré... "
if ansible-inventory --list &> /dev/null; then
    HOST_COUNT=$(ansible-inventory --list | grep -c "ansible_host")
    if [ "$HOST_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ OK${NC} ($HOST_COUNT hôte(s))"
    else
        echo -e "${YELLOW}⚠️  AVERTISSEMENT${NC} - Aucun hôte configuré dans inventory.ini"
        echo "   Éditez inventory.ini et ajoutez l'IP de votre VM Oracle Cloud"
    fi
else
    echo -e "${RED}❌ ERREUR${NC} - Inventaire invalide"
    exit 1
fi

# Test 5 : Liste des hôtes
echo ""
echo "📋 Hôtes configurés :"
ansible all --list-hosts

# Test 6 : Suggérer le test de connexion
echo ""
echo "=========================================="
echo -e "${GREEN}✅ TESTS RÉUSSIS !${NC}"
echo "=========================================="
echo ""
echo "📝 Prochaines étapes :"
echo ""
echo "1️⃣  Tester la connexion aux hôtes :"
echo "   ${YELLOW}ansible all -m ping${NC}"
echo ""
echo "2️⃣  Exécuter le playbook en mode dry-run :"
echo "   ${YELLOW}ansible-playbook deploy.yml --check${NC}"
echo ""
echo "3️⃣  Déployer sur Oracle Cloud :"
echo "   ${YELLOW}ansible-playbook deploy.yml --limit oracle_cloud${NC}"
echo ""
echo "=========================================="

