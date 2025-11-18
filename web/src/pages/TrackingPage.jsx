import React, { useState } from 'react';
import { packageService } from '../services/packageService';
import './TrackingPage.css';

const TrackingPage = () => {
  const [trackingNumber, setTrackingNumber] = useState('');
  const [packageData, setPackageData] = useState(null);
  const [isSearching, setIsSearching] = useState(false);
  const [error, setError] = useState('');

  const deliverySteps = [
    'En attente de collecte',
    'Ramassé par le transporteur',
    'En transit vers Libreville',
    'En transit vers l\'intérieur',
    'Prêt à la livraison',
    'En cours de livraison',
    'Livré',
    'Annulé',
  ];

  const handleSearch = async (e) => {
    e.preventDefault();
    const trackingNum = trackingNumber.trim().toUpperCase();
    
    if (!trackingNum) {
      setError('Veuillez entrer un numéro de suivi');
      return;
    }

    setIsSearching(true);
    setError('');
    setPackageData(null);

    try {
      const { data, error: searchError } = await packageService.getPackageByTrackingNumber(trackingNum);
      
      if (searchError) {
        throw searchError;
      }

      if (data) {
        setPackageData(data);
      } else {
        setError('Colis non trouvé. Vérifiez le numéro de suivi.');
      }
    } catch (err) {
      console.error('Erreur lors de la recherche:', err);
      setError('Erreur lors de la recherche. Veuillez réessayer.');
    } finally {
      setIsSearching(false);
    }
  };

  const getCurrentStepIndex = () => {
    if (!packageData) return 0;
    const status = packageData.status;
    const index = deliverySteps.indexOf(status);
    return index !== -1 ? index : 0;
  };

  return (
    <div className="tracking-page">
      <div className="page-header">
        <h1>Suivi de Colis</h1>
        <p>Entrez le numéro de suivi pour connaître le statut de votre colis</p>
      </div>

      <div className="tracking-container">
        <form onSubmit={handleSearch} className="search-form">
          <div className="search-input-group">
            <input
              type="text"
              value={trackingNumber}
              onChange={(e) => setTrackingNumber(e.target.value)}
              placeholder="Ex: SD-12345678"
              className="search-input"
            />
            <button 
              type="submit" 
              className="btn btn-primary search-btn"
              disabled={isSearching}
            >
              {isSearching ? 'Recherche...' : '🔍 Rechercher'}
            </button>
          </div>
        </form>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        {isSearching && (
          <div className="loading-message">
            Recherche en cours...
          </div>
        )}

        {packageData && (
          <div className="package-result">
            <div className="result-header">
              <h2>Colis: {packageData.tracking_number}</h2>
            </div>

            <div className="result-details">
              <div className="detail-row">
                <span className="detail-icon">📍</span>
                <div className="detail-content">
                  <strong>Départ:</strong>
                  <span>{packageData.pickup_address}</span>
                </div>
              </div>
              <div className="detail-row">
                <span className="detail-icon">🎯</span>
                <div className="detail-content">
                  <strong>Arrivée:</strong>
                  <span>{packageData.destination_address}</span>
                </div>
              </div>
              <div className="detail-row">
                <span className="detail-icon">📦</span>
                <div className="detail-content">
                  <strong>Type:</strong>
                  <span>{packageData.package_type}</span>
                </div>
              </div>
              <div className="detail-row">
                <span className="detail-icon">🚚</span>
                <div className="detail-content">
                  <strong>Statut Actuel:</strong>
                  <span className={`status-badge status-${packageData.status.toLowerCase().replace(/\s+/g, '-')}`}>
                    {packageData.status}
                  </span>
                </div>
              </div>
            </div>

            <div className="progress-section">
              <h3>Progression de la Livraison</h3>
              <div className="progress-timeline">
                {deliverySteps.map((step, index) => {
                  const currentStep = getCurrentStepIndex();
                  const isCompleted = index <= currentStep;
                  const isCurrent = index === currentStep;

                  return (
                    <div key={index} className={`timeline-step ${isCompleted ? 'completed' : ''} ${isCurrent ? 'current' : ''}`}>
                      <div className="step-indicator">
                        {isCompleted ? '✓' : '○'}
                      </div>
                      <div className="step-label">{step}</div>
                      {index < deliverySteps.length - 1 && (
                        <div className={`step-connector ${isCompleted ? 'completed' : ''}`}></div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default TrackingPage;







