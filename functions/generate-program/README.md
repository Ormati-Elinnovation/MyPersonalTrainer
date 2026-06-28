# generate-program (Supabase Edge Function)

Server-side AI that turns an uploaded workout file / goals into a structured
program (JSON day array). JWT-protected (authenticated users only).

**Provider: Google Gemini** (cheaper than Claude).

## Secrets (set in Supabase dashboard, no redeploy needed)
- `GEMINI_API_KEY` (required) — from https://aistudio.google.com/apikey
- `GEMINI_MODEL` (optional) — defaults to `gemini-2.0-flash`

Dashboard: https://supabase.com/dashboard/project/trpvmydhkdjybpqcciov/settings/functions
→ Edge Functions → Secrets.

Deployed via Supabase MCP `deploy_edge_function` (the live source is index.ts here).
