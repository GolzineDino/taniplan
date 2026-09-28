<script>
  import { supabase, today, fmtDate } from '$lib/supabase';
  import { user } from '$lib/auth';
  import { cats } from '$lib/data';
  import Guard from '$lib/Guard.svelte';
  import Head from '$lib/Head.svelte';
  let date = today(), title = '', category = 'tanam', start = '06:00', end = '', list = [], error = '';
  $: if ($user && date) load();
  async function load() { const { data } = await supabase.from('activities').select('*').eq('plan_date', date).order('start_time', { nullsFirst: false }); list = data || []; }
  async function add() {
    error = '';
    const { error: e } = await supabase.from('activities').insert({ title, category, plan_date: date, start_time: start || null, end_time: end || null });
    if (e) error = e.message; else { title = ''; load(); }
  }
  async function del(a) { await supabase.from('activities').delete().eq('id', a.id); load(); }
</script>
<Head icon="📅" title="Daily Plan" sub="Susun daftar kegiatan untuk hari yang kamu pilih." />
<Guard><div class="grid g2">
  <div>
    <h2 style="margin-bottom:12px">{fmtDate(date)}</h2>
    {#each list as a}
      <div class="item" style="--c:{cats[a.category]?.color}"><div class="t"><b>{cats[a.category]?.icon} {a.title}</b><span class="m">{cats[a.category]?.label}{a.done ? ' · selesai' : ''}</span></div>
        {#if a.start_time}<span class="time">{a.start_time.slice(0,5)}{a.end_time ? '–' + a.end_time.slice(0,5) : ''}</span>{/if}
        <button class="btn sm del" on:click={() => del(a)}>Hapus</button></div>
    {:else}<div class="empty">Belum ada kegiatan di tanggal ini. Tambah lewat formulir 🌾</div>{/each}
  </div>
  <form class="card" on:submit|preventDefault={add}>
    <h3>Tambah kegiatan</h3>
    <label for="d">Tanggal</label><input id="d" type="date" bind:value={date} required />
    <label for="t">Kegiatan</label><input id="t" bind:value={title} required placeholder="mis. Siram bedengan cabai" />
    <label for="c">Jenis</label><select id="c" bind:value={category}>{#each Object.entries(cats) as [k, c]}<option value={k}>{c.icon} {c.label}</option>{/each}</select>
    <div class="row"><div><label for="s">Mulai</label><input id="s" type="time" bind:value={start} /></div><div><label for="n">Selesai</label><input id="n" type="time" bind:value={end} /></div></div>
    {#if error}<div class="err">{error}</div>{/if}
    <button class="btn" style="margin-top:16px">Simpan ke rencana</button>
  </form>
</div></Guard>
