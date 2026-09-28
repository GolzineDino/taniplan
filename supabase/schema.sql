-- Jalankan di Supabase > SQL Editor
create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  title text not null, category text not null default 'lain',
  plan_date date not null default current_date,
  start_time time, end_time time,
  done boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  plant text not null, condition text not null default 'Sehat', body text not null,
  image_url text, image_path text, created_at timestamptz not null default now()
);
create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 5 and 200), body text not null,
  image_url text, image_path text,
  user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null, created_at timestamptz not null default now()
);
create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  body text not null, user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null, created_at timestamptz not null default now()
);
create index if not exists act_user_date on public.activities(user_id, plan_date);
create index if not exists notes_user on public.notes(user_id, created_at desc);

alter table public.activities enable row level security;
alter table public.notes enable row level security;
alter table public.questions enable row level security;
alter table public.answers enable row level security;
create policy "act_own" on public.activities for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "notes_own" on public.notes for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "q_read" on public.questions for select using (true);
create policy "q_ins" on public.questions for insert to authenticated with check (auth.uid() = user_id);
create policy "q_del" on public.questions for delete to authenticated using (auth.uid() = user_id);
create policy "a_read" on public.answers for select using (true);
create policy "a_ins" on public.answers for insert to authenticated with check (auth.uid() = user_id);
create policy "a_del" on public.answers for delete to authenticated using (auth.uid() = user_id);

insert into storage.buckets (id, name, public) values ('taniplan-images','taniplan-images', true) on conflict do nothing;
create policy "img_read" on storage.objects for select using (bucket_id = 'taniplan-images');
create policy "img_up" on storage.objects for insert to authenticated with check (bucket_id = 'taniplan-images' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "img_del" on storage.objects for delete to authenticated using (bucket_id = 'taniplan-images' and (storage.foldername(name))[1] = auth.uid()::text);
