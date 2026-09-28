<script>
  import { supabase } from '$lib/supabase';
  import { goto } from '$app/navigation';
  let mode = 'login', email = '', password = '', username = '', error = '', info = '', busy = false;
  async function submit() {
    error = info = ''; busy = true;
    if (mode === 'login') {
      const { error: e } = await supabase.auth.signInWithPassword({ email, password });
      if (e) error = 'Email atau kata sandi salah.'; else goto('/');
    } else {
      const { data, error: e } = await supabase.auth.signUp({ email, password, options: { data: { username: username || email.split('@')[0] } } });
      if (e) error = e.message; else if (data.session) goto('/'); else info = 'Pendaftaran berhasil. Cek email untuk konfirmasi, lalu masuk.';
    }
    busy = false;
  }
</script>
<svelte:head><title>Masuk – TaniPlan</title></svelte:head>
<div class="hero" style="min-height:0;padding-bottom:110px"><div class="sunb"></div><div class="in" style="grid-template-columns:1fr"><h1>Mulai hari tanimu 🌅</h1></div></div>
<div class="card" style="max-width:440px;margin:-70px auto 0;position:relative;z-index:3">
  <div class="tabs"><button class:on={mode==='login'} on:click={() => (mode='login')}>Masuk</button><button class:on={mode==='register'} on:click={() => (mode='register')}>Daftar</button></div>
  <form on:submit|preventDefault={submit}>
    {#if mode==='register'}<label for="u">Nama tampilan</label><input id="u" bind:value={username} placeholder="mis. Pak Tani" />{/if}
    <label for="e">Email</label><input id="e" type="email" bind:value={email} required />
    <label for="p">Kata sandi</label><input id="p" type="password" minlength="6" bind:value={password} required />
    {#if error}<div class="err">{error}</div>{/if}{#if info}<div class="okm">{info}</div>{/if}
    <button class="btn" style="width:100%;justify-content:center;margin-top:18px" disabled={busy}>{mode==='login' ? 'Masuk' : 'Buat akun'}</button>
  </form>
</div>
