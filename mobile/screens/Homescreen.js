import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

// Définissez les couleurs d'accentuation pour les boutons et titres
const ACCENT_COLOR = '#FFD700'; // Jaune Or
const SECONDARY_COLOR = '#FF6347'; // Rouge/Orange (couleur du bouton)

// Le composant reçoit l'objet 'navigation' de React Navigation
export default function HomeScreen({ navigation }) {
  
  // Fonction appelée quand l'utilisateur appuie sur le bouton
  const handleStart = () => {
    // Actuellement, cela affichera un message d'alerte, 
    // mais plus tard, nous utiliserons 'navigation.navigate()'
    alert('Bouton Démarrer appuyé !'); 
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Prêt pour votre livraison ?</Text>
      
      {/* Bouton Démarrer */}
      <TouchableOpacity 
        style={styles.button}
        onPress={handleStart} // Lance l'action au clic
      >
        <Text style={styles.buttonText}>DÉMARRER</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff', // Fond blanc
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 40,
    color: ACCENT_COLOR,
  },
  button: {
    backgroundColor: SECONDARY_COLOR, 
    paddingVertical: 15,
    paddingHorizontal: 50,
    borderRadius: 8,
    elevation: 3, // Ombre (Android)
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});