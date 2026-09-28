<script>
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { supabase, BUCKET, ago, uname } from '$lib/supabase';
  import { user } from '$lib/auth';
  let q = null, answers = [], text = '', busy = false, error = '', loading = true;
  $: id = $page.params.id;
  $: if (id) load();
  async function load() {
    q = (await supabase.from('questions').select('*').eq('id', id).maybeSingle()).data;
    answers = (await supabase.from('answers').select('*').eq('question_id', id).order('created_at')).data || []; loading = false;
  }
  async function reply() {
    error = ''; busy = true;
    const { error: e } = await supabase.from('answers').insert({ question_id: id, body: text, user_id: $user.id, author_name: uname($user) });
    busy = false; if (e) error = e.message; else { text = ''; load(); }
  }
  async function delA(a) { if (confirm('Hapus jawaban ini?')) { await supabase.from('answers').delete().eq('id', a.id); load(); } }
  async function delQ() {
    if (!confirm('Hapus pertanyaan beserta semua jawabannya?')) return;
    if (q.image_path) await supabase.storage.from(BUCKET).remove([q.image_path]);
    const { error: e } = await supabase.from('questions').delete().eq('id', id);
    if (e) alert(e.message); else goto('/forum');
  }
</script>
<svelte:head><title>{q?.title ?? 'Pertanyaan'} – TaniPlan</title></svelte:head>
<div style="max-width:820px">
{#if loading}<div class="empty">Memuat…</div>
{:else if !q}<div class="empty">Pertanyaan tidak ditemukan. <a href="/forum">Kembali</a></div>
{:else}
  <a href="/forum">← Forum</a>
  <article class="card" style="margin-top:10px"><h1 style="font-size:1.9rem">{q.title}</h1>
    <div class="who">{q.author_name} · {ago(q.created_at)} {#if $user?.id === q.user_id}<button class="btn sm del" on:click={delQ}>Hapus</button>{/if}</div>
    <p class="pre" style="margin-top:12px">{q.body}</p>{#if q.image_url}<img class="img" src={q.image_url} alt="Foto pertanyaan" />{/if}</article>
  <h2 style="margin:24px 0 10px">{answers.length} Jawaban</h2>
  {#each answers as a}<div class="card" style="margin-bottom:10px"><p class="pre">{a.body}</p><div class="who">{a.author_name} · {ago(a.created_at)} {#if $user?.id === a.user_id}<button class="btn sm del" on:click={() => delA(a)}>Hapus</button>{/if}</div></div>
  {:else}<div class="empty">Belum ada jawaban. Bagikan pengalamanmu!</div>{/each}
  <div class="card" style="margin-top:16px"><h3>Jawaban Anda</h3>
    {#if $user}<form on:submit|preventDefault={reply}><textarea bind:value={text} required></textarea>{#if error}<div class="err">{error}</div>{/if}<button class="btn" style="margin-top:12px" disabled={busy}>Kirim jawaban</button></form>
    {:else}<p style="margin-top:10px"><a class="btn" href="/login">Masuk untuk menjawab</a></p>{/if}</div>
{/if}</div>
