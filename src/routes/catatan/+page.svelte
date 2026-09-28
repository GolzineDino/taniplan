<script>
  import { supabase, BUCKET, uploadImage, ago } from '$lib/supabase';
  import { user } from '$lib/auth';
  import Guard from '$lib/Guard.svelte';
  import Head from '$lib/Head.svelte';
  let list = [], plant = '', condition = 'Sehat', body = '', file = null, busy = false, error = '';
  $: if ($user) load();
  async function load() { const { data } = await supabase.from('notes').select('*').order('created_at', { ascending: false }); list = data || []; }
  async function save() {
    error = ''; busy = true;
    try {
      let img = { url: null, path: null };
      if (file) img = await uploadImage(file, $user.id);
      const { error: e } = await supabase.from('notes').insert({ plant, condition, body, image_url: img.url, image_path: img.path });
      if (e) throw e;
      plant = body = ''; file = null; load();
    } catch (e) { error = e.message; }
    busy = false;
  }
  async function del(n) {
    if (!confirm('Hapus catatan ini?')) return;
    if (n.image_path) await supabase.storage.from(BUCKET).remove([n.image_path]);
    await supabase.from('notes').delete().eq('id', n.id); load();
  }
</script>
<Head icon="📝" title="Catatan" sub="Catat kondisi tanaman atau hasil kegiatan. Foto boleh dilewati." />
<Guard><div class="grid g2">
  <div class="grid" style="grid-template-columns:repeat(auto-fill,minmax(250px,1fr));align-content:start">
    {#each list as n}<article class="card note">{#if n.image_url}<img src={n.image_url} alt={n.plant} />{/if}
      <div class="b"><span class="tag {n.condition.split(' ')[0]}">{n.condition}</span><h3 style="margin:8px 0 4px">{n.plant}</h3><p class="pre">{n.body}</p>
        <div class="who">{ago(n.created_at)} <button class="btn sm del" on:click={() => del(n)}>Hapus</button></div></div></article>
    {:else}<div class="empty" style="grid-column:1/-1">Belum ada catatan. Tulis kondisi tanamanmu hari ini 🌿</div>{/each}
  </div>
  <form class="card" on:submit|preventDefault={save} style="align-self:start">
    <h3>Catatan baru</h3>
    <label for="p">Tanaman / lahan</label><input id="p" bind:value={plant} required placeholder="mis. Cabai bedengan 2" />
    <label for="c">Kondisi</label><select id="c" bind:value={condition}><option>Sehat</option><option>Perlu perhatian</option><option>Sakit</option><option>Panen</option></select>
    <label for="b">Catatan</label><textarea id="b" bind:value={body} required placeholder="Tinggi tanaman, warna daun, hasil panen…"></textarea>
    <label for="f">Foto (opsional)</label><input id="f" type="file" accept="image/*" on:change={(e) => (file = e.target.files[0] || null)} />
    {#if error}<div class="err">{error}</div>{/if}
    <button class="btn" style="margin-top:16px" disabled={busy}>{busy ? 'Menyimpan…' : 'Simpan catatan'}</button>
  </form>
</div></Guard>
