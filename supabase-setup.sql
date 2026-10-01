-- ============================================================
--  游戏工作台 - Supabase 数据库初始化脚本
--  使用方法：在 Supabase Dashboard 的 SQL Editor 中整段粘贴执行
-- ============================================================

-- 1. 用户表（自定义账号体系，不使用 Supabase Auth）
create table if not exists public.game_users (
  id bigserial primary key,
  uid text unique not null,
  username text unique not null,
  password text not null,
  created_at timestamptz default now()
);

-- 2. 游戏数据表
create table if not exists public.game_data (
  id bigserial primary key,
  uid text unique not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz default now()
);

-- 3. 索引
create index if not exists idx_game_users_username on public.game_users(username);
create index if not exists idx_game_users_uid on public.game_users(uid);
create index if not exists idx_game_data_uid on public.game_data(uid);

-- 4. 更新时间自动触发器（可选，updated_at 自动维护）
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_game_data_updated on public.game_data;
create trigger trg_game_data_updated
  before update on public.game_data
  for each row execute function public.handle_updated_at();

-- 5. Row Level Security（本项目使用自定义 uid 鉴权，因此对 anon 角色开放）
alter table public.game_users enable row level security;
alter table public.game_data enable row level security;

-- 6. RLS 策略 - game_users
drop policy if exists "public_game_users_select" on public.game_users;
create policy "public_game_users_select"
  on public.game_users for select
  to anon, authenticated
  using (true);

drop policy if exists "public_game_users_insert" on public.game_users;
create policy "public_game_users_insert"
  on public.game_users for insert
  to anon, authenticated
  with check (true);

-- 7. RLS 策略 - game_data
drop policy if exists "public_game_data_select" on public.game_data;
create policy "public_game_data_select"
  on public.game_data for select
  to anon, authenticated
  using (true);

drop policy if exists "public_game_data_insert" on public.game_data;
create policy "public_game_data_insert"
  on public.game_data for insert
  to anon, authenticated
  with check (true);

drop policy if exists "public_game_data_update" on public.game_data;
create policy "public_game_data_update"
  on public.game_data for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "public_game_data_delete" on public.game_data;
create policy "public_game_data_delete"
  on public.game_data for delete
  to anon, authenticated
  using (true);
