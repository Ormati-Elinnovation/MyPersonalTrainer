-- =====================================================================
--  RLS CUTOVER — APPLY ONLY AFTER THE NEW (login-required) FRONTEND IS
--  DEPLOYED TO PRODUCTION.
--
--  This replaces the wide-open RLS policies (qual=true) on the existing
--  crossfit tables with real auth.uid()-based policies, and makes the
--  `videos` bucket private. The currently-deployed guest-mode app WILL
--  STOP WORKING the moment this runs, because guests have no auth.uid().
--
--  Rollback: re-create the open policies (see bottom of this file).
--  Only touches crossfit tables/bucket — never the other apps' tables.
-- =====================================================================

-- ---- programs / blocks / tracker / videos / day_finished ----
drop policy if exists "programs open" on public.programs;
create policy programs_access on public.programs for all to authenticated
  using (public.crossfit_can_access(user_id)) with check (public.crossfit_can_access(user_id));

drop policy if exists "blocks open" on public.blocks;
create policy blocks_access on public.blocks for all to authenticated
  using (public.crossfit_can_access(user_id)) with check (public.crossfit_can_access(user_id));

drop policy if exists "tracker open" on public.tracker;
create policy tracker_access on public.tracker for all to authenticated
  using (public.crossfit_can_access(user_id)) with check (public.crossfit_can_access(user_id));

drop policy if exists "videos open" on public.videos;
create policy videos_access on public.videos for all to authenticated
  using (public.crossfit_can_access(user_id)) with check (public.crossfit_can_access(user_id));

drop policy if exists "day_finished open" on public.day_finished;
create policy day_finished_access on public.day_finished for all to authenticated
  using (public.crossfit_can_access(user_id)) with check (public.crossfit_can_access(user_id));

-- ---- profiles: read = self|coach|admin ; write = self ; admin may update anyone ----
drop policy if exists "profiles open" on public.profiles;
create policy profiles_select on public.profiles for select to authenticated
  using (public.crossfit_can_access(user_id));
create policy profiles_insert on public.profiles for insert to authenticated
  with check (user_id = auth.uid());
create policy profiles_update on public.profiles for update to authenticated
  using (user_id = auth.uid() or public.crossfit_is_admin())
  with check (user_id = auth.uid() or public.crossfit_is_admin());
create policy profiles_delete on public.profiles for delete to authenticated
  using (user_id = auth.uid());

-- ---- videos storage bucket: make private + owner|coach|admin ----
update storage.buckets set public = false where id = 'videos';
drop policy if exists "videos read public" on storage.objects;
drop policy if exists "videos insert open" on storage.objects;
drop policy if exists "videos update open" on storage.objects;
drop policy if exists "videos delete open" on storage.objects;
create policy videos_select on storage.objects for select to authenticated
  using (bucket_id='videos' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));
create policy videos_insert on storage.objects for insert to authenticated
  with check (bucket_id='videos' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));
create policy videos_update on storage.objects for update to authenticated
  using (bucket_id='videos' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));
create policy videos_delete on storage.objects for delete to authenticated
  using (bucket_id='videos' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));

-- =====================================================================
--  ROLLBACK (emergency) — re-open everything:
--
--  drop policy if exists programs_access on public.programs;
--  create policy "programs open" on public.programs for all using (true) with check (true);
--  ...repeat for blocks/tracker/videos/day_finished...
--  drop policy if exists profiles_select on public.profiles;
--  drop policy if exists profiles_insert on public.profiles;
--  drop policy if exists profiles_update on public.profiles;
--  drop policy if exists profiles_delete on public.profiles;
--  create policy "profiles open" on public.profiles for all using (true) with check (true);
--  update storage.buckets set public = true where id = 'videos';
-- =====================================================================
