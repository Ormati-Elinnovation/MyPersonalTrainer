-- Helper functions, guard trigger, redeem RPC — APPLIED as crossfit_coach_layer_functions
create or replace function public.crossfit_is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles p where p.user_id = auth.uid() and p.is_admin);
$$;
create or replace function public.crossfit_is_coach_of(trainee uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.crossfit_coach_links l
    where l.coach_user_id = auth.uid() and l.trainee_user_id = trainee and l.status='active');
$$;
create or replace function public.crossfit_can_access(owner uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select owner = auth.uid() or public.crossfit_is_admin() or public.crossfit_is_coach_of(owner);
$$;
revoke all on function public.crossfit_is_admin() from public;
revoke all on function public.crossfit_is_coach_of(uuid) from public;
revoke all on function public.crossfit_can_access(uuid) from public;
grant execute on function public.crossfit_is_admin() to authenticated;
grant execute on function public.crossfit_is_coach_of(uuid) to authenticated;
grant execute on function public.crossfit_can_access(uuid) to authenticated;

create or replace function public.crossfit_guard_is_admin()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.is_admin is distinct from old.is_admin
     and auth.uid() is not null
     and not public.crossfit_is_admin() then
    new.is_admin := old.is_admin;
  end if;
  return new;
end; $$;
drop trigger if exists crossfit_guard_is_admin on public.profiles;
create trigger crossfit_guard_is_admin before update on public.profiles
  for each row execute function public.crossfit_guard_is_admin();

create or replace function public.crossfit_redeem_invite(code text)
returns public.crossfit_coach_links language plpgsql security definer set search_path = public as $$
declare row public.crossfit_coach_links;
begin
  update public.crossfit_coach_links
     set trainee_user_id = auth.uid(), status='active', accepted_at=now()
   where join_code = code and status='invited'
   returning * into row;
  if not found then raise exception 'Invalid or used invite code'; end if;
  return row;
end; $$;
revoke all on function public.crossfit_redeem_invite(text) from public;
grant execute on function public.crossfit_redeem_invite(text) to authenticated;
