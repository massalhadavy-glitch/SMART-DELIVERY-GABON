// Configuration Supabase pour Smart Delivery Gabon Web
import { createClient } from '@supabase/supabase-js';

// Utilise les variables d'environnement en production, valeurs par défaut en développement
const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || 'https://phrgdydqxhgfynhzeokq.supabase.co';
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBocmdkeWRxeGhnZnluaHplb2txIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1ODA0MTcsImV4cCI6MjA3NzE1NjQxN30.6dxOlrQQRVznxiTgL3x0LeezD-u5bftnTwEbcIjan3A';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);



