# Testing Guide: Tickets and Shared Files Fixes

## Overview
This document guides you through testing the fixes for tickets user display and shared files enhancements.

## Prerequisites
1. Deploy the database migration: `supabase/migrations/20251118092000_add_file_version_history.sql`
2. Build and deploy the updated application
3. Have at least one admin user account to test with

## Test Cases

### 1. Tickets - User Display Fix

#### Test Case 1.1: View Tickets List
**Steps:**
1. Log in as an admin user
2. Navigate to Tickets page
3. Look at any ticket in the Open, Pending, Resolved, or Closed tabs

**Expected Results:**
- Each ticket should show:
  - ✍️ Created by: [User's full name or email] (not "user not found")
  - 👥 Assigned to/Resolved by/Closed by: [User's name] (if assigned)
  - All other ticket information (branch, fault type, date, etc.)
- NO blank tickets should appear
- NO "user not found" errors

#### Test Case 1.2: View Ticket Details
**Steps:**
1. Click on any ticket to open the detail sheet
2. Scroll through the ticket information

**Expected Results:**
- "Created By" section shows the creator's name or email
- "Assigned To" section shows the assignee's name (if assigned)
- All other fields display correctly

### 2. Shared Files - Folder Rename

#### Test Case 2.1: Rename a Folder
**Steps:**
1. Navigate to Shared Files page
2. Hover over any folder card
3. Click the Edit (✏️) icon button
4. Enter a new name in the dialog
5. Click "Rename"

**Expected Results:**
- Dialog opens with current folder name pre-filled
- After clicking "Rename", folder name updates immediately
- Success toast message appears: "Folder renamed successfully"
- Folder maintains all its contents and permissions

#### Test Case 2.2: Cancel Folder Rename
**Steps:**
1. Open rename dialog for a folder
2. Change the name
3. Click "Cancel"

**Expected Results:**
- Dialog closes
- Folder name remains unchanged
- No changes saved to database

### 3. Shared Files - Version History

#### Test Case 3.1: View Version History
**Steps:**
1. Navigate to Shared Files
2. Find a file in the file table
3. Click the History (🕐) icon button

**Expected Results:**
- Version History dialog opens
- If no versions exist: "No version history available for this file."
- If versions exist, table shows:
  - Version number (v1, v2, v3, etc.)
  - Modified by (user's name or email)
  - Date and time of modification
  - File size
  - Change notes (if any)

#### Test Case 3.2: Create Version History
**Note:** Version history is automatically created when files are modified. To test:

**Steps:**
1. Upload a file to a folder
2. (In future) Re-upload the same file with changes
3. View version history

**Expected Results:**
- Each modification creates a new version
- Versions are numbered sequentially
- Latest version appears at the top

### 4. Shared Files - Last Modified Display

#### Test Case 4.1: View Last Modified Date
**Steps:**
1. Navigate to Shared Files
2. Look at the file table

**Expected Results:**
- New "Last Modified" column appears between "Uploaded" and "Actions"
- Files show:
  - Clock icon (🕐) + date for modified files
  - "-" for files that haven't been modified since upload
- Date format matches other date displays

### 5. Regression Testing

#### Test Case 5.1: Existing Functionality
**Steps:**
1. Create a new ticket
2. Create a new folder
3. Upload a file
4. Download a file
5. Delete a folder
6. Delete a file

**Expected Results:**
- All existing functionality works as before
- No errors in console
- No broken UI elements

## Known Limitations

1. **Version History Trigger**: Versions are only created when files are actually modified in the database. Initial upload doesn't create a version (to avoid duplication).

2. **File Modification**: Currently, files are uploaded once. Full file modification/replacement functionality would need to be added separately to fully utilize version history.

3. **Profile Data**: If a user doesn't have a profile record, their auth email will be shown instead of a full name.

## Troubleshooting

### Issue: "user not found" still appears
**Solution:**
- Check that users have profile records in the `profiles` table
- Verify the database migration was applied
- Check browser console for any query errors

### Issue: Version history is empty
**Solution:**
- Version history is only created after file modifications
- Initial uploads don't create versions (by design)
- Future file updates will populate the history

### Issue: Folder rename doesn't work
**Solution:**
- Verify user has admin role
- Check browser console for permission errors
- Verify RLS policies allow folder updates

## Database Verification

To verify the migration was applied successfully:

```sql
-- Check if version history table exists
SELECT * FROM information_schema.tables 
WHERE table_name = 'shared_file_versions';

-- Check if last_modified columns exist
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'documents' 
AND column_name IN ('last_modified_by', 'last_modified_at');

-- View version history (if any exists)
SELECT * FROM shared_file_versions 
ORDER BY created_at DESC 
LIMIT 10;
```

## Success Criteria

All fixes are successful if:
- ✅ No "user not found" errors appear in tickets
- ✅ All tickets show creator and assignee information
- ✅ No blank tickets appear
- ✅ Folders can be renamed without issues
- ✅ Version history dialog opens and displays correctly
- ✅ Last modified date shows in file table
- ✅ All existing functionality continues to work

## Support

If issues persist after testing:
1. Check browser console for JavaScript errors
2. Check Supabase logs for database errors
3. Verify all migrations have been applied
4. Ensure user has appropriate roles (admin for shared files)
