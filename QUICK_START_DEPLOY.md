# Quick Start: Deploy Import Staff Users and Shared Folders Fixes

## ⚡ 3-Step Deploy

### 1️⃣ Deploy Edge Function (1 minute)
```bash
cd /path/to/oricol-ticket-flow-34e64301
npx supabase functions deploy import-staff-users
```

### 2️⃣ Apply Database Migration (1 minute)

**Using Supabase Dashboard:**
1. Go to https://supabase.com/dashboard
2. Select your project → SQL Editor → New Query
3. Copy from: `supabase/migrations/20251116230000_fix_shared_folders_rls.sql`
4. Paste and click "Run"

**Or using CLI:**
```bash
npx supabase db push
```

### 3️⃣ Deploy Application (depends on your setup)
```bash
npm run build
# Then deploy to your hosting (Vercel, Netlify, etc.)
```

## ✅ Quick Test

### Test Import Staff Users:
1. Login as admin
2. Go to "Import from Staff Users"
3. Select users → Import
4. **Expected:** ✅ "Created X users" + password CSV download

### Test Create Folder:
1. Login as admin
2. Go to Shared Files
3. Click "New Folder" → Enter name → Create
4. **Expected:** ✅ "Folder created successfully"

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Function not found | Deploy edge function (step 1) |
| Failed to create folder | Apply migration (step 2) |
| Permission denied | Verify you're logged in as admin |
| User already exists | Staff user email is already in use |

## 📖 Full Documentation

See `FIX_SUMMARY_IMPORT_AND_FOLDERS.md` for:
- Detailed technical explanation
- Security considerations
- Advanced troubleshooting
- Next steps and future enhancements

---

**Ready?** Start with Step 1 ⬆️
