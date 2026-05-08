-- CampusConnect Production Schema - Makerere University Edition
-- Motto: WE BUILD FOR THE FUTURE

-- 1. PROFILES
-- Stores user information linked to Supabase Auth
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text not null,
  role text not null check (role in ('student', 'admin')) default 'student',
  institution text not null default 'Makerere University',
  avatar_url text,
  location text default 'Kampala, Uganda',
  phone_number text,
  bio text,
  is_verified boolean default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2. POSTS (Instagram-style Feed)
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references public.profiles(id) on delete cascade not null,
  caption text not null,
  image_url text, -- Primary image/video content
  type text not null check (type in ('standard', 'admin_announcement')) default 'standard',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 3. GROUPS
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  focus text,
  avatar_url text,
  created_at timestamptz not null default now()
);

-- 4. EVENTS
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  event_date timestamptz not null,
  venue text not null,
  host_name text not null,
  image_url text,
  created_at timestamptz not null default now()
);

-- 5. STATUSES (Instagram-style Stories)
create table if not exists public.statuses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  content_url text not null,
  expires_at timestamptz not null default (now() + interval '24 hours'),
  created_at timestamptz not null default now()
);

-- 6. MESSAGES
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid references public.profiles(id) on delete cascade not null,
  receiver_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  is_read boolean default false,
  created_at timestamptz not null default now()
);

-- 7. LIKES
create table if not exists public.post_likes (
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

-- 8. COMMENTS
create table if not exists public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  created_at timestamptz not null default now()
);

-- 9. NOTIFICATIONS
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  actor_id uuid references public.profiles(id) on delete cascade not null,
  type text not null check (type in ('like', 'comment', 'message', 'announcement')),
  post_id uuid references public.posts(id) on delete cascade,
  content text,
  is_read boolean default false,
  created_at timestamptz not null default now()
);

-- SECURITY & ACCESS CONTROL (RLS)
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.groups enable row level security;
alter table public.events enable row level security;
alter table public.statuses enable row level security;
alter table public.messages enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.notifications enable row level security;

-- Profiles: Public can see profiles, users can edit their own
create policy "Public Profiles are viewable by everyone" on public.profiles for select using (true);
create policy "Users can insert their own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update their own profile" on public.profiles for update using (auth.uid() = id);

-- Posts: Public can see posts, authenticated can create
create policy "Posts are viewable by everyone" on public.posts for select using (true);
create policy "Users can create their own posts" on public.posts for insert with check (auth.uid() = author_id);
create policy "Users can delete their own posts" on public.posts for delete using (auth.uid() = author_id);

-- Social: Likes & Comments
create policy "Likes are viewable by everyone" on public.post_likes for select using (true);
create policy "Users can like posts" on public.post_likes for insert with check (auth.uid() = user_id);
create policy "Users can unlike posts" on public.post_likes for delete using (auth.uid() = user_id);

create policy "Comments are viewable by everyone" on public.post_comments for select using (true);
create policy "Users can comment" on public.post_comments for insert with check (auth.uid() = user_id);

-- Messages: Only participants can see/send
create policy "Users can see their own messages" on public.messages for select using (auth.uid() = sender_id or auth.uid() = receiver_id);
create policy "Users can send messages" on public.messages for insert with check (auth.uid() = sender_id);

-- DATABASE LOGIC & FUNCTIONS

-- A. Automatically create a profile when a new user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', 'Makerere User'), coalesce(new.raw_user_meta_data->>'role', 'student'));
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for new user signup
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- B. Real-time Pub/Sub configuration
alter publication supabase_realtime add table posts;
alter publication supabase_realtime add table messages;
alter publication supabase_realtime add table notifications;
alter publication supabase_realtime add table statuses;
