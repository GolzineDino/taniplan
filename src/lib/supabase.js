import { createClient } from '@supabase/supabase-js';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';
export const supabase = createClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY);
export const BUCKET = 'taniplan-images';
export const pad = (n) => String(n).padStart(2, '0');
export const iso = (d) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
export const today = () => iso(new Date());
export const fmtDate = (s) => new Date(s + 'T00:00:00').toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long' });
export const ago = (d) => {
  const s = (Date.now() - new Date(d)) / 1000;
  if (s < 60) return 'baru saja'; if (s < 3600) return Math.floor(s / 60) + ' menit lalu';
  if (s < 86400) return Math.floor(s / 3600) + ' jam lalu';
  return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
};
export const uname = (u) => u?.user_metadata?.username || u?.email?.split('@')[0] || 'petani';
export async function uploadImage(file, uid) {
  if (file.size > 5 * 1024 * 1024) throw new Error('Ukuran foto maksimal 5 MB.');
  const path = `${uid}/${Date.now()}-${file.name.replace(/[^\w.-]/g, '_')}`;
  const { error } = await supabase.storage.from(BUCKET).upload(path, file);
  if (error) throw new Error('Gagal mengunggah foto: ' + error.message);
  return { path, url: supabase.storage.from(BUCKET).getPublicUrl(path).data.publicUrl };
}
