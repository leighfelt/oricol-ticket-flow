# RLS Policy Fixes & NTFS File Permissions Guide

**Date:** 2025-11-18  
**Version:** 2.0  
**Features:** User Role Management Fix + NTFS File Permissions

---

## Overview

This guide covers two major improvements to the Oricol Helpdesk system:

1. **Fixed RLS Policies** - Admins can now manage user roles via secure edge function
2. **NTFS-Style File Permissions** - Enterprise-grade file permission system with inheritance

---

## Part 1: User Role Management Fix

### Problem

After implementing security fixes to prevent privilege escalation (migration `20251117102836`), the `user_roles` table was locked down so only service_role could modify roles. This broke the admin UI for managing user roles on the Staff Users page.

**Error Message:**
```
Failed to update user roles: new row violates row-level security policy
```

### Solution: Edge Function for Role Management

Instead of allowing direct database access, we created a secure edge function that:
- ✅ Validates the admin's JWT token
- ✅ Checks if user has admin role
- ✅ Uses service role to bypass RLS (securely)
- ✅ Provides comprehensive logging

### How It Works

#### Architecture

```
User Interface (Users.tsx)
    ↓
Edge Function (manage-user-roles)
    ↓ Validates admin
    ↓ Uses service role
    ↓
Database (user_roles table)
```

#### Edge Function: `manage-user-roles`

**Endpoint:** `supabase.functions.invoke('manage-user-roles')`

**Request Body:**
```typescript
{
  targetUserId: string,     // UUID of user to modify
  rolesToSet: string[]      // Array of roles to assign
}
```

**Response:**
```typescript
{
  success: boolean,
  message: string,
  rolesSet: string[]
}
```

**Security:**
- Only admins can call this function
- JWT token validated before any action
- Service role used only after admin verification
- Comprehensive audit logging

#### Updated Client Code

**Before (Direct DB Access - Broken):**
```typescript
// This fails due to RLS policies
await supabase
  .from("user_roles")
  .delete()
  .eq("user_id", userId);
```

**After (Edge Function - Works):**
```typescript
// This works securely via edge function
const { data, error } = await supabase.functions.invoke('manage-user-roles', {
  body: {
    targetUserId: systemUser.user_id,
    rolesToSet: editRoles,
  },
});
```

### Using the Fixed System

#### Managing User Roles (Admin UI)

1. **Navigate to Users Page**
   - Click "Users" in sidebar
   - Go to "System Users" tab

2. **Edit User Roles**
   - Click on a user to open details
   - Check/uncheck roles:
     - ☐ admin
     - ☐ ceo
     - ☐ support_staff
     - ☐ user

3. **Save Changes**
   - Click "Save" button
   - Changes applied via edge function
   - Success message appears

#### Available Roles

| Role | Description | Access Level |
|------|-------------|--------------|
| `admin` | Full system access | Everything including System Users |
| `ceo` | Executive access | Everything except System Users |
| `support_staff` | Support team member | Tickets, Users, Reports, VPN, RDP |
| `user` | Basic user | Tickets and Remote Support only |

### Troubleshooting

#### "Unauthorized: Admin access required"

**Cause:** You're not logged in as an admin.

**Solution:**
1. Ensure you're logged in with an admin account
2. Check your roles in the database:
   ```sql
   SELECT role FROM user_roles WHERE user_id = auth.uid();
   ```

#### "Failed to update user roles"

**Cause:** Edge function not deployed or network issue.

**Solution:**
1. Deploy the edge function:
   ```bash
   npx supabase functions deploy manage-user-roles
   ```
2. Check Supabase logs for errors
3. Verify network connectivity

---

## Part 2: NTFS-Style File Permissions

### Overview

We've implemented a Windows NTFS-style permission system for the shared files and document hub. This provides enterprise-grade file security with:

- ✅ Four permission levels (Read, Write, Modify, Full Control)
- ✅ Permission inheritance (folders → subfolders → files)
- ✅ Allow/Deny rules (Deny always wins)
- ✅ Group-based permissions
- ✅ User-specific overrides

### Permission Levels

#### 1. Read
**Can:**
- View folders
- View files
- Download files

**Cannot:**
- Upload files
- Modify files
- Delete files
- Change permissions

**Use Case:** Users who need to view documentation but not modify it.

#### 2. Write
**Can:**
- Everything in Read
- Upload new files
- Create subfolders

**Cannot:**
- Modify existing files (unless owner)
- Delete files (unless owner)
- Change permissions

**Use Case:** Users who need to contribute files but not modify others' work.

