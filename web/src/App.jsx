import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Navbar from './components/Navbar';
import HomePage from './pages/HomePage';
import SendPackagePage from './pages/SendPackagePage';
import TrackingPage from './pages/TrackingPage';
import OrdersPage from './pages/OrdersPage';
import ProfilePage from './pages/ProfilePage';
import PrivacyPolicyPage from './pages/PrivacyPolicyPage';
import './App.css';

function App() {
  return (
    <Router>
      <div className="App">
        <Navbar />
        <main className="main-content">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/send" element={<SendPackagePage />} />
            <Route path="/tracking" element={<TrackingPage />} />
            <Route path="/orders" element={<OrdersPage />} />
            <Route path="/profile" element={<ProfilePage />} />
            <Route path="/politique-confidentialite" element={<PrivacyPolicyPage />} />
            <Route path="/politique-confidentialite.html" element={<PrivacyPolicyPage />} />
          </Routes>
        </main>
        <footer className="footer">
          <p>&copy; 2024 Smart Delivery Gabon. Tous droits réservés.</p>
          <p style={{ marginTop: '0.5rem' }}>
            <Link 
              to="/politique-confidentialite" 
              style={{ color: 'white', textDecoration: 'underline' }}
            >
              Politique de Confidentialité
            </Link>
          </p>
        </footer>
      </div>
    </Router>
  );
}

export default App;
