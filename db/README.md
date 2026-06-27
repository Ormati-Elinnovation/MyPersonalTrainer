# Database migrations — Coach Layer

Supabase project: `trpvmydhkdjybpqcciov` (shared across several apps — only the
`crossfit*` / shared `programs/blocks/tracker/profiles/videos/day_finished`
tables and the `videos` / `crossfit-avatars` storage buckets are touched here).

Apply order:

| File | What | Status |
|------|------|--------|
| `01_schema.sql` | roles, extended profile fields, `crossfit_prs`, `crossfit_coach_links`, `assigned_by_coach_id`, `crossfit-avatars` bucket, 1RM backfill | **applied** |
| `02_functions.sql` | `crossfit_is_admin / is_coach_of / can_access`, `is_admin` guard trigger, `crossfit_redeem_invite` RPC | **applied** |
| `03_new_table_policies.sql` | RLS policies for the NEW tables + avatars bucket (safe; old app unaffected) | **applied** |
| `04_rls_cutover_AFTER_DEPLOY.sql` | replace open policies on existing tables + make `videos` bucket private | **PENDING — run only after the new frontend is deployed** |

The admin flag was set manually:
`update profiles set is_admin=true where ... email='or10mati@gmail.com';`

⚠️ `04_rls_cutover` breaks the old guest-mode app instantly. Deploy the new
`deploy/index.html` (login-required) first, then run it.

## Additional applied migrations
- `crossfit_coach_trainee_limit` — DB trigger enforcing max 5 active trainees per coach.
