-- PENDING (Or 07.11): Float (flotation tank) recovery flag — shown for Alumit only in the UI.
-- Same pattern as 06_sauna_ice_tracker. The app auto-detects the column: until this runs,
-- the Float button and counter render but toggles are not persisted.

alter table public.tracker
  add column if not exists float_tank boolean not null default false;

comment on column public.tracker.float_tank is 'Optional flag: Float (flotation tank) checked for a workout day.';

notify pgrst, 'reload schema';
