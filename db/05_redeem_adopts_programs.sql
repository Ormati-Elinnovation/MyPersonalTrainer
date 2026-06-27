-- APPLIED as crossfit_redeem_adopts_existing_programs
-- On redeem, the trainee "brings" their existing programs under the coach's
-- management (stamp assigned_by_coach_id), so the coach manages them and they
-- become subject to the per-trainee edit lock.
create or replace function public.crossfit_redeem_invite(code text)
returns public.crossfit_coach_links language plpgsql security definer set search_path = public as $$
declare row public.crossfit_coach_links;
begin
  update public.crossfit_coach_links
     set trainee_user_id = auth.uid(), status='active', accepted_at=now()
   where join_code = code and status='invited'
   returning * into row;
  if not found then raise exception 'Invalid or used invite code'; end if;
  update public.programs set assigned_by_coach_id = row.coach_user_id
   where user_id = auth.uid() and assigned_by_coach_id is null;
  return row;
end; $$;
revoke all on function public.crossfit_redeem_invite(text) from public, anon;
grant execute on function public.crossfit_redeem_invite(text) to authenticated;
