-- Hardening — APPLIED as crossfit_harden_function_grants
-- Keep SECURITY DEFINER helpers/RPC callable by authenticated only (never anon),
-- and make the guard trigger function non-callable.
revoke execute on function public.crossfit_is_admin() from anon;
revoke execute on function public.crossfit_is_coach_of(uuid) from anon;
revoke execute on function public.crossfit_can_access(uuid) from anon;
revoke execute on function public.crossfit_redeem_invite(text) from anon;
revoke all on function public.crossfit_guard_is_admin() from public;
revoke all on function public.crossfit_guard_is_admin() from anon;
revoke all on function public.crossfit_guard_is_admin() from authenticated;
