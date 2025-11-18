-- ============================================================================
-- LOCAL SETUP - COMPLETE DATABASE SCHEMA
-- ============================================================================
-- This script sets up ALL tables needed for local development
-- Run this ONCE when setting up a new local Supabase instance
-- 
-- PREREQUISITE: You must have Supabase running locally
-- See LOCAL_SETUP.md for instructions on starting local Supabase
-- 
-- HOW TO USE:
-- 1. Start local Supabase: npx supabase start
-- 2. Open Supabase Studio: http://localhost:54323
-- 3. Go to SQL Editor
-- 4. Copy and paste this ENTIRE file
-- 5. Click "Run"
-- 
-- This script is safe to run multiple times (uses IF NOT EXISTS)
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create enum types
DO $$ BEGIN
  CREATE TYPE public.ticket_status AS ENUM ('open', 'in_progress', 'pending', 'resolved', 'closed');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE public.ticket_priority AS ENUM ('low', 'medium', 'high', 'urgent');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE public.asset_status AS ENUM ('active', 'maintenance', 'retired', 'disposed');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin', 'ceo', 'support_staff', 'user');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Create handle_updated_at function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  email TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- User roles table
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role public.app_role DEFAULT 'user' NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (user_id)
);

-- Tickets table
CREATE TABLE IF NOT EXISTS public.tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  status public.ticket_status DEFAULT 'open' NOT NULL,
  priority public.ticket_priority DEFAULT 'medium' NOT NULL,
  category TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  closed_at TIMESTAMPTZ,
  closed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Ticket comments table
CREATE TABLE IF NOT EXISTS public.ticket_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID REFERENCES public.tickets(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Assets table
CREATE TABLE IF NOT EXISTS public.assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_tag TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  status public.asset_status DEFAULT 'active' NOT NULL,
  location TEXT,
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  purchase_date DATE,
  warranty_expiry DATE,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Documents table (required for shared files)
CREATE TABLE IF NOT EXISTS public.documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  filename TEXT NOT NULL,
  original_filename TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  storage_path TEXT NOT NULL,
  storage_bucket TEXT NOT NULL DEFAULT 'documents',
  category TEXT NOT NULL DEFAULT 'general',
  description TEXT,
  tags TEXT[],
  page_location TEXT,
  moved_from TEXT,
  moved_at TIMESTAMPTZ,
  moved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================================
-- USER GROUPS AND PERMISSIONS
-- ============================================================================

-- User groups table
CREATE TABLE IF NOT EXISTS public.user_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- User group members table
CREATE TABLE IF NOT EXISTS public.user_group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES public.user_groups(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  added_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  added_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (group_id, user_id)
);

-- Group permissions table
CREATE TABLE IF NOT EXISTS public.group_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES public.user_groups(id) ON DELETE CASCADE NOT NULL,
  permission_type TEXT NOT NULL,
  can_view BOOLEAN DEFAULT false,
  can_create BOOLEAN DEFAULT false,
  can_update BOOLEAN DEFAULT false,
  can_delete BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (group_id, permission_type)
);

-- User permissions table
CREATE TABLE IF NOT EXISTS public.user_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  permission_type TEXT NOT NULL,
  can_view BOOLEAN DEFAULT false,
  can_create BOOLEAN DEFAULT false,
  can_update BOOLEAN DEFAULT false,
  can_delete BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (user_id, permission_type)
);

-- ============================================================================
-- SHARED FILES SYSTEM
-- ============================================================================

-- Shared files table
CREATE TABLE IF NOT EXISTS public.shared_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID REFERENCES public.documents(id) ON DELETE CASCADE NOT NULL,
  shared_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  shared_with_user UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  shared_with_group UUID REFERENCES public.user_groups(id) ON DELETE CASCADE,
  permission_level TEXT DEFAULT 'view' NOT NULL,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  CHECK (
    (shared_with_user IS NOT NULL AND shared_with_group IS NULL) OR
    (shared_with_user IS NULL AND shared_with_group IS NOT NULL)
  )
);

-- Shared folders table
CREATE TABLE IF NOT EXISTS public.shared_folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  parent_folder_id UUID REFERENCES public.shared_folders(id) ON DELETE CASCADE,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Shared folder files table
CREATE TABLE IF NOT EXISTS public.shared_folder_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  filename TEXT NOT NULL,
  original_filename TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  storage_path TEXT NOT NULL,
  folder_id UUID REFERENCES public.shared_folders(id) ON DELETE CASCADE,
  uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Shared folder permissions table
CREATE TABLE IF NOT EXISTS public.shared_folder_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_id UUID REFERENCES public.shared_folders(id) ON DELETE CASCADE NOT NULL,
  user_group_id UUID REFERENCES public.user_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  can_view BOOLEAN DEFAULT false,
  can_upload BOOLEAN DEFAULT false,
  can_download BOOLEAN DEFAULT false,
  can_delete BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  CHECK (
    (user_group_id IS NOT NULL AND user_id IS NULL) OR
    (user_group_id IS NULL AND user_id IS NOT NULL)
  )
);

