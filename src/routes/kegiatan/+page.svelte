<script>
  import { supabase, today } from '$lib/supabase';
  import { user } from '$lib/auth';
  import { cats, guide } from '$lib/data';
  import Head from '$lib/Head.svelte';
  let times = {}, msg = '';
  async function sched(k) {
    if (!$user) { msg = 'Masuk dulu untuk menjadwalkan kegiatan.'; return; }
    const { error } = await supabase.from('activities').insert({ title: cats[k].label, category: k, plan_date: today(), start_time: times[k] || null });
    msg = error ? error.message : `✅ ${cats[k].label} ditambahkan ke rencana hari ini.`;
  }
</script>
<Head icon="🌱" title="Kegiatan Pertanian" sub="Pilih kegiatan, baca panduan singkat, lalu jadwalkan untuk hari ini." />
{#if msg}<div class="okm" style="margin:0 0 16px">{msg}</div>{/if}
<div class="grid g3" style="grid-template-columns:repeat(auto-fill,minmax(310px,1fr))">
  {#each guide as g}
    <article class="gk" style="border-top:8px solid {cats[g.key].color}">
      <div class="top"><span class="e">{cats[g.key].icon}</span><h3>{cats[g.key].label}</h3></div>
      <p style="margin:10px 0;color:var(--muted)">{g.tip}</p>
      <ol>{#each g.steps as s}<li>{s}</li>{/each}</ol>
      <div style="display:flex;gap:8px;align-items:center"><input type="time" bind:value={times[g.key]} aria-label="Jam" style="max-width:130px" /><button class="btn sm" on:click={() => sched(g.key)}>+ Jadwalkan hari ini</button></div>
    </article>
  {/each}
</div>
