-- Fix RLS policies for user_roles to allow admin management
-- Also implement NTFS-style file permissions for shared files system

-- ============================================================================
-- PART 1: Fix user_roles RLS Policies
-- ============================================================================

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;

-- Recreate admin view policy (keep existing)
CREATE POLICY "Admins can view all roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Add new policies for admin role management via edge function
-- Note: Direct client access still blocked, must use manage-user-roles edge function
COMMENT ON TABLE public.user_roles IS 'User role assignments. Admins must use manage-user-roles edge function to modify.';

-- ============================================================================
-- PART 2: NTFS-Style File Permissions System
-- ============================================================================

-- Create enum for NTFS-style permission levels
CREATE TYPE public.file_permission_level AS ENUM (
  'read',           -- Read only (can view/download)
  'write',          -- Read + Write (can upload new files)
  'modify',         -- Read + Write + Modify (can edit/delete own files)
  'full_control'    -- Full access (can manage permissions, delete any file)
);

-- Create enum for permission type (allow/deny)
CREATE TYPE public.permission_type AS ENUM ('allow', 'deny');

-- Add NTFS permission columns to existing shared_folder_permissions table
ALTER TABLE public.shared_folder_permissions 
  ADD COLUMN IF NOT EXISTS permission_level public.file_permission_level DEFAULT 'read',
  ADD COLUMN IF NOT EXISTS permission_type public.permission_type DEFAULT 'allow',
  ADD COLUMN IF NOT EXISTS inherited BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS inherit_from_folder_id UUID REFERENCES public.shared_folders(id) ON DELETE CASCADE;

-- Create index for faster permission lookups
CREATE INDEX IF NOT EXISTS idx_shared_folder_permissions_level 
  ON public.shared_folder_permissions(permission_level);
CREATE INDEX IF NOT EXISTS idx_shared_folder_permissions_type 
  ON public.shared_folder_permissions(permission_type);
CREATE INDEX IF NOT EXISTS idx_shared_folder_permissions_inherited 
  ON public.shared_folder_permissions(inherited);

-- Function to check if user has specific permission level on a folder
CREATE OR REPLACE FUNCTION public.has_folder_permission(
  p_folder_id UUID,
  p_user_id UUID,
  p_required_level public.file_permission_level
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_has_permission BOOLEAN := false;
  v_permission_levels TEXT[] := ARRAY['read', 'write', 'modify', 'full_control'];
  v_required_level_index INT;
  v_user_level_index INT;
  v_explicit_deny BOOLEAN;
BEGIN
  -- Admins always have full control
  IF EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = p_user_id AND role = 'admin'
  ) THEN
    RETURN true;
  END IF;

  -- Check for explicit DENY (deny always wins)
  SELECT EXISTS (
    SELECT 1 FROM public.shared_folder_permissions
    WHERE folder_id = p_folder_id
    AND permission_type = 'deny'
    AND (
      user_id = p_user_id
      OR user_group_id IN (
        SELECT group_id FROM public.user_group_members
        WHERE user_id = p_user_id
      )
    )
  ) INTO v_explicit_deny;

  IF v_explicit_deny THEN
    RETURN false;
  END IF;

  -- Get the index of required permission level
  SELECT array_position(v_permission_levels, p_required_level::TEXT) INTO v_required_level_index;

  -- Check for ALLOW permission (user or group)
  SELECT MAX(array_position(v_permission_levels, permission_level::TEXT))
  INTO v_user_level_index
  FROM public.shared_folder_permissions
  WHERE folder_id = p_folder_id
  AND permission_type = 'allow'
  AND (
    user_id = p_user_id
    OR user_group_id IN (
      SELECT group_id FROM public.user_group_members
      WHERE user_id = p_user_id
    )
  );

  -- User has permission if their level is >= required level
  IF v_user_level_index IS NOT NULL AND v_user_level_index >= v_required_level_index THEN
    RETURN true;
  END IF;

  RETURN false;
END;
$$;

-- Function to check effective permissions (including inheritance)
CREATE OR REPLACE FUNCTION public.get_effective_permission(
  p_folder_id UUID,
  p_user_id UUID
)
RETURNS public.file_permission_level
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_permission public.file_permission_level;
  v_current_folder UUID := p_folder_id;
  v_parent_folder UUID;
  v_depth INT := 0;
  v_max_depth INT := 10; -- Prevent infinite loops
