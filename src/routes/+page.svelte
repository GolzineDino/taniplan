<script>
  import { onMount } from 'svelte';
  import { supabase, today, fmtDate, uname } from '$lib/supabase';
  import { user, ready } from '$lib/auth';
  import { cats, photos } from '$lib/data';
  let acts = [];
  $: if ($user) load();
  async function load() { const { data } = await supabase.from('activities').select('*').eq('plan_date', today()).order('start_time', { nullsFirst: false }); acts = data || []; }
  async function toggle(a) { await supabase.from('activities').update({ done: !a.done }).eq('id', a.id); load(); }
  $: pct = acts.length ? Math.round((acts.filter((a) => a.done).length / acts.length) * 100) : 0;
  $: next = acts.filter((a) => !a.done);
  const hour = new Date().getHours();
  const greet = hour < 11 ? 'Selamat pagi' : hour < 15 ? 'Selamat siang' : hour < 18 ? 'Selamat sore' : 'Selamat malam';
  const feats = [['/plan', '📅', 'Daily Plan', 'Susun daftar kegiatan hari ini.'], ['/todo', '✅', 'To-Do List', 'Centang kegiatan yang selesai.'], ['/kegiatan', '🌱', 'Kegiatan Pertanian', 'Panduan tanam, siram, pupuk, panen.'], ['/jadwal', '⏰', 'Jadwal & Waktu', 'Lihat jam kegiatan dalam garis waktu.'], ['/catatan', '📝', 'Catatan', 'Catat kondisi tanaman lengkap foto.'], ['/progress', '📊', 'Progress', 'Pantau persentase kegiatan selesai.']];
</script>
<svelte:head><title>TaniPlan – Atur Kegiatan Tani Harian</title></svelte:head>
<section class="hero"><div class="sunb"></div>
  <div class="in"><div>
    <h1>{$user ? `${greet}, ${uname($user)}!` : 'Atur kegiatan tani, hari demi hari.'}</h1>
    <p>{$user ? fmtDate(today()) + ' · ' + (acts.length ? `${next.length} kegiatan menunggumu.` : 'Belum ada rencana hari ini.') : 'Rencanakan tanam, siram, pupuk, sampai panen. Catat kondisi tanaman dan lihat progresmu.'}</p>
    <a class="btn" href={$user ? '/plan' : '/login'}>{$user ? '+ Tambah rencana hari ini' : 'Mulai gratis'}</a>
  </div>
  <div class="ring" style="--p:{pct}"><div>{pct}%<small>selesai hari ini</small></div></div></div>
  <svg class="f" viewBox="0 0 1200 150" preserveAspectRatio="none" aria-hidden="true">
    <path d="M0 60 Q300 20 600 55 T1200 40 V150 H0Z" fill="#7cc242"/><path d="M0 85 Q300 50 600 80 T1200 70 V150 H0Z" fill="#4fae2e"/><path d="M0 112 Q300 84 600 108 T1200 98 V150 H0Z" fill="#2f8a3a"/><path d="M0 132 Q300 112 600 130 T1200 124 V150 H0Z" fill="#1d5a34"/>
  </svg>
</section>
<div class="ph-strip">{#each photos as p}<figure class="photo"><img src={p.src} alt={p.cap} loading="lazy" /><span>{p.cap}</span></figure>{/each}</div>
<div class="grid g2">
  <div><h2 style="margin-bottom:14px">Fitur utama</h2><div class="grid g3">{#each feats as [h, e, t, d]}<a class="feat" href={h}><span class="e">{e}</span><h3>{t}</h3><p>{d}</p></a>{/each}</div></div>
  <div><h2 style="margin-bottom:14px">Hari ini</h2>
    {#if !$user}<div class="empty">Masuk untuk melihat kegiatanmu.</div>
    {:else}{#each acts.slice(0, 6) as a}
      <div class="item" class:done={a.done} style="--c:{cats[a.category]?.color}"><button class="chk" class:on={a.done} on:click={() => toggle(a)} aria-label="Tandai selesai">{a.done ? '✓' : ''}</button><div class="t"><b>{cats[a.category]?.icon} {a.title}</b></div>{#if a.start_time}<span class="time">{a.start_time.slice(0, 5)}</span>{/if}</div>
    {:else}<div class="empty">Belum ada kegiatan. <a href="/plan">Buat rencana</a></div>{/each}{/if}
  </div>
</div>