#### 3. Modify
**Can:**
- Everything in Write
- Edit own files
- Delete own files
- Edit files uploaded by others (if permission granted)

**Cannot:**
- Delete others' files (without full_control)
- Change permissions

**Use Case:** Team members who collaborate on shared documents.

#### 4. Full Control
**Can:**
- Everything in Modify
- Delete any file in folder
- Manage permissions for folder
- Grant/revoke access to others

**Cannot:**
- Nothing (has full access)

**Use Case:** Folder owners, administrators, project managers.

### Permission Inheritance

Permissions automatically inherit from parent folders to child folders and files.

**Example:**
```
📁 Marketing (User has "Write" permission)
  ├── 📁 Campaigns (Inherits "Write")
  │   ├── 📄 Q1_Plan.docx (Inherits "Write")
  │   └── 📄 Budget.xlsx (Inherits "Write")
  └── 📁 Analytics (Inherits "Write")
      └── 📄 Monthly_Report.pdf (Inherits "Write")
```

**Breaking Inheritance:**
You can set explicit permissions on a subfolder to override inherited permissions.

```
📁 Marketing (User has "Write")
  ├── 📁 Public (Explicit "Read" - more restrictive)
  └── 📁 Management (Explicit "Full Control" - more permissive)
```

### Allow vs Deny Rules

**Priority:** Deny rules ALWAYS override Allow rules.

**Example:**
- User Group "Sales" has "Write" permission (ALLOW)
- User "john@company.com" has "Read" permission (DENY)
- Result: John can only Read (Deny wins)

**Use Cases for Deny:**
- Temporarily revoke access without removing from group
- Block specific users from sensitive folders
- Prevent accidental deletions

### Database Functions

#### `has_folder_permission(folder_id, user_id, required_level)`

Checks if a user has a specific permission level on a folder.

**Parameters:**
- `folder_id` (UUID): Folder to check
- `user_id` (UUID): User to check
- `required_level` (enum): Permission level needed

**Returns:** `BOOLEAN`

**Example:**
```sql
SELECT has_folder_permission(
  '123e4567-e89b-12d3-a456-426614174000',
  auth.uid(),
  'write'
);
```

#### `get_effective_permission(folder_id, user_id)`

Gets the effective permission level for a user, including inheritance.

**Parameters:**
- `folder_id` (UUID): Folder to check
- `user_id` (UUID): User to check

**Returns:** `file_permission_level` enum or NULL

**Example:**
```sql
SELECT get_effective_permission(
  '123e4567-e89b-12d3-a456-426614174000',
  auth.uid()
);
```

### Setting Up Permissions

#### Via Database (Administrators)

**Grant User Permission:**
```sql
INSERT INTO shared_folder_permissions (folder_id, user_id, permission_level, permission_type)
VALUES (
  '123e4567-e89b-12d3-a456-426614174000',  -- folder ID
  'user-uuid-here',                          -- user ID
  'modify',                                  -- permission level
  'allow'                                    -- allow or deny
);
```

**Grant Group Permission:**
```sql
INSERT INTO shared_folder_permissions (folder_id, user_group_id, permission_level, permission_type)
VALUES (
  '123e4567-e89b-12d3-a456-426614174000',  -- folder ID
  'group-uuid-here',                        -- group ID
  'write',                                  -- permission level
  'allow'                                   -- allow or deny
);
```

**Deny User Access:**
```sql
INSERT INTO shared_folder_permissions (folder_id, user_id, permission_level, permission_type)
VALUES (
  '123e4567-e89b-12d3-a456-426614174000',
  'user-uuid-here',
  'read',                                   -- minimum level to deny
  'deny'                                    -- this overrides any allow rules
);
```

#### Via UI (Coming Soon)

A permission management UI is planned for future releases.

### Permission Examples

#### Example 1: Department Folder Structure

```
📁 Company Files (Admin: Full Control)
  ├── 📁 HR (HR Group: Full Control, All Staff: Read)
  │   ├── 📁 Policies (HR Group: Modify, All Staff: Read)
  │   └── 📁 Confidential (HR Group: Full Control, Deny: All Others)
  ├── 📁 Sales (Sales Group: Modify, Sales Manager: Full Control)
  └── 📁 Public (All Staff: Write)
```

#### Example 2: Project Collaboration

```
📁 Project Alpha
  ├── Permission: Project Team = Modify (ALLOW)
  ├── Permission: Project Manager = Full Control (ALLOW)
  ├── Permission: john@company.com = Read (DENY - on leave)
  │
  ├── 📁 Deliverables (inherits Project Team = Modify)
  ├── 📁 Internal (inherits Project Team = Modify)
  └── 📁 Client Facing
      └── Permission: Client User = Read (ALLOW)
```

