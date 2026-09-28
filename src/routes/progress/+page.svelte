<script>
  import { supabase, today, iso } from '$lib/supabase';
  import { user } from '$lib/auth';
  import { cats } from '$lib/data';
  import Guard from '$lib/Guard.svelte';
  import Head from '$lib/Head.svelte';
  let all = [];
  $: if ($user) load();
  const days = Array.from({ length: 7 }, (_, i) => { const d = new Date(); d.setDate(d.getDate() - (6 - i)); return d; });
  async function load() { const { data } = await supabase.from('activities').select('plan_date,category,done').gte('plan_date', iso(days[0])).lte('plan_date', today()); all = data || []; }
  const pc = (l) => (l.length ? Math.round((l.filter((a) => a.done).length / l.length) * 100) : 0);
  $: bars = days.map((d) => { const l = all.filter((a) => a.plan_date === iso(d)); return { d: d.toLocaleDateString('id-ID', { weekday: 'short' }), p: pc(l), t: iso(d) === today() }; });
  $: todayP = pc(all.filter((a) => a.plan_date === today()));
  $: weekP = pc(all);
  $: byCat = Object.entries(cats).map(([k, c]) => { const l = all.filter((a) => a.category === k); return { k, c, n: l.length, p: pc(l) }; }).filter((x) => x.n);
</script>
<Head icon="📊" title="Progress" sub="Persentase kegiatan yang selesai." />
<Guard>
  <div class="grid" style="grid-template-columns:repeat(auto-fit,minmax(240px,1fr));margin-bottom:18px">
    <div class="card dark"><small>Hari ini</small><h1 style="font-size:3.4rem;color:var(--lime)">{todayP}%</h1></div>
    <div class="card"><small>7 hari terakhir</small><h1 style="font-size:3.4rem;color:var(--moss)">{weekP}%</h1></div>
    <div class="card"><small>Total kegiatan (7 hari)</small><h1 style="font-size:3.4rem">{all.length}</h1></div>
  </div>
  <div class="grid g2">
    <div class="card"><h3>Grafik 7 hari</h3><div class="bars">{#each bars as b}<div>{b.p}%<span class="b" class:t={b.t} style="height:{b.p}%"></span>{b.d}</div>{/each}</div></div>
    <div class="card"><h3 style="margin-bottom:12px">Per jenis kegiatan</h3>
      {#each byCat as x}<p style="display:flex;justify-content:space-between;margin-top:10px"><b>{x.c.icon} {x.c.label}</b><span>{x.p}% · {x.n}</span></p><div class="meter" style="--c:{x.c.color}"><i style="width:{x.p}%"></i></div>
      {:else}<p style="color:var(--muted)">Belum ada data. Buat rencana di Daily Plan.</p>{/each}</div>
  </div>
</Guard>
