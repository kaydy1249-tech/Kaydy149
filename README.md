# ShopROBUXGMHUB — GitHub Pages

Upload **all files in this folder** to the root of the GitHub repository.

## Files
- `index.html` — shop
- `admin.html` — admin login/dashboard
- `app.js` — shop logic
- `config.js` — Supabase browser configuration
- `schema.sql` — database/RLS setup
- `.nojekyll` — GitHub Pages helper

## Important
The browser key is a Supabase Publishable key. It is safe to expose in frontend code, but your Supabase RLS policies must be configured correctly.

Before using orders, run `schema.sql` in Supabase SQL Editor. Then ensure your Auth user's UUID exists in `public.admin_users`.
