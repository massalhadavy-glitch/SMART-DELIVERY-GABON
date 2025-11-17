// Service d'authentification avec Supabase
import { supabase } from '../config/supabase';

export const authService = {
  // Vérifier si un utilisateur est admin
  async checkAdminRole(userId) {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('role')
        .eq('id', userId)
        .single();

      if (error) throw error;
      return data?.role === 'admin';
    } catch (error) {
      console.error('Erreur lors de la vérification du rôle:', error);
      return false;
    }
  },

  // Connexion avec numéro de téléphone (simplifié pour les visiteurs)
  async loginWithPhone(phoneNumber) {
    // Pour les visiteurs, on ne fait qu'une vérification simple
    // L'authentification complète peut être ajoutée plus tard
    return { success: true, phone: phoneNumber };
  },

  // Obtenir l'utilisateur actuel
  async getCurrentUser() {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      return user;
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'utilisateur:', error);
      return null;
    }
  },

  // Déconnexion
  async logout() {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      return { success: true };
    } catch (error) {
      console.error('Erreur lors de la déconnexion:', error);
      return { success: false, error };
    }
  },
};






