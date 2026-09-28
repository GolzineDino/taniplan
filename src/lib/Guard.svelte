<script>import { user, ready } from '$lib/auth';</script>
{#if !$ready}<div class="empty">Memuat…</div>
{:else if $user}<slot />
{:else}<div class="lock"><span>🔒</span><h2>Masuk dulu untuk mengatur kegiatanmu</h2><p>Data rencana, catatan, dan progres tersimpan aman di akunmu.</p><a class="btn" href="/login">Masuk / Daftar</a></div>{/if}
