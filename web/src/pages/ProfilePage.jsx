import React from 'react';
import './ProfilePage.css';

const ProfilePage = () => {
  return (
    <div className="profile-page">
      <div className="page-header">
        <h1>Mon Profil</h1>
      </div>

      <div className="profile-container">
        <div className="profile-card">
          <div className="profile-avatar">
            <span className="avatar-icon">👤</span>
          </div>
          <h2>Utilisateur</h2>
          <p className="profile-email">Bienvenue sur Smart Delivery Gabon</p>
          
          <div className="profile-info">
            <div className="info-item">
              <strong>Statut:</strong>
              <span>Visiteur</span>
            </div>
            <div className="info-item">
              <strong>Services disponibles:</strong>
              <span>Envoi de colis, Suivi, Consultation</span>
            </div>
          </div>

          <div className="profile-actions">
            <button className="btn btn-secondary">
              Modifier le profil
            </button>
            <button className="btn btn-outline">
              Se déconnecter
            </button>
          </div>

          <div className="profile-danger-zone" style={{ marginTop: '30px', padding: '20px', backgroundColor: '#fff3cd', borderRadius: '8px', border: '2px solid #ffc107' }}>
            <h3 style={{ color: '#856404', marginBottom: '15px', display: 'flex', alignItems: 'center' }}>
              <span style={{ marginRight: '8px' }}>⚠️</span>
              Demande de Suppression de Données
            </h3>
            <p style={{ color: '#856404', marginBottom: '15px' }}>
              Vous pouvez demander la suppression de votre compte et de toutes vos données associées.
            </p>
            <a 
              href="/demande-suppression-donnees.html" 
              target="_blank" 
              rel="noopener noreferrer"
              className="btn"
              style={{ 
                backgroundColor: '#ff9800', 
                color: 'white', 
                textDecoration: 'none',
                display: 'inline-block',
                padding: '10px 20px',
                borderRadius: '5px',
                fontWeight: 'bold'
              }}
            >
              Demander la suppression de mes données
            </a>
            <p style={{ color: '#856404', fontSize: '0.9em', marginTop: '10px' }}>
              Cette action est irréversible. Toutes vos données seront définitivement supprimées.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;



















