-- PENDING (Or 07.11): Vibrate Plate recovery flag — shown for Alumit only in the UI.
-- Same pattern as 06_sauna_ice_tracker. The app auto-detects the column: until this runs,
-- the Vibrate Plate button and counter stay hidden.

alter table public.tracker
  add column if not exists vibrate_plate boolean not null default false;

comment on column public.tracker.vibrate_plate is 'Optional flag: Vibrate Plate checked for a workout day.';

notify pgrst, 'reload schema';
