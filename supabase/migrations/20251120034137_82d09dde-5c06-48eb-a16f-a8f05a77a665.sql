-- ============================================================================
-- SECURITY FIX: Remove Public Storage Access
-- ============================================================================
-- Fix for: "Storage Buckets Allow Public Read Access"
-- Issue: documents and diagrams buckets are publicly readable
-- Solution: Restrict access to authenticated users only

-- Drop existing public SELECT policies
DROP POLICY IF EXISTS "documents_storage_select" ON storage.objects;
DROP POLICY IF EXISTS "diagrams_storage_select" ON storage.objects;

-- Create authenticated-only SELECT policies for documents
CREATE POLICY "authenticated_documents_select"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'documents' AND
  (
    (metadata->>'uploaded_by')::uuid = auth.uid() OR
    has_role(auth.uid(), 'admin'::app_role) OR
    has_role(auth.uid(), 'support_staff'::app_role)
  )
);

-- Create authenticated-only SELECT policies for diagrams
CREATE POLICY "authenticated_diagrams_select"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'diagrams' AND
  (
    (metadata->>'uploaded_by')::uuid = auth.uid() OR
    has_role(auth.uid(), 'admin'::app_role) OR
    has_role(auth.uid(), 'support_staff'::app_role)
  )
);

-- ============================================================================
-- SECURITY FIX: Restrict Overly Permissive RLS Policies
-- ============================================================================
-- Fix for: "Overly Permissive RLS Policies Expose All Data"
-- Issue: Many tables use USING (true) allowing any authenticated user full access
-- Solution: Implement owner-based and role-based access control

-- ============================================================================
-- CHAT MESSAGES: Users can only see their own messages + admins/support can see all
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Authenticated users can update chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Authenticated users can delete chat messages" ON public.chat_messages;