-- ============================================================================
-- CREATE INDEXES
-- ============================================================================

-- Profiles indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- User roles indexes
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON public.user_roles(role);

-- Tickets indexes
CREATE INDEX IF NOT EXISTS idx_tickets_status ON public.tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_created_by ON public.tickets(created_by);
CREATE INDEX IF NOT EXISTS idx_tickets_assigned_to ON public.tickets(assigned_to);

-- Ticket comments indexes
CREATE INDEX IF NOT EXISTS idx_ticket_comments_ticket_id ON public.ticket_comments(ticket_id);

-- Assets indexes
CREATE INDEX IF NOT EXISTS idx_assets_status ON public.assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_assigned_to ON public.assets(assigned_to);

-- Documents indexes
CREATE INDEX IF NOT EXISTS idx_documents_uploaded_by ON public.documents(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_documents_category ON public.documents(category);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON public.documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_file_type ON public.documents(file_type);
CREATE INDEX IF NOT EXISTS idx_documents_page_location ON public.documents(page_location);

-- User groups indexes
CREATE INDEX IF NOT EXISTS idx_user_group_members_group_id ON public.user_group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_user_group_members_user_id ON public.user_group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_group_permissions_group_id ON public.group_permissions(group_id);
CREATE INDEX IF NOT EXISTS idx_user_permissions_user_id ON public.user_permissions(user_id);

-- Shared files indexes
CREATE INDEX IF NOT EXISTS idx_shared_files_document_id ON public.shared_files(document_id);
CREATE INDEX IF NOT EXISTS idx_shared_files_shared_by ON public.shared_files(shared_by);
CREATE INDEX IF NOT EXISTS idx_shared_files_shared_with_user ON public.shared_files(shared_with_user);
CREATE INDEX IF NOT EXISTS idx_shared_files_shared_with_group ON public.shared_files(shared_with_group);
CREATE INDEX IF NOT EXISTS idx_shared_folders_parent ON public.shared_folders(parent_folder_id);
CREATE INDEX IF NOT EXISTS idx_shared_folders_created_by ON public.shared_folders(created_by);
CREATE INDEX IF NOT EXISTS idx_shared_folder_files_folder ON public.shared_folder_files(folder_id);
CREATE INDEX IF NOT EXISTS idx_shared_folder_files_uploaded_by ON public.shared_folder_files(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_shared_folder_permissions_folder ON public.shared_folder_permissions(folder_id);
CREATE INDEX IF NOT EXISTS idx_shared_folder_permissions_group ON public.shared_folder_permissions(user_group_id);
CREATE INDEX IF NOT EXISTS idx_shared_folder_permissions_user ON public.shared_folder_permissions(user_id);

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_folder_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_folder_permissions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CREATE RLS POLICIES
-- ============================================================================

-- Profiles policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (id = auth.uid());

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid());

-- User roles policies
DROP POLICY IF EXISTS "Users can view own role" ON public.user_roles;
CREATE POLICY "Users can view own role"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins can manage all roles" ON public.user_roles;
CREATE POLICY "Admins can manage all roles"
  ON public.user_roles FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Tickets policies
DROP POLICY IF EXISTS "Users can view own tickets" ON public.tickets;
CREATE POLICY "Users can view own tickets"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (
    created_by = auth.uid() 
    OR assigned_to = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() 
      AND role IN ('admin', 'ceo', 'support_staff')
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create tickets" ON public.tickets;
CREATE POLICY "Authenticated users can create tickets"
  ON public.tickets FOR INSERT
  TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update tickets" ON public.tickets;
CREATE POLICY "Users can update tickets"
  ON public.tickets FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() 
      AND role IN ('admin', 'ceo', 'support_staff')
    )
  );

DROP POLICY IF EXISTS "Admins can delete tickets" ON public.tickets;
CREATE POLICY "Admins can delete tickets"
  ON public.tickets FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Ticket comments policies
DROP POLICY IF EXISTS "Users can view ticket comments" ON public.ticket_comments;
CREATE POLICY "Users can view ticket comments"
  ON public.ticket_comments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.tickets
      WHERE id = ticket_id
      AND (
        created_by = auth.uid()
        OR assigned_to = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.user_roles
          WHERE user_id = auth.uid() 
          AND role IN ('admin', 'ceo', 'support_staff')
        )
      )
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create comments" ON public.ticket_comments;
CREATE POLICY "Authenticated users can create comments"
  ON public.ticket_comments FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Assets policies
DROP POLICY IF EXISTS "Admins can manage assets" ON public.assets;
CREATE POLICY "Admins can manage assets"
  ON public.assets FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() 
      AND role IN ('admin', 'ceo')
    )
  );

