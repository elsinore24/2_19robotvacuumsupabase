import { supabase } from './supabaseClient';

export async function searchRobotVacuums(params: {
  keywords?: string;
  brand?: string;
  minPrice?: number;
  maxPrice?: number;
  sortBy?: string;
}) {
  try {
    const { data: { session } } = await supabase.auth.getSession();
    
    const response = await fetch('/api/amazon-pa-api?' + new URLSearchParams({
      ...params,
      keywords: params.keywords || 'robot vacuum'
    }), {
      headers: {
        'Authorization': `Bearer ${session?.access_token}`,
      }
    });

    if (!response.ok) {
      throw new Error('Failed to fetch robot vacuums');
    }

    return await response.json();
  } catch (error) {
    console.error('Error fetching robot vacuums:', error);
    throw error;
  }
}