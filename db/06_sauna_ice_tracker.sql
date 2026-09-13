-- APPLIED as crossfit_sauna_ice_tracker
-- Add global Sauna/Ice flags to tracker entries.
-- These are optional completion extras and DO NOT affect workout completion counts.

alter table public.tracker
  add column if not exists sauna boolean not null default false,
  add column if not exists ice boolean not null default false;

comment on column public.tracker.sauna is 'Global optional flag: Sauna checked for a workout day.';
comment on column public.tracker.ice is 'Global optional flag: Ice checked for a workout day.';
