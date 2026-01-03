import React, { useState } from 'react';
import { packageService } from '../services/packageService';
import { sendNotificationToAdmin } from '../services/notificationService';
import './SendPackagePage.css';

const SendPackagePage = () => {
  const [formData, setFormData] = useState({
    senderName: '',
    senderPhone: '',
    recipientName: '',
    recipientPhone: '',
    pickupAddress: '',
    destinationAddress: '',
    packageType: '',
    deliveryType: '',
    paymentMethod: '',
  });

  const [cost, setCost] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [trackingNumber, setTrackingNumber] = useState('');

  const deliveryCosts = {
    'Livraison standard (2H à 6h)': 2000,
    'Livraison express (30min à 2h)': 3000,
    'Livraison LBV-Owendo': 3000,
    'Livraison LBV-Akanda': 3000,
    'Livraison AKANDA-Owendo': 3500,
  };

  const deliveryTypes = [
    'Livraison standard (2H à 6h)',
    'Livraison express (30min à 2h)',
    'Livraison LBV-Owendo',
    'Livraison LBV-Akanda',
    'Livraison AKANDA-Owendo',
  ];

  const paymentMethods = ['Airtel Money', 'Paiement à la livraison'];

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));

    if (name === 'deliveryType') {
      setCost(deliveryCosts[value] || 0);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    // Vérifier si Airtel Money est sélectionné
    if (formData.paymentMethod === 'Airtel Money') {
      alert('Le service Airtel Money n\'est pas encore disponible');
      setIsSubmitting(false);
      return;
    }

    const trackingNum = `SD-${Date.now().toString().slice(-8)}`;

    const packageData = {
      tracking_number: trackingNum,
      sender_name: formData.senderName,
      sender_phone: formData.senderPhone,
      client_phone_number: formData.senderPhone,
      recipient_name: formData.recipientName,
      recipient_phone: formData.recipientPhone,
      pickup_address: formData.pickupAddress,
      destination_address: formData.destinationAddress,
      package_type: formData.packageType,
      delivery_type: formData.deliveryType,
      status: 'En attente de collecte',
      cost: cost,
    };

    try {
      const { data, error } = await packageService.createPackage(packageData);

      if (error) {
        throw error;
      }

      setTrackingNumber(trackingNum);
      setShowSuccess(true);
      
      // Envoyer la notification WhatsApp à l'administrateur
      try {
        await sendNotificationToAdmin({
          trackingNumber: trackingNum,
          pickupAddress: formData.pickupAddress,
          destinationAddress: formData.destinationAddress,
          packageType: formData.packageType,
          deliveryType: formData.deliveryType,
          totalCost: cost,
          customerPhone: formData.senderPhone,
          customerName: formData.senderName,
          recipientName: formData.recipientName,
          recipientPhone: formData.recipientPhone,
          paymentMethod: formData.paymentMethod,
        });
        console.log('✅ Notification envoyée à l\'administrateur');
      } catch (notificationError) {
        console.error('⚠️ Erreur lors de l\'envoi de la notification:', notificationError);
        // Ne pas bloquer la soumission si la notification échoue
      }
      
      // Réinitialiser le formulaire
      setFormData({
        senderName: '',
        senderPhone: '',
        recipientName: '',
        recipientPhone: '',
        pickupAddress: '',
        destinationAddress: '',
        packageType: '',
        deliveryType: '',
        paymentMethod: '',
      });
      setCost(0);
    } catch (error) {
      console.error('Erreur lors de la soumission:', error);
      alert('Erreur lors de la soumission. Veuillez réessayer.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (showSuccess) {
    return (
      <div className="send-package-page">
        <div className="success-modal">
          <div className="success-content">
            <div className="success-icon">✅</div>
            <h2>Commande validée !</h2>
            <p>Votre commande a été enregistrée avec succès !</p>
            <div className="tracking-box">
              <p className="tracking-label">Votre numéro de suivi</p>
              <p className="tracking-number">{trackingNumber}</p>
            </div>
            <p className="warning-text">
              ⚠️ Veuillez relever votre numéro de suivi pour suivre votre colis.
            </p>
            <button 
              className="btn btn-primary" 
              onClick={() => {
                setShowSuccess(false);
                setTrackingNumber('');
              }}
            >
              Retour au formulaire
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="send-package-page">
      <div className="page-header">
        <h1>Envoyer un Colis</h1>
        <p>Remplissez le formulaire ci-dessous pour envoyer un colis</p>
      </div>

      <form onSubmit={handleSubmit} className="package-form">
        <div className="form-section">
          <h2>Informations Expéditeur</h2>
          <div className="form-grid">
            <div className="form-group">
              <label>Nom de l'expéditeur *</label>
              <input
                type="text"
                name="senderName"
                value={formData.senderName}
                onChange={handleChange}
                required
              />
            </div>
            <div className="form-group">
              <label>Téléphone de l'expéditeur *</label>
              <input
                type="tel"
                name="senderPhone"
                value={formData.senderPhone}
                onChange={handleChange}
                required
              />
            </div>
          </div>
        </div>

        <div className="form-section">
          <h2>Informations Destinataire</h2>
          <div className="form-grid">
            <div className="form-group">
              <label>Nom du destinataire *</label>
              <input
                type="text"
                name="recipientName"
                value={formData.recipientName}
                onChange={handleChange}
                required
              />
            </div>
            <div className="form-group">
              <label>Téléphone du destinataire *</label>
              <input
                type="tel"
                name="recipientPhone"
                value={formData.recipientPhone}
                onChange={handleChange}
                required
              />
            </div>
          </div>
        </div>

        <div className="form-section">
          <h2>Adresses</h2>
          <div className="form-grid">
            <div className="form-group">
              <label>Adresse de départ *</label>
              <input
                type="text"
                name="pickupAddress"
                value={formData.pickupAddress}
                onChange={handleChange}
                required
              />
            </div>
            <div className="form-group">
              <label>Adresse de destination *</label>
              <input
                type="text"
                name="destinationAddress"
                value={formData.destinationAddress}
                onChange={handleChange}
                required
              />
            </div>
          </div>
        </div>

        <div className="form-section">
          <h2>Détails du Colis</h2>
          <div className="form-grid">
            <div className="form-group">
              <label>Nature du colis *</label>
              <input
                type="text"
                name="packageType"
                value={formData.packageType}
                onChange={handleChange}
                placeholder="Ex: Documents, Vêtements, etc."
                required
              />
            </div>
            <div className="form-group">
              <label>Type de livraison *</label>
              <select
                name="deliveryType"
                value={formData.deliveryType}
                onChange={handleChange}
                required
              >
                <option value="">Sélectionnez un type</option>
                {deliveryTypes.map(type => (
                  <option key={type} value={type}>{type}</option>
                ))}
              </select>
            </div>
          </div>
        </div>

        <div className="form-section">
          <div className="form-group">
            <label>Mode de paiement *</label>
            <select
              name="paymentMethod"
              value={formData.paymentMethod}
              onChange={handleChange}
              required
            >
              <option value="">Sélectionnez un mode de paiement</option>
              {paymentMethods.map(method => (
                <option key={method} value={method}>{method}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="cost-display">
          <h3>Coût: {cost.toLocaleString()} FCFA</h3>
        </div>

        <button 
          type="submit" 
          className="btn btn-primary btn-submit"
          disabled={isSubmitting}
        >
          {isSubmitting ? 'Envoi en cours...' : 'Soumettre'}
        </button>
      </form>
    </div>
  );
};

export default SendPackagePage;

