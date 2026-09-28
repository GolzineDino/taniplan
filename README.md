# 🌾 TaniPlan – Perencana Kegiatan Tani Harian

SvelteKit + Supabase (Auth, Database, Storage) + Vercel.

## Fitur
- **Dashboard** – sapaan, progres hari ini, kegiatan terdekat, galeri foto
- **Daily Plan** – buat/hapus daftar kegiatan per tanggal (jenis + jam mulai/selesai)
- **To-Do List** – centang kegiatan selesai, tambah tugas cepat
- **Kegiatan Pertanian** – panduan menanam, menyiram, memupuk, menyiangi, kendali hama, memangkas, panen; bisa langsung dijadwalkan
- **Jadwal & Waktu** – garis waktu per jam
- **Catatan** – kondisi tanaman + foto opsional, bisa dihapus
- **Progress** – persentase hari ini, 7 hari, grafik, per jenis kegiatan
- **Forum Tanya Jawab** – halaman terpisah: pertanyaan (judul, deskripsi, foto opsional), jawaban, hapus milik sendiri

## 1. Siapkan Supabase
1. Buat proyek di https://supabase.com.
2. **SQL Editor** → tempel seluruh `supabase/schema.sql` → **Run** (tabel, RLS, bucket foto `taniplan-images`).
3. **Authentication → Providers → Email** aktif. Untuk uji cepat, matikan *Confirm email*.
4. **Project Settings → API**: salin **Project URL** dan **anon public key**.
5. Setelah deploy, isi **Authentication → URL Configuration → Site URL** dengan alamat Vercel Anda.

## 2. Jalankan lokal (opsional)
```bash
npm install
cp .env.example .env   # isi kedua variabel
npm run dev
```

## 3. Deploy ke Vercel
1. Ekstrak zip, upload isinya ke repository GitHub baru (jangan upload `.env`).
2. Vercel → **Add New → Project** → pilih repo (terdeteksi **SvelteKit**).
3. **Environment Variables**: `PUBLIC_SUPABASE_URL` dan `PUBLIC_SUPABASE_ANON_KEY`.
4. **Deploy**. Bila env diubah, lakukan **Redeploy**.

Atau dengan CLI: `npm i -g vercel && vercel --prod`.

## Catatan
- Data rencana dan catatan bersifat pribadi (RLS: hanya pemilik yang bisa baca/ubah/hapus).
- Foto dekorasi memakai URL Unsplash; ganti di `src/lib/data.js` bila ada yang tidak tampil.
- Panduan kegiatan di `src/lib/data.js` bersifat umum; sesuaikan dengan komoditas Anda.
