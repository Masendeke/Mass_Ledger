-- Mass Ledger: run this once in Supabase -> SQL Editor.
-- Safe to re-run: tables use "if not exists" and policies are dropped first.

create table if not exists public.daily_entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  date        date not null,
  type        text not null check (type in ('profit', 'loss', 'noMovement')),
  amount      numeric not null default 0,
  note        text not null default '',
  updated_at  timestamptz not null default now(),
  unique (user_id, date)
);

create table if not exists public.user_profiles (
  user_id   uuid primary key references auth.users(id) on delete cascade,
  name      text,
  email     text,
  currency  text default 'South African Rand (R)'
);

alter table public.daily_entries enable row level security;
alter table public.user_profiles enable row level security;

drop policy if exists "own entries" on public.daily_entries;
create policy "own entries" on public.daily_entries
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "own profile" on public.user_profiles;
create policy "own profile" on public.user_profiles
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
