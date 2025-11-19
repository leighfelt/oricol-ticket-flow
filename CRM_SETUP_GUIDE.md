# Oricol CRM Setup Guide

## Quick Fix: "Failed to load CRM data" Error

If you're seeing the error "Failed to load CRM data" when accessing the Oricol CRM page, it means the CRM database tables haven't been created yet. Follow the instructions below based on your setup.

---

## 🚀 Option 1: For Lovable Users (No CLI Access)

**This is the easiest method if you're using Lovable.dev**

1. **Open Supabase SQL Editor**
   - Go to your Supabase project dashboard at [supabase.com](https://supabase.com)
   - Click on "SQL Editor" in the left sidebar
   - Click "New query" to create a new query

2. **Copy and Run the Migration**
   - Open the file `supabase/migrations/20251119080900_create_crm_system.sql` from your GitHub repository
   - Copy the entire contents of the file
   - Paste it into the Supabase SQL Editor
   - Click the "Run" button (or press Ctrl+Enter / Cmd+Enter)

3. **Verify the Setup**
   - You should see a success message
   - Go back to your Oricol app and navigate to the CRM page
   - The page should now load without errors

---

## 💻 Option 2: For CLI Users (Local Development)

**If you have Node.js and the Supabase CLI installed**

1. **Apply the migration**
   ```bash
   npm run migrate
   ```
   
   Or use the Supabase CLI directly:
   ```bash
   npx supabase db push
   ```

2. **Verify the tables were created**
   ```bash
   npx supabase db dump --data-only
   ```

3. **Test the CRM page**
   - Start your development server: `npm run dev`
   - Navigate to http://localhost:8080/crm
   - The page should now load without errors

---

## ✅ What This Migration Does

The migration creates the following database tables:

### 1. **crm_companies**
   - Stores company/organization information
   - Fields: name, industry, size, contact info, address, etc.
   - Status tracking: active, inactive, prospect

### 2. **crm_contacts**
   - Stores individual contact information
   - Links to companies
   - Fields: name, email, phone, job title, department, etc.

### 3. **crm_deals**
   - Tracks sales opportunities/deals
   - Links to companies and contacts
   - Fields: title, value, currency, stage, probability, dates
   - Stages: lead → qualified → proposal → negotiation → won/lost

### 4. **crm_activities**
   - Logs customer interactions
   - Types: calls, emails, meetings, notes, tasks, follow-ups
   - Links to companies, contacts, and deals

---

## 🔒 Security Features

The migration includes:
- **Row Level Security (RLS)** enabled on all tables
- **Admin-only access** - Only users with admin role can access CRM data
- **Automatic timestamps** - created_at and updated_at fields
- **Indexes** for better query performance
- **Foreign key relationships** for data integrity

---

## 🛡️ Permissions

**Important:** The CRM system is restricted to admin users only. To access the CRM:

1. You must be signed in
2. Your account must have the 'admin' role in the `user_roles` table

If you need admin access, see [ADMIN_ACCOUNT_SETUP.md](./ADMIN_ACCOUNT_SETUP.md)

---

## 🧪 Testing the CRM System

After applying the migration, test the CRM by:

1. **Navigate to CRM page**: Go to `/crm` in your app
2. **Check the dashboard**: You should see 4 stat cards showing 0 for everything
3. **Try creating a company**:
   - Click "Add Company"
   - Fill in the company name (required)
   - Add any additional details
   - Click "Add Company"
4. **Verify it appears**: The new company should show up in the companies list

---

## ❓ Troubleshooting

### "Access Denied" or "Permission Denied" Errors

This means you don't have admin permissions. See:
- [ADMIN_ACCOUNT_SETUP.md](./ADMIN_ACCOUNT_SETUP.md)
- [QUICK_FIX_ACCESS_DENIED.md](./QUICK_FIX_ACCESS_DENIED.md)

### "Table already exists" Error

If you see this error, the migration has already been applied. You can safely ignore it.

### Migration Fails to Run

1. Check your Supabase connection is working
2. Ensure you're logged into the correct project
3. Try running the SQL manually in the Supabase SQL Editor

### Still Getting "Failed to load CRM data"

1. Clear your browser cache and reload
2. Sign out and sign back in
3. Check the browser console for specific error messages
4. Verify the tables exist in Supabase:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name LIKE 'crm_%';
   ```

---

## 📚 Related Documentation

- [LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md) - Complete guide for editing SQL on Lovable
- [SUPABASE_MIGRATIONS.md](./SUPABASE_MIGRATIONS.md) - Complete migration guide
- [ADMIN_ACCOUNT_SETUP.md](./ADMIN_ACCOUNT_SETUP.md) - Setting up admin accounts

---

## 🆘 Need Help?

If you're still experiencing issues:
1. Check the error message in the browser console (F12)
2. Verify your Supabase connection in `.env`
3. Create a ticket in the system
4. Contact support

---

## 📝 Manual SQL (Alternative Method)

If the migration file is not accessible, you can run this SQL directly in Supabase SQL Editor:

```sql
-- See the full SQL in: supabase/migrations/20251119080900_create_crm_system.sql
```

The migration file contains approximately 273 lines of SQL that create all tables, indexes, RLS policies, and triggers.
