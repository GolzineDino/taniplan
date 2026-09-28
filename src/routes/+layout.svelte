<script>
  import '../app.css';
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { supabase, uname } from '$lib/supabase';
  import { user, ready } from '$lib/auth';
  const nav = [['/', '🏡', 'Dashboard'], ['/plan', '📅', 'Daily Plan'], ['/todo', '✅', 'To-Do List'], ['/kegiatan', '🌱', 'Kegiatan Tani'], ['/jadwal', '⏰', 'Jadwal & Waktu'], ['/catatan', '📝', 'Catatan'], ['/progress', '📊', 'Progress'], ['/forum', '💬', 'Forum Tanya Jawab']];
  onMount(() => {
    supabase.auth.getSession().then(({ data }) => { user.set(data.session?.user ?? null); ready.set(true); });
    const { data: sub } = supabase.auth.onAuthStateChange((_e, s) => user.set(s?.user ?? null));
    return () => sub.subscription.unsubscribe();
  });
  const on = (h, p) => (h === '/' ? p === '/' : p.startsWith(h));
  async function out() { await supabase.auth.signOut(); goto('/'); }
</script>
<div class="shell">
  <aside class="side">
    <a class="logo" href="/">🌾 Tani<b>Plan</b></a>
    {#each nav as [h, i, l]}<a class="n" class:on={on(h, $page.url.pathname)} href={h}><span>{i}</span>{l}</a>{/each}
    <div class="me">
      {#if $user}<b>👋 {uname($user)}</b><br /><small>{$user.email}</small><br /><button class="btn sm line" style="margin-top:10px" on:click={out}>Keluar</button>
      {:else}<a class="btn sm sun" href="/login">Masuk / Daftar</a>{/if}
    </div>
  </aside>
  <div class="main"><slot /></div>
</div>
