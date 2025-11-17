# Quick Fix Guide - Error Messages

## Common Errors and Solutions

### 🚫 "Permission denied - Only administrators can create folders/groups"

**What it means**: You don't have admin role assigned

**Quick Fix**:
1. Contact your system administrator
2. They need to run this SQL in Supabase:
   ```sql
   INSERT INTO user_roles (user_id, role)
   VALUES ('your-user-id-here', 'admin');
   ```
3. Log out and log back in

**How to find your user ID**:
- Open browser console (F12)
- Run: `(await supabase.auth.getUser()).data.user.id`

---

### 🌐 "Network error - unable to reach the server"

**What it means**: Can't connect to Supabase

**Quick Fix**:
1. Check your internet connection
2. Verify Supabase project status: https://status.supabase.com
3. Try refreshing the page
4. Clear browser cache and retry

---

### 🔑 "Authentication error - your session may have expired"

**What it means**: Your login session is no longer valid

**Quick Fix**:
1. Log out completely
2. Clear browser cookies for this site
3. Log back in with your credentials

---

### 📁 "A folder with this name already exists"

**What it means**: Duplicate folder name in the same location

**Quick Fix**:
1. Choose a different folder name
2. Or navigate to a different parent folder
3. Or delete the existing folder first (if you have permission)

---

### 👥 "This user is already a member of this group"

**What it means**: The user is already in the group

**Quick Fix**:
1. Select a different user
2. Or remove the user from the group first, then re-add

---

### ⚠️ "Row-level security policy violation"

**What it means**: Database security is blocking your action

**Quick Fix**:
1. Verify you have admin role:
   ```sql
   SELECT * FROM user_roles WHERE user_id = 'your-user-id';
   ```
2. If no admin role, contact your administrator
3. If you have admin role but still see error, contact support

---

### 🔄 "Failed to fetch" or "CORS error"

**What it means**: Configuration issue with edge function

**Quick Fix** (For Administrators):
1. Check edge function is deployed:
   ```bash
   supabase functions list
   ```
2. Verify environment variables are set:
   - SUPABASE_URL
   - SUPABASE_SERVICE_ROLE_KEY
3. Redeploy edge function:
   ```bash
   supabase functions deploy import-staff-users
   ```

---

## Debugging Steps

### For End Users:
1. Check the full error message (includes technical details)
2. Try the Quick Fix listed above
3. If still failing, contact your administrator with:
   - Screenshot of the error
   - What you were trying to do
   - Your username/email

### For Administrators:

#### Check User Roles
```sql
-- See all users and their roles
SELECT p.email, ur.role
FROM profiles p
LEFT JOIN user_roles ur ON p.user_id = ur.user_id
ORDER BY p.email;
```

#### Grant Admin Access
```sql
-- Grant admin role to a user
INSERT INTO user_roles (user_id, role)
VALUES ('user-uuid-here', 'admin')
ON CONFLICT DO NOTHING;
```

#### Check RLS Policies
```sql
-- Verify RLS is enabled
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename IN ('shared_folders', 'user_groups', 'user_group_members');
```

#### View Edge Function Logs
1. Go to Supabase Dashboard
2. Navigate to Edge Functions
3. Select 'import-staff-users'
4. Click 'Logs' tab
5. Look for errors or warnings

---

## Getting More Help

### Check These Resources First:
- `ERROR_HANDLING_FIXES.md` - Comprehensive fix documentation
- Browser Console (F12) - Full error details and logs
- Supabase Logs - Edge function execution logs

### Contact Support With:
1. **Error Message** - Full text including technical details
2. **Browser Console Logs** - Screenshot or copy/paste
3. **Steps to Reproduce** - What you clicked, in order
4. **User Info** - Your email and role
5. **Environment** - Browser, OS, time of error

### SQL Diagnostics to Run:
```sql
-- Check your roles
SELECT * FROM user_roles WHERE user_id = auth.uid();

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'shared_folders';

-- Check recent errors (if you have access)
SELECT * FROM auth.users WHERE email = 'your-email@example.com';
```

---

## Prevention Tips

### For Admins:
- Regularly audit user roles
- Set up monitoring for edge function errors
- Keep Supabase project updated
- Document which users should have admin access

### For Users:
- Don't close browser during operations
- Use strong, stable internet connection
- Keep session active (don't leave logged in idle too long)
- Report errors immediately with full details

---

## Emergency Contacts

If you encounter an error not listed here or the Quick Fixes don't work:

1. **First**: Check `ERROR_HANDLING_FIXES.md`
2. **Then**: Contact your system administrator
3. **Include**: Full error message, browser console logs, steps to reproduce
