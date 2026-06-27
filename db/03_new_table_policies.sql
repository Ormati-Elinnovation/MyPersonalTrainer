-- RLS for NEW tables/bucket — APPLIED as crossfit_coach_layer_new_table_policies
-- Safe: old app does not touch these.
drop policy if exists crossfit_prs_access on public.crossfit_prs;
create policy crossfit_prs_access on public.crossfit_prs for all to authenticated
  using (public.crossfit_can_access(user_id)) with check (public.crossfit_can_access(user_id));

drop policy if exists coach_links_select on public.crossfit_coach_links;
create policy coach_links_select on public.crossfit_coach_links for select to authenticated
  using (coach_user_id = auth.uid() or trainee_user_id = auth.uid() or public.crossfit_is_admin());
drop policy if exists coach_links_insert on public.crossfit_coach_links;
create policy coach_links_insert on public.crossfit_coach_links for insert to authenticated
  with check (coach_user_id = auth.uid());
drop policy if exists coach_links_coach_update on public.crossfit_coach_links;
create policy coach_links_coach_update on public.crossfit_coach_links for update to authenticated
  using (coach_user_id = auth.uid() or public.crossfit_is_admin())
  with check (coach_user_id = auth.uid() or public.crossfit_is_admin());
drop policy if exists coach_links_coach_delete on public.crossfit_coach_links;
create policy coach_links_coach_delete on public.crossfit_coach_links for delete to authenticated
  using (coach_user_id = auth.uid() or public.crossfit_is_admin());

drop policy if exists crossfit_avatars_select on storage.objects;
create policy crossfit_avatars_select on storage.objects for select to authenticated
  using (bucket_id='crossfit-avatars' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));
drop policy if exists crossfit_avatars_insert on storage.objects;
create policy crossfit_avatars_insert on storage.objects for insert to authenticated
  with check (bucket_id='crossfit-avatars' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));
drop policy if exists crossfit_avatars_update on storage.objects;
create policy crossfit_avatars_update on storage.objects for update to authenticated
  using (bucket_id='crossfit-avatars' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));
drop policy if exists crossfit_avatars_delete on storage.objects;
create policy crossfit_avatars_delete on storage.objects for delete to authenticated
  using (bucket_id='crossfit-avatars' and public.crossfit_can_access(((storage.foldername(name))[1])::uuid));
