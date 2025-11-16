-- Add additional fields to profiles table for user tracking
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES public.branches(id),
ADD COLUMN IF NOT EXISTS device_serial_number TEXT,
ADD COLUMN IF NOT EXISTS vpn_username TEXT,
ADD COLUMN IF NOT EXISTS vpn_password TEXT,
ADD COLUMN IF NOT EXISTS rdp_username TEXT,
ADD COLUMN IF NOT EXISTS rdp_password TEXT;

-- Create user_document_storage table to track individual user document uploads
CREATE TABLE IF NOT EXISTS public.user_document_storage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  document_id UUID REFERENCES public.documents(id) ON DELETE CASCADE NOT NULL,
  storage_capacity_mb NUMERIC NOT NULL DEFAULT 0,
  upload_count INTEGER NOT NULL DEFAULT 0,
  last_upload_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (user_id, document_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_document_storage_user_id ON public.user_document_storage(user_id);
CREATE INDEX IF NOT EXISTS idx_user_document_storage_document_id ON public.user_document_storage(document_id);

-- Enable RLS on user_document_storage table
ALTER TABLE public.user_document_storage ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_document_storage
-- Users can view their own storage
CREATE POLICY "Users can view own document storage"
  ON public.user_document_storage FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Admins can view all document storage
CREATE POLICY "Admins can view all document storage"
  ON public.user_document_storage FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Users can insert their own storage records
CREATE POLICY "Users can insert own document storage"
  ON public.user_document_storage FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own storage records
CREATE POLICY "Users can update own document storage"
  ON public.user_document_storage FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Admins can update any storage records
CREATE POLICY "Admins can update all document storage"
  ON public.user_document_storage FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Create user_activity_log table to track user actions
CREATE TABLE IF NOT EXISTS public.user_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  activity_type TEXT NOT NULL, -- 'document_upload', 'document_download', 'ticket_create', etc.
  activity_details JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_activity_log_user_id ON public.user_activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_created_at ON public.user_activity_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_activity_type ON public.user_activity_log(activity_type);

-- Enable RLS on user_activity_log table
ALTER TABLE public.user_activity_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_activity_log
-- Users can view their own activity
CREATE POLICY "Users can view own activity"
  ON public.user_activity_log FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Admins can view all activity
CREATE POLICY "Admins can view all activity"
  ON public.user_activity_log FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Anyone can insert activity (for logging)
CREATE POLICY "Authenticated users can insert activity"
  ON public.user_activity_log FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Add updated_at trigger for user_document_storage
CREATE OR REPLACE FUNCTION update_user_document_storage_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_document_storage_updated_at
  BEFORE UPDATE ON public.user_document_storage
  FOR EACH ROW
  EXECUTE FUNCTION update_user_document_storage_updated_at();

-- Update documents table RLS to allow admin-only access for Document Hub
DROP POLICY IF EXISTS "Authenticated users can view all documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can upload documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can update documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can delete documents" ON public.documents;

-- Create admin-only policies for documents
CREATE POLICY "Admins can view all documents"
  ON public.documents FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can upload documents"
  ON public.documents FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update documents"
  ON public.documents FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete documents"
  ON public.documents FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Add comments for documentation
COMMENT ON TABLE public.user_document_storage IS 'Tracks individual user document uploads and storage usage';
COMMENT ON TABLE public.user_activity_log IS 'Logs all user activities for admin reporting and auditing';
COMMENT ON COLUMN public.profiles.branch_id IS 'Branch assigned to the user';
COMMENT ON COLUMN public.profiles.device_serial_number IS 'Device endpoint serial number assigned to user';
COMMENT ON COLUMN public.profiles.vpn_username IS 'VPN username for the user';
COMMENT ON COLUMN public.profiles.vpn_password IS 'VPN password for the user (encrypted recommended)';
COMMENT ON COLUMN public.profiles.rdp_username IS 'RDP username for the user';
COMMENT ON COLUMN public.profiles.rdp_password IS 'RDP password for the user (encrypted recommended)';
