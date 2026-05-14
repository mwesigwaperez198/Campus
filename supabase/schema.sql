-- CampusConnect Master Production Schema (Makerere Blue Edition)
-- Motto: WE BUILD FOR THE FUTURE

create extension if not exists pgcrypto;

-- 1. PROFILES
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text not null,
  role text not null check (role in ('student', 'admin')) default 'student',
  institution text not null default 'Makerere University',
  avatar_url text,
  bio text,
  is_private boolean default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2. POSTS (Feed & Reels)
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references public.profiles(id) on delete cascade not null,
  caption text,
  image_url text,
  type text not null check (type in ('standard', 'admin_announcement', 'reel')) default 'standard',
  created_at timestamptz not null default now()
);

-- 3. GROUPS
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  avatar_url text,
  creator_id uuid references public.profiles(id) on delete set null,
  is_private boolean default false,
  created_at timestamptz default now()
);

-- 4. EVENTS
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  event_date timestamptz not null,
  venue text not null,
  host_name text not null,
  image_url text,
  created_at timestamptz default now()
);

-- 5. STORIES (Statuses)
create table if not exists public.statuses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  content_url text not null,
  expires_at timestamptz default (now() + interval '24 hours'),
  created_at timestamptz default now()
);

-- 6. MESSAGES
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid references public.profiles(id) on delete cascade,
  receiver_id uuid references public.profiles(id) on delete cascade,
  group_id uuid references public.groups(id) on delete cascade,
  content text,
  file_url text,
  type text default 'text', -- text, image, doc, voice, ai_image, poll, location
  created_at timestamptz default now()
);

-- 7. FOLLOWS
create table if not exists public.follows (
  follower_id uuid references public.profiles(id) on delete cascade,
  following_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (follower_id, following_id)
);

-- 8. EVENT REGISTRATIONS
create table if not exists public.event_registrations (
  event_id uuid references public.events(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (event_id, user_id)
);

-- RLS ENABLE
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.groups enable row level security;
alter table public.events enable row level security;
alter table public.statuses enable row level security;
alter table public.messages enable row level security;
alter table public.follows enable row level security;
alter table public.event_registrations enable row level security;

-- POLICIES (No Recursion)
create policy "Profiles viewable by all" on public.profiles for select using (not is_private or auth.uid() = id or exists (select 1 from public.follows where follower_id = auth.uid() and following_id = profiles.id));
create policy "Profiles update by owner" on public.profiles for update using (auth.uid() = id);

create policy "Posts viewable by all" on public.posts for select using (true);
create policy "Posts insert by owner" on public.posts for insert with check (auth.uid() = author_id);

create policy "Groups viewable by all" on public.groups for select using (true);
create policy "Groups insert by auth" on public.groups for insert with check (auth.role() = 'authenticated');

create policy "Events viewable by all" on public.events for select using (true);
create policy "Events insert by auth" on public.events for insert with check (auth.role() = 'authenticated');

create policy "Statuses viewable by all" on public.statuses for select using (expires_at > now());
create policy "Statuses insert by owner" on public.statuses for insert with check (auth.uid() = user_id);

create policy "Messages viewable by participants" on public.messages for select
using (auth.uid() = sender_id or auth.uid() = receiver_id or (group_id is not null));
create policy "Messages insert by sender" on public.messages for insert with check (auth.uid() = sender_id);

create policy "Follows viewable by all" on public.follows for select using (true);
create policy "Follows insert by follower" on public.follows for insert with check (auth.uid() = follower_id);

create policy "Event regs viewable by all" on public.event_registrations for select using (true);
create policy "Event regs insert by user" on public.event_registrations for insert with check (auth.uid() = user_id);
create policy "Event regs delete by user" on public.event_registrations for delete using (auth.uid() = user_id);

-- AUTH TRIGGER
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', 'User'),
    coalesce(new.raw_user_meta_data->>'role', 'student')
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- STORAGE
insert into storage.buckets (id, name, public) values
('posts','posts',true), ('avatars','avatars',true), ('stories','stories',true), ('groups','groups',true), ('events','events',true)
on conflict (id) do nothing;

create policy "Storage Access" on storage.objects for select using (true);
create policy "Storage Upload" on storage.objects for insert with check (auth.role() = 'authenticated');