-- Documents policies
DROP POLICY IF EXISTS "Authenticated users can view all documents" ON public.documents;
CREATE POLICY "Authenticated users can view all documents"
  ON public.documents FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can upload documents" ON public.documents;
CREATE POLICY "Authenticated users can upload documents"
  ON public.documents FOR INSERT
  TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated users can update documents" ON public.documents;
CREATE POLICY "Authenticated users can update documents"
  ON public.documents FOR UPDATE
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can delete documents" ON public.documents;
CREATE POLICY "Authenticated users can delete documents"
  ON public.documents FOR DELETE
  TO authenticated
  USING (true);

-- User groups policies
DROP POLICY IF EXISTS "Authenticated users can view groups" ON public.user_groups;
CREATE POLICY "Authenticated users can view groups"
  ON public.user_groups FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins can manage groups" ON public.user_groups;
CREATE POLICY "Admins can manage groups"
  ON public.user_groups FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- User group members policies
DROP POLICY IF EXISTS "Users can view group memberships" ON public.user_group_members;
CREATE POLICY "Users can view group memberships"
  ON public.user_group_members FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins can manage group memberships" ON public.user_group_members;
CREATE POLICY "Admins can manage group memberships"
  ON public.user_group_members FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Group permissions policies
DROP POLICY IF EXISTS "Users can view group permissions" ON public.group_permissions;
CREATE POLICY "Users can view group permissions"
  ON public.group_permissions FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins can manage group permissions" ON public.group_permissions;
CREATE POLICY "Admins can manage group permissions"
  ON public.group_permissions FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- User permissions policies
DROP POLICY IF EXISTS "Users can view own permissions" ON public.user_permissions;
CREATE POLICY "Users can view own permissions"
  ON public.user_permissions FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can manage user permissions" ON public.user_permissions;
CREATE POLICY "Admins can manage user permissions"
  ON public.user_permissions FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Shared files policies
