# Agila × Santhosh Love Chat — Final starter

Romantic purple/pink animated chat UI with demo mode and optional Supabase auth + realtime message sync.

## Local preview (demo mode)
1. Install Node.js 18+.
2. Extract this folder and run `npm install`.
3. Run `npm run dev`, then open the localhost URL shown.
4. Demo mode works without Supabase; messages and profile images are stored in this browser only.

## Live private chat (Supabase)
1. Create a Supabase project. Copy project URL and anon/publishable key.
2. In SQL Editor, run `supabase-setup.sql`.
3. Create a UUID to represent your couple, then use it in `.env` as `VITE_COUPLE_ID`.
4. Create/invite exactly two Auth users (one for Agila, one for Santhosh) from Supabase Auth dashboard.
5. Insert their role mapping in `love_members` using that UUID and each user's Auth UUID:
   - role `agila`, display_name `Agila`
   - role `santhosh`, display_name `Santhosh`
6. Create a **private** Storage bucket named `couple-media` and keep it private. Storage policies in SQL restrict access to couple folder. For this prototype, storage upload uses signed links and UI does not yet refresh expired links automatically.
7. Add `.env` file in the project root:
```
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
VITE_COUPLE_ID=YOUR_COUPLE_UUID
```
8. Realtime: Dashboard -> Database -> Replication; enable `love_messages` table for realtime.
9. `npm install`, `npm run build` to test. Deploy to Vercel by importing the GitHub repo. Add the same environment variables in Vercel Project Settings -> Environment Variables, then redeploy.

## Notes
- Demo mode is local to one browser/device; it is not cross-device.
- Supabase mode syncs text and message metadata. Storage uploads use private bucket signed URLs; the prototype does not refresh expired media links yet.
- Calls are UI buttons only; real voice/video calling needs a WebRTC/calling service integration.
- Photo avatar changes are currently stored locally in the browser.
- Do not expose Supabase service-role keys in Vite/client environment variables. Use only the anon/publishable key.