CREATE POLICY "Users can view own messages or if admin/support"
ON public.chat_messages FOR SELECT
USING (
  user_id = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Users can update own messages"
ON public.chat_messages FOR UPDATE
USING (user_id = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users can delete own messages"
ON public.chat_messages FOR DELETE
USING (user_id = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- MAINTENANCE REQUESTS: Requester, assignee, and staff can access
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all maintenance requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Authenticated users can update maintenance requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Authenticated users can delete maintenance requests" ON public.maintenance_requests;

CREATE POLICY "Users can view own maintenance requests or if staff"
ON public.maintenance_requests FOR SELECT
USING (
  requested_by = auth.uid() OR
  assigned_to = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Users can update own requests or if staff"
ON public.maintenance_requests FOR UPDATE
USING (
  requested_by = auth.uid() OR
  assigned_to = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only admins can delete maintenance requests"
ON public.maintenance_requests FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- JOBS: Creator, assignee, and admins can access
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all jobs" ON public.jobs;
DROP POLICY IF EXISTS "Authenticated users can update jobs" ON public.jobs;
DROP POLICY IF EXISTS "Authenticated users can delete jobs" ON public.jobs;

CREATE POLICY "Users can view own jobs or if admin"
ON public.jobs FOR SELECT
USING (
  created_by = auth.uid() OR
  assigned_to = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Users can update own jobs or if admin"
ON public.jobs FOR UPDATE
USING (
  created_by = auth.uid() OR
  assigned_to = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Only admins can delete jobs"
ON public.jobs FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- JOB UPDATE REQUESTS: Requester and admins can access
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all update requests" ON public.job_update_requests;
DROP POLICY IF EXISTS "Authenticated users can update update requests" ON public.job_update_requests;
DROP POLICY IF EXISTS "Authenticated users can delete update requests" ON public.job_update_requests;

CREATE POLICY "Users can view own job update requests or if admin"
ON public.job_update_requests FOR SELECT
USING (
  requested_by = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only admins can update job update requests"
ON public.job_update_requests FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only admins can delete job update requests"
ON public.job_update_requests FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- ASSETS: Admins and support staff only (sensitive company data)
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all assets" ON public.assets;
DROP POLICY IF EXISTS "Authenticated users can update assets" ON public.assets;
DROP POLICY IF EXISTS "Authenticated users can delete assets" ON public.assets;

CREATE POLICY "Only staff can view assets"
ON public.assets FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only staff can update assets"
ON public.assets FOR UPDATE
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only admins can delete assets"
ON public.assets FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- BRANCHES: Admins and support staff only (company structure data)
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all branches" ON public.branches;
DROP POLICY IF EXISTS "Authenticated users can update branches" ON public.branches;
DROP POLICY IF EXISTS "Authenticated users can delete branches" ON public.branches;

CREATE POLICY "Only staff can view branches"
ON public.branches FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only staff can update branches"
ON public.branches FOR UPDATE
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only admins can delete branches"
ON public.branches FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- HARDWARE INVENTORY: Admins and support staff only
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all hardware" ON public.hardware_inventory;
DROP POLICY IF EXISTS "Authenticated users can update hardware" ON public.hardware_inventory;
DROP POLICY IF EXISTS "Authenticated users can delete hardware" ON public.hardware_inventory;

CREATE POLICY "Only staff can view hardware"
ON public.hardware_inventory FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only staff can update hardware"
ON public.hardware_inventory FOR UPDATE
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only admins can delete hardware"
ON public.hardware_inventory FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- NETWORK DEVICES: Admins and support staff only (infrastructure data)
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all network devices" ON public.network_devices;
DROP POLICY IF EXISTS "Authenticated users can update network devices" ON public.network_devices;
DROP POLICY IF EXISTS "Authenticated users can delete network devices" ON public.network_devices;

CREATE POLICY "Only staff can view network devices"
ON public.network_devices FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only staff can update network devices"
ON public.network_devices FOR UPDATE
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only admins can delete network devices"
ON public.network_devices FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- INTERNET CONNECTIVITY: Admins and support staff only
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view all internet connectivity" ON public.internet_connectivity;
DROP POLICY IF EXISTS "Authenticated users can update internet connectivity" ON public.internet_connectivity;
DROP POLICY IF EXISTS "Authenticated users can delete internet connectivity" ON public.internet_connectivity;

CREATE POLICY "Only staff can view connectivity"
ON public.internet_connectivity FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only staff can update connectivity"
ON public.internet_connectivity FOR UPDATE
USING (
  has_role(auth.uid(), 'admin'::app_role) OR
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Only admins can delete connectivity"
ON public.internet_connectivity FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- SHARED FILES: Only file sharers, recipients, and admins can access
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view shared files" ON public.shared_files;
DROP POLICY IF EXISTS "Authenticated users can update shares" ON public.shared_files;
DROP POLICY IF EXISTS "Authenticated users can delete shares" ON public.shared_files;

CREATE POLICY "Users can view files shared with them"
ON public.shared_files FOR SELECT
USING (
  shared_by = auth.uid() OR
  shared_with_user_id = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  EXISTS (
    SELECT 1 FROM public.user_group_members
    WHERE group_id = shared_with_group_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Only file owners and admins can update shares"
ON public.shared_files FOR UPDATE
USING (shared_by = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only file owners and admins can delete shares"
ON public.shared_files FOR DELETE
USING (shared_by = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- SHARED FOLDERS: Creator and members can access
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view folders" ON public.shared_folders;
DROP POLICY IF EXISTS "Authenticated users can update folders" ON public.shared_folders;
DROP POLICY IF EXISTS "Authenticated users can delete folders" ON public.shared_folders;

CREATE POLICY "Users can view folders they created or have access to"
ON public.shared_folders FOR SELECT
USING (
  created_by = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  EXISTS (
    SELECT 1 FROM public.shared_folder_permissions
    WHERE folder_id = shared_folders.id AND 
    (user_id = auth.uid() OR group_id IN (
      SELECT group_id FROM public.user_group_members WHERE user_id = auth.uid()
    ))
  )
);

CREATE POLICY "Only creators and admins can update folders"
ON public.shared_folders FOR UPDATE
USING (created_by = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only creators and admins can delete folders"
ON public.shared_folders FOR DELETE
USING (created_by = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- USER GROUPS: Admins and group creators only
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view groups" ON public.user_groups;
DROP POLICY IF EXISTS "Authenticated users can update groups" ON public.user_groups;
DROP POLICY IF EXISTS "Authenticated users can delete groups" ON public.user_groups;

CREATE POLICY "Users can view groups they belong to or created"
ON public.user_groups FOR SELECT
USING (
  created_by = auth.uid() OR
  has_role(auth.uid(), 'admin'::app_role) OR
  EXISTS (
    SELECT 1 FROM public.user_group_members
    WHERE group_id = user_groups.id AND user_id = auth.uid()
  )
);

CREATE POLICY "Only creators and admins can update groups"
ON public.user_groups FOR UPDATE
USING (created_by = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only creators and admins can delete groups"
ON public.user_groups FOR DELETE
USING (created_by = auth.uid() OR has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- USER PERMISSIONS: Admins only (security-critical)
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view user perms" ON public.user_permissions;
DROP POLICY IF EXISTS "Authenticated users can grant user perms" ON public.user_permissions;
DROP POLICY IF EXISTS "Authenticated users can revoke user perms" ON public.user_permissions;

CREATE POLICY "Only admins can view user permissions"
ON public.user_permissions FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only admins can grant user permissions"
ON public.user_permissions FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only admins can revoke user permissions"
ON public.user_permissions FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- ============================================================================
-- GROUP PERMISSIONS: Admins only (security-critical)
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view group perms" ON public.group_permissions;
DROP POLICY IF EXISTS "Authenticated users can grant group perms" ON public.group_permissions;
DROP POLICY IF EXISTS "Authenticated users can revoke group perms" ON public.group_permissions;

CREATE POLICY "Only admins can view group permissions"
ON public.group_permissions FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only admins can grant group permissions"
ON public.group_permissions FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Only admins can revoke group permissions"
ON public.group_permissions FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));