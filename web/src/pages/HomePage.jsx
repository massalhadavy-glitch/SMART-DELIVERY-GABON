import React from 'react';
import { Link } from 'react-router-dom';
import './HomePage.css';

const HomePage = () => {
  return (
    <div className="home-page">
      <div className="hero-section">
        <div className="hero-content">
          <h1 className="hero-title">Bienvenue sur Smart Delivery Gabon</h1>
          <p className="hero-subtitle">Application de livraison de colis à Libreville</p>
          
          <div className="hero-actions">
            <Link to="/send" className="btn btn-primary">
              <span className="btn-icon">📦</span>
              Commander un livreur
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
              <p>Option de livraison rapide</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">📋</div>
              <h3>Livraison Standard</h3>
              <p>Option de livraison standard</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🌍</div>
              <h3>Livraison Inter-Communes</h3>
              <p>Livraison entre Libreville, Owendo et Akanda</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🔒</div>
              <h3>Sécurisé</h3>
              <p>Suivi de vos colis dans l'application</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HomePage;