BEGIN
  -- Check direct permissions first (most specific)
  SELECT permission_level INTO v_permission
  FROM public.shared_folder_permissions
  WHERE folder_id = p_folder_id
  AND permission_type = 'allow'
  AND (
    user_id = p_user_id
    OR user_group_id IN (
      SELECT group_id FROM public.user_group_members
      WHERE user_id = p_user_id
    )
  )
  ORDER BY 
    CASE permission_level
      WHEN 'full_control' THEN 4
      WHEN 'modify' THEN 3
      WHEN 'write' THEN 2
      WHEN 'read' THEN 1
    END DESC
  LIMIT 1;

  IF v_permission IS NOT NULL THEN
    RETURN v_permission;
  END IF;

  -- Walk up the folder tree to find inherited permissions
  WHILE v_current_folder IS NOT NULL AND v_depth < v_max_depth LOOP
    SELECT parent_folder_id INTO v_parent_folder
    FROM public.shared_folders
    WHERE id = v_current_folder;

    IF v_parent_folder IS NULL THEN
      EXIT;
    END IF;

    -- Check for permissions on parent folder
    SELECT permission_level INTO v_permission
    FROM public.shared_folder_permissions
    WHERE folder_id = v_parent_folder
    AND permission_type = 'allow'
    AND (
      user_id = p_user_id
      OR user_group_id IN (
        SELECT group_id FROM public.user_group_members
        WHERE user_id = p_user_id
      )
    )
    ORDER BY 
      CASE permission_level
        WHEN 'full_control' THEN 4
        WHEN 'modify' THEN 3
        WHEN 'write' THEN 2
        WHEN 'read' THEN 1
      END DESC
    LIMIT 1;

    IF v_permission IS NOT NULL THEN
      RETURN v_permission;
    END IF;

    v_current_folder := v_parent_folder;
    v_depth := v_depth + 1;
  END LOOP;

  -- No permissions found
  RETURN NULL;
END;
$$;

-- Update RLS policies for shared_folder_files to use new permission system
DROP POLICY IF EXISTS "Users can view files in accessible folders" ON public.shared_folder_files;
DROP POLICY IF EXISTS "Users can upload files to folders with permission" ON public.shared_folder_files;
DROP POLICY IF EXISTS "Users can update files with permission" ON public.shared_folder_files;
DROP POLICY IF EXISTS "Users can delete files with permission" ON public.shared_folder_files;

-- New RLS policies using NTFS-style permissions
CREATE POLICY "Users can view files with read permission"
  ON public.shared_folder_files FOR SELECT
  TO authenticated
  USING (
    -- Admins can see all
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    -- Users with read or higher permission
    public.has_folder_permission(folder_id, auth.uid(), 'read')
    OR
    -- Users can see files they uploaded
    uploaded_by = auth.uid()
  );

CREATE POLICY "Users can upload files with write permission"
  ON public.shared_folder_files FOR INSERT
  TO authenticated
  WITH CHECK (
    -- Admins can upload anywhere
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    -- Users with write or higher permission
    public.has_folder_permission(folder_id, auth.uid(), 'write')
  );

CREATE POLICY "Users can modify own files or files with modify permission"
  ON public.shared_folder_files FOR UPDATE
  TO authenticated
  USING (
    -- Admins can modify all
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    -- Users can modify their own files
    uploaded_by = auth.uid()
    OR
    -- Users with modify or full_control permission
    public.has_folder_permission(folder_id, auth.uid(), 'modify')
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR uploaded_by = auth.uid()
    OR public.has_folder_permission(folder_id, auth.uid(), 'modify')
  );

CREATE POLICY "Users can delete own files or files with full_control permission"
  ON public.shared_folder_files FOR DELETE
  TO authenticated
  USING (
    -- Admins can delete all
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    -- Users can delete their own files if they have modify permission
    (uploaded_by = auth.uid() AND public.has_folder_permission(folder_id, auth.uid(), 'modify'))
    OR
    -- Users with full_control can delete any file
    public.has_folder_permission(folder_id, auth.uid(), 'full_control')
  );

-- Update RLS policies for shared_folder_permissions
DROP POLICY IF EXISTS "Admins can manage folder permissions" ON public.shared_folder_permissions;
DROP POLICY IF EXISTS "Users can view permissions they have access to" ON public.shared_folder_permissions;

CREATE POLICY "Admins and users with full_control can manage permissions"
  ON public.shared_folder_permissions FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    public.has_folder_permission(folder_id, auth.uid(), 'full_control')
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    public.has_folder_permission(folder_id, auth.uid(), 'full_control')
  );

CREATE POLICY "Users can view permissions on folders they can access"
  ON public.shared_folder_permissions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    public.has_folder_permission(folder_id, auth.uid(), 'read')
  );

-- Add helpful comments
COMMENT ON FUNCTION public.has_folder_permission IS 'Checks if user has specific NTFS-style permission level on folder (deny rules override allow rules)';
COMMENT ON FUNCTION public.get_effective_permission IS 'Gets effective permission level including inheritance from parent folders';
COMMENT ON COLUMN public.shared_folder_permissions.permission_level IS 'NTFS-style permission: read, write, modify, or full_control';
COMMENT ON COLUMN public.shared_folder_permissions.permission_type IS 'Allow or Deny (deny always wins)';
COMMENT ON COLUMN public.shared_folder_permissions.inherited IS 'True if this permission was inherited from a parent folder';
COMMENT ON COLUMN public.shared_folder_permissions.inherit_from_folder_id IS 'Folder ID this permission was inherited from';

-- Migrate existing permissions to new system
-- Update all existing permissions to use 'allow' type and appropriate permission level
UPDATE public.shared_folder_permissions
SET permission_type = 'allow'
WHERE permission_type IS NULL;

UPDATE public.shared_folder_permissions
SET permission_level = CASE
  WHEN can_delete = true THEN 'full_control'::public.file_permission_level
  WHEN can_upload = true THEN 'modify'::public.file_permission_level
  WHEN can_download = true THEN 'write'::public.file_permission_level
  ELSE 'read'::public.file_permission_level
END
WHERE permission_level IS NULL;