### Migration from Old System

The migration automatically converts old permissions:

| Old Permission | New Permission Level |
|----------------|---------------------|
| `can_delete = true` | `full_control` |
| `can_upload = true` | `modify` |
| `can_download = true` | `write` |
| `can_view = true` | `read` |

All existing permissions are set to `allow` type by default.

### Best Practices

#### 1. Use Groups for Most Permissions
❌ Bad: Assign permissions to 50 individual users  
✅ Good: Create "Sales Team" group, assign permission to group

#### 2. Deny Rules Sparingly
❌ Bad: Deny everyone except 2 people  
✅ Good: Only grant access to those 2 people

#### 3. Inherit When Possible
❌ Bad: Set explicit permissions on every subfolder  
✅ Good: Set permission on parent, let subfolders inherit

#### 4. Start Restrictive
❌ Bad: Give everyone Full Control, then deny specific users  
✅ Good: Give minimum needed permissions, grant more as needed

#### 5. Document Your Structure
✅ Use folder descriptions to explain permission structure  
✅ Keep a document listing who has access to what

---

## Deployment Instructions

### 1. Deploy Edge Function

```bash
# Deploy the manage-user-roles function
npx supabase functions deploy manage-user-roles
```

### 2. Apply Migration

**Option A: Migration Manager (Easiest)**
1. Open Dashboard → Overview tab
2. Click "Apply Migrations" button
3. Wait for completion

**Option B: CLI**
```bash
npx supabase db push
```

**Option C: SQL Editor**
1. Copy contents of `20251118105000_fix_rls_and_ntfs_permissions.sql`
2. Paste into Supabase SQL Editor
3. Click "Run"

### 3. Verify Installation

**Check Edge Function:**
```bash
# List deployed functions
npx supabase functions list
```

**Check Migration:**
```sql
-- Verify migration applied
SELECT * FROM schema_migrations
WHERE version = '20251118105000_fix_rls_and_ntfs_permissions';

-- Check NTFS permission levels exist
SELECT enum_range(NULL::file_permission_level);
```

**Test Role Management:**
1. Log in as admin
2. Go to Users → System Users
3. Edit a user's roles
4. Should save successfully

---

## Troubleshooting

### User Role Management Issues

#### "new row violates row-level security policy"

**Cause:** Edge function not deployed or not being used.

**Solution:**
1. Ensure edge function deployed: `npx supabase functions deploy manage-user-roles`
2. Verify client code uses edge function (not direct DB access)
3. Check browser console for errors

### NTFS Permission Issues

#### "Access Denied" when uploading files

**Cause:** User doesn't have Write or higher permission.

**Solution:**
Check permissions:
```sql
SELECT permission_level, permission_type
FROM shared_folder_permissions
WHERE folder_id = 'your-folder-id'
AND (
  user_id = 'your-user-id'
  OR user_group_id IN (
    SELECT group_id FROM user_group_members
    WHERE user_id = 'your-user-id'
  )
);
```

#### Inherited permissions not working

**Cause:** Permission inheritance function not created.

**Solution:**
1. Verify migration applied
2. Check function exists:
   ```sql
   SELECT proname FROM pg_proc WHERE proname = 'get_effective_permission';
   ```

---

## Security Considerations

### User Role Management

✅ **Secure:**
- Edge function validates admin status
- Service role used only after verification
- Audit logging for all changes
- Cannot escalate own privileges

### NTFS File Permissions

✅ **Secure:**
- Deny rules always override allow
- Admins still have full access (important for management)
- RLS policies enforce permissions at database level
- Inheritance prevents permission gaps

⚠️ **Important:**
- Admins can always bypass permissions (by design)
- Review permissions regularly
- Use deny rules carefully (hard to troubleshoot)

---

## Related Documentation

- [Migration Manager Guide](./MIGRATION_MANAGER_GUIDE.md) - How to apply migrations
- [Implementation Summary](./IMPLEMENTATION_SUMMARY_COMPLETE.md) - Technical details
- [Security Summary](./SECURITY_SUMMARY_FINAL.md) - Security considerations

---

## Support

For issues or questions:
1. Check this guide for solutions
2. Review browser console for errors
3. Check Supabase logs in Dashboard
4. Contact development team

---

**Last Updated:** 2025-11-18  
**Version:** 2.0  
**Status:** Production Ready
