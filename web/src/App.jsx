import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import HomePage from './pages/HomePage';
import SendPackagePage from './pages/SendPackagePage';
import TrackingPage from './pages/TrackingPage';
import OrdersPage from './pages/OrdersPage';
import ProfilePage from './pages/ProfilePage';
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
          </Routes>
        </main>
        <footer className="footer">
          <p>&copy; 2024 Smart Delivery Gabon. Tous droits réservés.</p>
        </footer>
      </div>
    </Router>
  );
}

export default App;
