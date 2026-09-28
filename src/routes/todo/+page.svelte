<script>
  import { supabase, today, fmtDate } from '$lib/supabase';
  import { user } from '$lib/auth';
  import { cats } from '$lib/data';
  import Guard from '$lib/Guard.svelte';
  import Head from '$lib/Head.svelte';
  let list = [], quick = '';
  $: if ($user) load();
  async function load() { const { data } = await supabase.from('activities').select('*').eq('plan_date', today()).order('start_time', { nullsFirst: false }); list = data || []; }
  async function toggle(a) { await supabase.from('activities').update({ done: !a.done }).eq('id', a.id); load(); }
  async function add() { if (!quick.trim()) return; await supabase.from('activities').insert({ title: quick, category: 'lain', plan_date: today() }); quick = ''; load(); }
  async function del(a) { await supabase.from('activities').delete().eq('id', a.id); load(); }
  $: todo = list.filter((a) => !a.done); $: done = list.filter((a) => a.done);
</script>
<Head icon="✅" title="To-Do List" sub={'Centang kegiatan yang sudah selesai · ' + fmtDate(today())} />
<Guard>
  <form class="card" style="display:flex;gap:10px;margin-bottom:20px" on:submit|preventDefault={add}><input bind:value={quick} placeholder="Tambah tugas cepat, mis. Cek pompa air" /><button class="btn">Tambah</button></form>
  <h3 style="margin-bottom:10px">Belum selesai ({todo.length})</h3>
  {#each todo as a}<div class="item" style="--c:{cats[a.category]?.color}"><button class="chk" on:click={() => toggle(a)} aria-label="Selesai"></button><div class="t"><b>{cats[a.category]?.icon} {a.title}</b></div>{#if a.start_time}<span class="time">{a.start_time.slice(0,5)}</span>{/if}<button class="btn sm del" on:click={() => del(a)}>Hapus</button></div>
  {:else}<div class="empty">{list.length ? 'Semua kegiatan selesai. Mantap! 🎉' : 'Belum ada tugas hari ini.'}</div>{/each}
  {#if done.length}<h3 style="margin:22px 0 10px">Selesai ({done.length})</h3>
    {#each done as a}<div class="item done" style="--c:{cats[a.category]?.color}"><button class="chk on" on:click={() => toggle(a)} aria-label="Batalkan">✓</button><div class="t"><b>{a.title}</b></div><button class="btn sm del" on:click={() => del(a)}>Hapus</button></div>{/each}{/if}
</Guard>
