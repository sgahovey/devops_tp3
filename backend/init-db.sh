#!/bin/bash
# Script d'initialisation de la base de données pour Railway

# Attendre que PostgreSQL soit prêt
until pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER; do
  echo "En attente de PostgreSQL..."
  sleep 2
done

# Créer la base de données si elle n'existe pas
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || true

# Exécuter le script d'initialisation
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f /var/www/html/init.sql

echo "Base de données initialisée avec succès !"
