# generate-program (Supabase Edge Function)

Server-side AI that turns an uploaded workout file / goals into a structured
program (JSON day array). JWT-protected (authenticated users only).

**Provider: Anthropic Claude.**

## Secrets (Supabase dashboard → Edge Functions → Secrets; no redeploy needed)
- `ANTHROPIC_API_KEY` (required) — from https://console.anthropic.com → API Keys
- `ANTHROPIC_MODEL` (optional) — defaults to `claude-sonnet-4-6`

Dashboard: https://supabase.com/dashboard/project/trpvmydhkdjybpqcciov/settings/functions

(History: briefly used Gemini; reverted to Claude. Remove unused GEMINI_API_KEY / GEMINI_MODEL secrets.)
