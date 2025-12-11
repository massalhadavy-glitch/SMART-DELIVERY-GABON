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
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;















