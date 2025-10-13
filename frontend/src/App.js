import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

function App() {
  const [salles, setSalles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    nom: '',
    capacite: '',
    equipement: '',
    disponible: true
  });
  const [editingId, setEditingId] = useState(null);

  useEffect(() => {
    fetchSalles();
  }, []);

  const fetchSalles = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/salles`);
      setSalles(response.data);
      setError(null);
    } catch (err) {
      setError('Erreur lors du chargement des salles');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingId) {
        await axios.put(`${API_URL}/salles/${editingId}`, formData);
      } else {
        await axios.post(`${API_URL}/salles`, formData);
      }
      fetchSalles();
      resetForm();
    } catch (err) {
      setError('Erreur lors de la sauvegarde');
      console.error(err);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cette salle ?')) {
      try {
        await axios.delete(`${API_URL}/salles/${id}`);
        fetchSalles();
      } catch (err) {
        setError('Erreur lors de la suppression');
        console.error(err);
      }
    }
  };

  const handleEdit = (salle) => {
    setFormData({
      nom: salle.nom,
      capacite: salle.capacite,
      equipement: salle.equipement,
      disponible: salle.disponible
    });
    setEditingId(salle.id);
    setShowForm(true);
  };

  const resetForm = () => {
    setFormData({
      nom: '',
      capacite: '',
      equipement: '',
      disponible: true
    });
    setEditingId(null);
    setShowForm(false);
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? checked : value
    });
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🏢 Gestion des Salles</h1>
        <p>Système de gestion des salles de réunion</p>
      </header>

      <main className="container">
        <div className="actions">
          <button 
            className="btn btn-primary"
            onClick={() => setShowForm(!showForm)}
          >
            {showForm ? '❌ Annuler' : '➕ Nouvelle Salle'}
          </button>
        </div>

        {error && (
          <div className="alert alert-error">
            {error}
          </div>
        )}

        {showForm && (
          <div className="card form-card">
            <h2>{editingId ? 'Modifier la salle' : 'Nouvelle salle'}</h2>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label htmlFor="nom">Nom de la salle *</label>
                <input
                  type="text"
                  id="nom"
                  name="nom"
                  value={formData.nom}
                  onChange={handleChange}
                  required
                  placeholder="Ex: Salle A101"
                />
              </div>

              <div className="form-group">
                <label htmlFor="capacite">Capacité *</label>
                <input
                  type="number"
                  id="capacite"
                  name="capacite"
                  value={formData.capacite}
                  onChange={handleChange}
                  required
                  min="1"
                  placeholder="Ex: 30"
                />
              </div>

              <div className="form-group">
                <label htmlFor="equipement">Équipement</label>
                <textarea
                  id="equipement"
                  name="equipement"
                  value={formData.equipement}
                  onChange={handleChange}
                  placeholder="Ex: Projecteur, Tableau blanc..."
                  rows="3"
                />
              </div>

              <div className="form-group checkbox-group">
                <label>
                  <input
                    type="checkbox"
                    name="disponible"
                    checked={formData.disponible}
                    onChange={handleChange}
                  />
                  <span>Salle disponible</span>
                </label>
              </div>

              <div className="form-actions">
                <button type="submit" className="btn btn-success">
                  {editingId ? '💾 Modifier' : '✅ Créer'}
                </button>
                <button type="button" className="btn btn-secondary" onClick={resetForm}>
                  Annuler
                </button>
              </div>
            </form>
          </div>
        )}

        {loading ? (
          <div className="loading">
            <div className="spinner"></div>
            <p>Chargement des salles...</p>
          </div>
        ) : (
          <div className="salles-grid">
            {salles.length === 0 ? (
              <div className="empty-state">
                <p>Aucune salle disponible</p>
                <p>Cliquez sur "Nouvelle Salle" pour commencer</p>
              </div>
            ) : (
              salles.map((salle) => (
                <div key={salle.id} className={`card salle-card ${salle.disponible ? 'disponible' : 'indisponible'}`}>
                  <div className="salle-header">
                    <h3>{salle.nom}</h3>
                    <span className={`badge ${salle.disponible ? 'badge-success' : 'badge-danger'}`}>
                      {salle.disponible ? '✓ Disponible' : '✗ Occupée'}
                    </span>
                  </div>
                  <div className="salle-body">
                    <p className="capacite">
                      <strong>👥 Capacité:</strong> {salle.capacite} personnes
                    </p>
                    {salle.equipement && (
                      <p className="equipement">
                        <strong>🔧 Équipement:</strong> {salle.equipement}
                      </p>
                    )}
                  </div>
                  <div className="salle-actions">
                    <button 
                      className="btn btn-sm btn-info"
                      onClick={() => handleEdit(salle)}
                    >
                      ✏️ Modifier
                    </button>
                    <button 
                      className="btn btn-sm btn-danger"
                      onClick={() => handleDelete(salle.id)}
                    >
                      🗑️ Supprimer
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </main>

      <footer className="App-footer">
        <p>© 2025 - TP3 DevOps - Gestion des Salles</p>
      </footer>
    </div>
  );
}

export default App;


