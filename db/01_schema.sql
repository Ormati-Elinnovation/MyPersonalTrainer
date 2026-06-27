-- Coach layer schema (additive) — APPLIED as migration crossfit_coach_layer_schema
alter table public.profiles add column if not exists is_coach boolean not null default false;
alter table public.profiles add column if not exists is_admin boolean not null default false;
alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists phone text;
alter table public.profiles add column if not exists address text;
alter table public.profiles add column if not exists affiliate_box text;
alter table public.profiles add column if not exists instagram_handle text;
alter table public.profiles add column if not exists twitter_handle text;
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists onboarded_at timestamptz;

create table if not exists public.crossfit_prs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null check (category in ('weightlifting','powerlifting','benchmark')),
  name text not null,
  value numeric,
  unit text not null default 'kg' check (unit in ('kg','lb','sec','reps','rounds')),
  recorded_at date,
  notes text,
  created_at timestamptz not null default now()
);
create index if not exists crossfit_prs_user_idx on public.crossfit_prs (user_id);
create index if not exists crossfit_prs_user_name_idx on public.crossfit_prs (user_id, category, name);
alter table public.crossfit_prs enable row level security;

create table if not exists public.crossfit_coach_links (
  id uuid primary key default gen_random_uuid(),
  coach_user_id uuid not null references auth.users(id) on delete cascade,
  trainee_user_id uuid references auth.users(id) on delete cascade,
  status text not null default 'invited' check (status in ('invited','active','revoked')),
  invite_email text,
  join_code text unique,
  created_at timestamptz not null default now(),
  accepted_at timestamptz
);
create unique index if not exists crossfit_coach_links_pair_uniq
  on public.crossfit_coach_links (coach_user_id, trainee_user_id) where trainee_user_id is not null;
create index if not exists crossfit_coach_links_trainee_idx on public.crossfit_coach_links (trainee_user_id) where status='active';
create index if not exists crossfit_coach_links_coach_idx   on public.crossfit_coach_links (coach_user_id) where status='active';
create index if not exists crossfit_coach_links_code_idx    on public.crossfit_coach_links (join_code) where status='invited';
alter table public.crossfit_coach_links enable row level security;

alter table public.programs add column if not exists assigned_by_coach_id uuid references auth.users(id);

insert into storage.buckets (id, name, public) values ('crossfit-avatars','crossfit-avatars', false)
  on conflict (id) do nothing;

insert into public.crossfit_prs (user_id, category, name, value, unit)
select user_id, 'weightlifting', 'Snatch', snatch_1rm, 'kg' from public.profiles where snatch_1rm is not null
union all select user_id, 'weightlifting', 'Clean & Jerk', clean_jerk_1rm, 'kg' from public.profiles where clean_jerk_1rm is not null
union all select user_id, 'powerlifting', 'Back Squat', back_squat_1rm, 'kg' from public.profiles where back_squat_1rm is not null
union all select user_id, 'powerlifting', 'Deadlift', deadlift_1rm, 'kg' from public.profiles where deadlift_1rm is not null
union all select user_id, 'powerlifting', 'Bench Press', bench_press_1rm, 'kg' from public.profiles where bench_press_1rm is not null;

update public.profiles p set email = u.email from auth.users u where u.id = p.user_id and p.email is null;
