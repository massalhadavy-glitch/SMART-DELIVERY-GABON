import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
// CODE CORRECT (Selon la documentation et l'installation standard)
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Importer le nouvel écran que nous venons de créer
import HomeScreen from './screens/HomeScreen';

// Crée l'objet pour la pile de navigation
const Stack = createNativeStackNavigator();

export default function App() {
  return (
    // Le conteneur obligatoire pour toute la navigation
    <NavigationContainer>
      
      {/* La Pile des Écrans, qui gère le passage d'une page à l'autre */}
      <Stack.Navigator 
        initialRouteName="Home" // L'écran de départ est 'Home'
        screenOptions={{
          headerStyle: { backgroundColor: '#FFD700' }, // Barre de titre (Jaune Or)
          headerTintColor: '#201A1B', // Couleur du texte de la barre (Sombre)
          headerTitleStyle: { fontWeight: 'bold' },
        }}
      >
        {/* Définition de l'écran d'accueil avec le bouton 'Démarrer' */}
        <Stack.Screen 
          name="Home" 
          component={HomeScreen} 
          options={{ title: 'Nouvelle Livraison' }} // Titre affiché en haut de l'écran
        />
        
        {/* Les futures pages (Géolocalisation, Paiement) seront ajoutées ici */}

      </Stack.Navigator>
    </NavigationContainer>
  );
}