DROP POLICY IF EXISTS "Users can view files shared with them" ON public.shared_files;
CREATE POLICY "Users can view files shared with them"
  ON public.shared_files FOR SELECT
  TO authenticated
  USING (
    shared_by = auth.uid()
    OR shared_with_user = auth.uid()
    OR shared_with_group IN (
      SELECT group_id FROM public.user_group_members
      WHERE user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Users can share files" ON public.shared_files;
CREATE POLICY "Users can share files"
  ON public.shared_files FOR INSERT
  TO authenticated
  WITH CHECK (
    shared_by = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Users can manage their shares" ON public.shared_files;
CREATE POLICY "Users can manage their shares"
  ON public.shared_files FOR UPDATE
  TO authenticated
  USING (
    shared_by = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Users can delete their shares" ON public.shared_files;
CREATE POLICY "Users can delete their shares"
  ON public.shared_files FOR DELETE
  TO authenticated
  USING (
    shared_by = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Shared folders policies
DROP POLICY IF EXISTS "Users can view folders they have permission to" ON public.shared_folders;
CREATE POLICY "Users can view folders they have permission to"
  ON public.shared_folders FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR EXISTS (
      SELECT 1 FROM public.shared_folder_permissions
      WHERE folder_id = shared_folders.id
      AND can_view = true
      AND (
        user_id = auth.uid()
        OR user_group_id IN (
          SELECT group_id FROM public.user_group_members
          WHERE user_id = auth.uid()
        )
      )
    )
    OR created_by = auth.uid()
  );

DROP POLICY IF EXISTS "Admins can manage folders" ON public.shared_folders;
CREATE POLICY "Admins can manage folders"
  ON public.shared_folders FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Shared folder files policies
DROP POLICY IF EXISTS "Users can view files in accessible folders" ON public.shared_folder_files;
CREATE POLICY "Users can view files in accessible folders"
  ON public.shared_folder_files FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR EXISTS (
      SELECT 1 FROM public.shared_folder_permissions
      WHERE folder_id = shared_folder_files.folder_id
      AND can_view = true
      AND (
        user_id = auth.uid()
        OR user_group_id IN (
          SELECT group_id FROM public.user_group_members
          WHERE user_id = auth.uid()
        )
      )
    )
    OR uploaded_by = auth.uid()
  );

DROP POLICY IF EXISTS "Users can upload files to folders with permission" ON public.shared_folder_files;
CREATE POLICY "Users can upload files to folders with permission"
  ON public.shared_folder_files FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR EXISTS (
      SELECT 1 FROM public.shared_folder_permissions
      WHERE folder_id = shared_folder_files.folder_id
      AND can_upload = true
      AND (
        user_id = auth.uid()
        OR user_group_id IN (
          SELECT group_id FROM public.user_group_members
          WHERE user_id = auth.uid()
        )
      )
    )
  );

DROP POLICY IF EXISTS "Users can delete files with permission" ON public.shared_folder_files;
CREATE POLICY "Users can delete files with permission"
  ON public.shared_folder_files FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR EXISTS (
      SELECT 1 FROM public.shared_folder_permissions
      WHERE folder_id = shared_folder_files.folder_id
      AND can_delete = true
      AND (
        user_id = auth.uid()
        OR user_group_id IN (
          SELECT group_id FROM public.user_group_members
          WHERE user_id = auth.uid()
        )
      )
    )
    OR uploaded_by = auth.uid()
  );

-- Shared folder permissions policies
DROP POLICY IF EXISTS "Admins and users can view permissions" ON public.shared_folder_permissions;
CREATE POLICY "Admins and users can view permissions"
  ON public.shared_folder_permissions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR user_id = auth.uid()
    OR user_group_id IN (
      SELECT group_id FROM public.user_group_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can manage permissions" ON public.shared_folder_permissions;
CREATE POLICY "Admins can manage permissions"
  ON public.shared_folder_permissions FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- CREATE TRIGGERS
-- ============================================================================

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_user_roles_updated_at ON public.user_roles;
CREATE TRIGGER update_user_roles_updated_at
  BEFORE UPDATE ON public.user_roles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_tickets_updated_at ON public.tickets;
CREATE TRIGGER update_tickets_updated_at
  BEFORE UPDATE ON public.tickets
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_assets_updated_at ON public.assets;
CREATE TRIGGER update_assets_updated_at
  BEFORE UPDATE ON public.assets
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_documents_updated_at ON public.documents;
CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON public.documents
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_user_groups_updated_at ON public.user_groups;
CREATE TRIGGER update_user_groups_updated_at
  BEFORE UPDATE ON public.user_groups
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_user_permissions_updated_at ON public.user_permissions;
CREATE TRIGGER update_user_permissions_updated_at
  BEFORE UPDATE ON public.user_permissions
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_shared_folders_updated_at ON public.shared_folders;
CREATE TRIGGER update_shared_folders_updated_at
  BEFORE UPDATE ON public.shared_folders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_shared_folder_files_updated_at ON public.shared_folder_files;
CREATE TRIGGER update_shared_folder_files_updated_at
  BEFORE UPDATE ON public.shared_folder_files
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS update_shared_folder_permissions_updated_at ON public.shared_folder_permissions;
CREATE TRIGGER update_shared_folder_permissions_updated_at
  BEFORE UPDATE ON public.shared_folder_permissions
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- ADD COMMENTS
-- ============================================================================

COMMENT ON TABLE public.profiles IS 'User profile information';
COMMENT ON TABLE public.user_roles IS 'User role assignments (admin, ceo, support_staff, user)';
COMMENT ON TABLE public.tickets IS 'Support tickets';
COMMENT ON TABLE public.ticket_comments IS 'Comments on support tickets';
COMMENT ON TABLE public.assets IS 'Company assets (laptops, monitors, etc.)';
COMMENT ON TABLE public.documents IS 'Stores metadata for all documents uploaded to the Document Hub';
COMMENT ON TABLE public.user_groups IS 'User groups for organizing users and managing permissions';
COMMENT ON TABLE public.user_group_members IS 'Junction table for user group membership';
COMMENT ON TABLE public.group_permissions IS 'System permissions granted to user groups';
COMMENT ON TABLE public.user_permissions IS 'Individual user permissions for system features';
COMMENT ON TABLE public.shared_files IS 'File sharing between users and groups';
COMMENT ON TABLE public.shared_folders IS 'Folder structure for organizing shared files';
COMMENT ON TABLE public.shared_folder_files IS 'Files stored in shared folders';
COMMENT ON TABLE public.shared_folder_permissions IS 'Permissions for accessing shared folders';

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ LOCAL SETUP COMPLETE!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'All tables created successfully:';
  RAISE NOTICE '  ✓ Core tables (profiles, user_roles, tickets, assets)';
  RAISE NOTICE '  ✓ Documents table';
  RAISE NOTICE '  ✓ User groups and permissions';
  RAISE NOTICE '  ✓ Shared files system';
  RAISE NOTICE '';
  RAISE NOTICE 'All RLS policies applied successfully!';
  RAISE NOTICE 'All indexes created successfully!';
  RAISE NOTICE 'All triggers created successfully!';
  RAISE NOTICE '';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '  1. Create a user account in your app';
  RAISE NOTICE '  2. Your app is ready to use!';
  RAISE NOTICE '';
  RAISE NOTICE 'Access your local Supabase:';
  RAISE NOTICE '  - App: http://localhost:8080';
  RAISE NOTICE '  - Supabase Studio: http://localhost:54323';
  RAISE NOTICE '  - Email Testing: http://localhost:54324';
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
END $$;
