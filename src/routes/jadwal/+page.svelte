<script>
  import { supabase, today, fmtDate, pad } from '$lib/supabase';
  import { user } from '$lib/auth';
  import { cats } from '$lib/data';
  import Guard from '$lib/Guard.svelte';
  import Head from '$lib/Head.svelte';
  let date = today(), list = [];
  const hours = Array.from({ length: 18 }, (_, i) => i + 4);
  $: if ($user && date) load();
  async function load() { const { data } = await supabase.from('activities').select('*').eq('plan_date', date).order('start_time'); list = data || []; }
  $: unscheduled = list.filter((a) => !a.start_time);
  const at = (h) => list.filter((a) => a.start_time && +a.start_time.slice(0, 2) === h);
</script>
<Head icon="⏰" title="Jadwal & Waktu" sub="Garis waktu kegiatanmu dari pagi sampai malam." />
<Guard>
  <div style="display:flex;gap:12px;align-items:center;margin-bottom:18px;flex-wrap:wrap"><input type="date" bind:value={date} style="max-width:200px" /><b>{fmtDate(date)}</b></div>
  <div class="card tl">
    {#each hours as h}<div class="h"><i>{pad(h)}:00</i>{#each at(h) as a}<div class="blk" style="--c:{cats[a.category]?.color}">{cats[a.category]?.icon} {a.title}<small>{a.start_time.slice(0,5)}{a.end_time ? ' – ' + a.end_time.slice(0,5) : ''}{a.done ? ' · ✓ selesai' : ''}</small></div>{/each}</div>{/each}
  </div>
  {#if unscheduled.length}<div class="card" style="margin-top:16px"><h3>Tanpa jam</h3>{#each unscheduled as a}<p>{cats[a.category]?.icon} {a.title}</p>{/each}</div>{/if}
</Guard>
