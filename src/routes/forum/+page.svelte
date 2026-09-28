<script>
  import { supabase, uploadImage, ago, uname } from '$lib/supabase';
  import { user } from '$lib/auth';
  import { onMount } from 'svelte';
  import Head from '$lib/Head.svelte';
  let list = [], search = '', open = false, title = '', body = '', file = null, busy = false, error = '';
  onMount(load);
  async function load() { const { data } = await supabase.from('questions').select('id,title,author_name,created_at,image_url,answers(count)').order('created_at', { ascending: false }); list = data || []; }
  async function post() {
    error = ''; busy = true;
    try {
      let img = { url: null, path: null };
      if (file) img = await uploadImage(file, $user.id);
      const { error: e } = await supabase.from('questions').insert({ title, body, image_url: img.url, image_path: img.path, user_id: $user.id, author_name: uname($user) });
      if (e) throw e;
      title = body = ''; file = null; open = false; load();
    } catch (e) { error = e.message; }
    busy = false;
  }
  $: shown = list.filter((q) => q.title.toLowerCase().includes(search.toLowerCase()));
</script>
<Head icon="💬" title="Forum Tanya Jawab" sub="Tanya sesama petani dan mahasiswa pertanian, atau bagikan pengalamanmu." />
<div style="display:flex;gap:10px;flex-wrap:wrap;margin-bottom:16px"><input style="flex:1;min-width:200px" placeholder="Cari pertanyaan…" bind:value={search} />
  {#if $user}<button class="btn sun" on:click={() => (open = !open)}>{open ? 'Tutup' : '+ Tulis pertanyaan'}</button>{:else}<a class="btn" href="/login">Masuk untuk bertanya</a>{/if}</div>
{#if open && $user}
  <form class="card" style="margin-bottom:18px" on:submit|preventDefault={post}>
    <label for="t">Judul</label><input id="t" bind:value={title} minlength="5" maxlength="200" required />
    <label for="b">Deskripsi</label><textarea id="b" bind:value={body} required></textarea>
    <label for="f">Foto (opsional)</label><input id="f" type="file" accept="image/*" on:change={(e) => (file = e.target.files[0] || null)} />
    {#if error}<div class="err">{error}</div>{/if}
    <button class="btn" style="margin-top:14px" disabled={busy}>{busy ? 'Mengirim…' : 'Kirim pertanyaan'}</button>
  </form>
{/if}
{#each shown as q}<a class="q" href="/forum/{q.id}"><div class="cnt">{q.answers?.[0]?.count ?? 0}<small>jawaban</small></div><div><h3>{q.title}</h3><div class="who">{q.author_name} · {ago(q.created_at)}</div></div>{#if q.image_url}<img class="th" src={q.image_url} alt="" />{/if}</a>
{:else}<div class="empty">Belum ada pertanyaan. Jadilah yang pertama bertanya 🌾</div>{/each}
