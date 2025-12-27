// Service pour gérer les colis avec Supabase
import { supabase } from '../config/supabase';

export const packageService = {
  // Créer un nouveau colis
  async createPackage(packageData) {
    try {
      const { data, error } = await supabase
        .from('packages')
        .insert([packageData])
        .select()
        .single();

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Erreur lors de la création du colis:', error);
      return { data: null, error };
    }
  },

  // Récupérer un colis par numéro de suivi
  async getPackageByTrackingNumber(trackingNumber) {
    try {
      const { data, error } = await supabase
        .from('packages')
        .select('*')
        .eq('tracking_number', trackingNumber)
        .single();

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Erreur lors de la récupération du colis:', error);
      return { data: null, error };
    }
  },

  // Récupérer tous les colis d'un client par numéro de téléphone
  async getPackagesByPhone(phoneNumber) {
    try {
      const { data, error } = await supabase
        .from('packages')
        .select('*')
        .eq('client_phone_number', phoneNumber)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Erreur lors de la récupération des colis:', error);
      return { data: null, error };
    }
  },

  // Récupérer tous les colis (pour admin)
  async getAllPackages() {
    try {
      const { data, error } = await supabase
        .from('packages')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Erreur lors de la récupération des colis:', error);
      return { data: null, error };
    }
  },

  // Mettre à jour le statut d'un colis
  async updatePackageStatus(packageId, newStatus) {
    try {
      const { data, error } = await supabase
        .from('packages')
        .update({ status: newStatus })
        .eq('id', packageId)
        .select()
        .single();

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Erreur lors de la mise à jour du colis:', error);
      return { data: null, error };
    }
  },
};



















