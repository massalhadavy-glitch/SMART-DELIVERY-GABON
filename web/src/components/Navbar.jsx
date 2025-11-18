import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import './Navbar.css';

const Navbar = () => {
  const location = useLocation();

  const isActive = (path) => location.pathname === path;

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <Link to="/" className="navbar-logo">
          <span className="logo-icon">🚚</span>
          <span className="logo-text">Smart Delivery Gabon</span>
        </Link>
        
        <ul className="navbar-menu">
          <li>
            <Link 
              to="/" 
              className={`navbar-link ${isActive('/') ? 'active' : ''}`}
            >
              Accueil
            </Link>
          </li>
          <li>
            <Link 
              to="/send" 
              className={`navbar-link ${isActive('/send') ? 'active' : ''}`}
            >
              Envoyer un colis
            </Link>
          </li>
          <li>
            <Link 
              to="/tracking" 
              className={`navbar-link ${isActive('/tracking') ? 'active' : ''}`}
            >
              Suivi
            </Link>
          </li>
          <li>
            <Link 
              to="/orders" 
              className={`navbar-link ${isActive('/orders') ? 'active' : ''}`}
            >
              Mes colis
            </Link>
          </li>
          <li>
            <Link 
              to="/profile" 
              className={`navbar-link ${isActive('/profile') ? 'active' : ''}`}
            >
              Profil
            </Link>
          </li>
        </ul>
      </div>
    </nav>
  );
};

export default Navbar;







