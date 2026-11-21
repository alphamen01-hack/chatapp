-- Create a UUID for the couple and use it as VITE_COUPLE_ID.
-- Invite/create both auth users in Supabase Dashboard (Auth -> Users).
-- Add one row for each user in love_members, assigning role='agila' or 'santhosh'.
create table if not exists public.love_members (
  couple_id uuid not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('agila','santhosh')),
  display_name text not null,
  primary key (couple_id,user_id),
  unique (couple_id,role)
);
create table if not exists public.love_messages (
  id uuid primary key,
  couple_id uuid not null,
  sender text not null check (sender in ('agila','santhosh')),
  kind text not null default 'text',
  content text,
  media_url text,
  media_path text,
  created_at timestamptz not null default now()
);
create index if not exists love_messages_couple_created on public.love_messages(couple_id,created_at);
alter table public.love_members enable row level security;
alter table public.love_messages enable row level security;
create policy "members read own couple roster" on public.love_members for select to authenticated
using (user_id=auth.uid());
create policy "couple members read messages" on public.love_messages for select to authenticated
using (exists(select 1 from public.love_members m where m.couple_id=love_messages.couple_id and m.user_id=auth.uid()));
create policy "members send as assigned role" on public.love_messages for insert to authenticated
with check (exists(select 1 from public.love_members m where m.couple_id=love_messages.couple_id and m.user_id=auth.uid() and m.role=love_messages.sender));
-- Storage: create a PRIVATE bucket named couple-media in Storage dashboard.
-- The policy permits authenticated members only to read/write files under their couple UUID folder.
create policy "couple media read" on storage.objects for select to authenticated
using (bucket_id='couple-media' and exists(select 1 from public.love_members m where m.user_id=auth.uid() and m.couple_id::text=(storage.foldername(name))[1]));
create policy "couple media upload" on storage.objects for insert to authenticated
with check (bucket_id='couple-media' and exists(select 1 from public.love_members m where m.user_id=auth.uid() and m.couple_id::text=(storage.foldername(name))[1]));
create policy "couple media delete own uploads" on storage.objects for delete to authenticated
using (bucket_id='couple-media' and exists(select 1 from public.love_members m where m.user_id=auth.uid() and m.couple_id::text=(storage.foldername(name))[1]));
-- Realtime: in Supabase Dashboard -> Database -> Replication, enable love_messages.
