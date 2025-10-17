-- Script d'initialisation pour Railway
CREATE TABLE IF NOT EXISTS salles (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    capacite INTEGER NOT NULL,
    equipement TEXT,
    disponible BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer les données de test
INSERT INTO salles (nom, capacite, equipement, disponible) VALUES 
    ('Salle A101', 30, 'Projecteur, Tableau blanc', true),
    ('Salle B202', 50, 'Vidéoprojecteur, Micro', true),
    ('Salle C303', 20, 'Tableau interactif', false),
    ('Salle D404', 40, 'Système audio, Écran', true)
ON CONFLICT DO NOTHING;
