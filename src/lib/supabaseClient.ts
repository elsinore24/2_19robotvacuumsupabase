import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    storage: window.localStorage
  },
  global: {
    headers: {
      'X-Client-Info': 'robot-vacuum-price@1.0.0'
    }
  }
});

// Initialize connection and set up auth state listener
supabase.auth.onAuthStateChange((event, session) => {
  console.log('Auth state changed:', { event, session });
  
  if (event === 'SIGNED_OUT' || event === 'USER_DELETED') {
    console.log('User signed out, clearing local storage');
    localStorage.removeItem('supabase.auth.token');
  } else if (event === 'SIGNED_IN') {
    console.log('User signed in:', session?.user);
  }
}); 