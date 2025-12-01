-- Create staff_members table for staff directory records (not login users)
CREATE TABLE IF NOT EXISTS public.staff_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  email TEXT,
  department TEXT,
  job_title TEXT,
  phone TEXT,
  branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_staff_members_full_name ON public.staff_members(full_name);
CREATE INDEX IF NOT EXISTS idx_staff_members_email ON public.staff_members(email);
CREATE INDEX IF NOT EXISTS idx_staff_members_branch_id ON public.staff_members(branch_id);
CREATE INDEX IF NOT EXISTS idx_staff_members_status ON public.staff_members(status);

-- Enable RLS
ALTER TABLE public.staff_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies - All authenticated users can view staff
CREATE POLICY "Authenticated users can view staff members"
  ON public.staff_members FOR SELECT
  TO authenticated
  USING (true);

-- Only admins can insert staff members
CREATE POLICY "Admins can insert staff members"
  ON public.staff_members FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Only admins can update staff members
CREATE POLICY "Admins can update staff members"
  ON public.staff_members FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Only admins can delete staff members
CREATE POLICY "Admins can delete staff members"
  ON public.staff_members FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Add updated_at trigger
CREATE TRIGGER update_staff_members_updated_at
  BEFORE UPDATE ON public.staff_members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE public.staff_members IS 'Staff directory records - these are not login users, just employee records';
COMMENT ON COLUMN public.staff_members.status IS 'Staff member status: active, inactive, on_leave';
