create extension if not exists pgcrypto;

create table if not exists profiles (
  id uuid references auth.users primary key,
  name text,
  avatar_url text,
  created_at timestamp default now()
);

create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  title text default 'New Chat',
  mode text default 'online' check (mode in ('online', 'offline')),
  created_at timestamp default now(),
  updated_at timestamp default now()
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations on delete cascade not null,
  role text check (role in ('user', 'assistant')),
  content text,
  is_offline boolean default false,
  created_at timestamp default now()
);

alter table profiles enable row level security;
alter table conversations enable row level security;
alter table messages enable row level security;

create policy "profiles_owner_policy"
on profiles for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "conversations_owner_policy"
on conversations for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "messages_owner_policy"
on messages for all using (
  exists (
    select 1 from conversations c
    where c.id = conversation_id and c.user_id = auth.uid()
  )
) with check (
  exists (
    select 1 from conversations c
    where c.id = conversation_id and c.user_id = auth.uid()
  )
);

create index if not exists idx_conversations_user_updated_at on conversations(user_id, updated_at desc);
create index if not exists idx_messages_conversation_created_at on messages(conversation_id, created_at asc);
