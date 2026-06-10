import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL!;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseKey);

// Fetch images for gallery
export async function fetchGalleryImages() {
  const { data } = await supabase
    .from('gallery_images')
    .select('*')
    .order('created_at', { ascending: false });
  return data;
}