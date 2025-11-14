import React, { useState, useEffect } from 'react';
import { packageService } from '../services/packageService';
import './OrdersPage.css';

const OrdersPage = () => {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [packages, setPackages] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSearch = async (e) => {
    e.preventDefault();
    const phone = phoneNumber.trim();
    
    if (!phone) {
      setError('Veuillez entrer votre numéro de téléphone');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const { data, error: searchError } = await packageService.getPackagesByPhone(phone);
      
      if (searchError) {
        throw searchError;
      }

      setPackages(data || []);
      
      if (!data || data.length === 0) {
        setError('Aucun colis trouvé pour ce numéro de téléphone');
      }
    } catch (err) {
      console.error('Erreur lors de la recherche:', err);
      setError('Erreur lors de la recherche. Veuillez réessayer.');
      setPackages([]);
    } finally {
      setIsLoading(false);
    }
  };

  const getStatusColor = (status) => {
    if (status === 'Livré') return '#4caf50';
    if (status === 'Annulé') return '#f44336';
    if (status.includes('En cours')) return '#ff9800';
    return '#2196f3';
  };

  return (
    <div className="orders-page">
      <div className="page-header">
        <h1>Mes Colis</h1>
        <p>Entrez votre numéro de téléphone pour voir vos colis</p>
      </div>

      <div className="orders-container">
        <form onSubmit={handleSearch} className="search-form">
          <div className="search-input-group">
            <input
              type="tel"
              value={phoneNumber}
              onChange={(e) => setPhoneNumber(e.target.value)}
              placeholder="Ex: 06xxxxxxx ou 074xxxxxx"
              className="search-input"
            />
            <button 
              type="submit" 
              className="btn btn-primary search-btn"
              disabled={isLoading}
            >
              {isLoading ? 'Recherche...' : '🔍 Rechercher'}
            </button>
          </div>
        </form>

        {error && (
          <div className={`message ${error.includes('Aucun') ? 'info' : 'error'}`}>
            {error}
          </div>
        )}

        {isLoading && (
          <div className="loading-message">
            Recherche en cours...
          </div>
        )}

        {packages.length > 0 && (
          <div className="packages-list">
            <h2>{packages.length} colis trouvé(s)</h2>
            <div className="packages-grid">
              {packages.map((pkg) => (
                <div key={pkg.id} className="package-card">
                  <div className="package-header">
                    <h3>{pkg.tracking_number}</h3>
                    <span 
                      className="status-badge"
                      style={{ backgroundColor: getStatusColor(pkg.status) }}
                    >
                      {pkg.status}
                    </span>
                  </div>
                  
                  <div className="package-details">
                    <div className="detail-item">
                      <strong>De:</strong> {pkg.pickup_address}
                    </div>
                    <div className="detail-item">
                      <strong>Vers:</strong> {pkg.destination_address}
                    </div>
                    <div className="detail-item">
                      <strong>Type:</strong> {pkg.package_type}
                    </div>
                    <div className="detail-item">
                      <strong>Livraison:</strong> {pkg.delivery_type}
                    </div>
                    <div className="detail-item">
                      <strong>Coût:</strong> {pkg.cost?.toLocaleString()} FCFA
                    </div>
                    {pkg.created_at && (
                      <div className="detail-item">
                        <strong>Date:</strong> {new Date(pkg.created_at).toLocaleDateString('fr-FR')}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default OrdersPage;



