import React from 'react';
import { Link } from 'react-router-dom';
import './HomePage.css';

const HomePage = () => {
  return (
    <div className="home-page">
      <div className="hero-section">
        <div className="hero-content">
          <h1 className="hero-title">Bienvenue sur Smart Delivery Gabon</h1>
          <p className="hero-subtitle">Votre partenaire de confiance pour la livraison rapide et sécurisée</p>
          
          <div className="hero-actions">
            <Link to="/send" className="btn btn-primary">
              <span className="btn-icon">📦</span>
              Envoyer un colis
            </Link>
            <Link to="/tracking" className="btn btn-secondary">
              <span className="btn-icon">🔍</span>
              Suivre un colis
            </Link>
          </div>
        </div>
      </div>

      <div className="features-section">
        <div className="container">
          <h2 className="section-title">Nos Services</h2>
          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">⚡</div>
              <h3>Livraison Express</h3>
              <p>Livraison rapide en 2 à 5 heures</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">📋</div>
              <h3>Livraison Standard</h3>
              <p>Livraison standard en 6 à 12 heures</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🌍</div>
              <h3>Livraison Inter-Communes</h3>
              <p>Livraison entre Libreville, Owendo et Akanda</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🔒</div>
              <h3>Sécurisé</h3>
              <p>Suivi en temps réel de vos colis</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HomePage;

