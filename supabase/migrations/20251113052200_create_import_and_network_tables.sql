-- Create import_jobs table to track CSV imports
CREATE TABLE public.import_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES public.branches(id) ON DELETE CASCADE,
  uploader UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  import_type TEXT NOT NULL, -- 'csv', 'network_json', 'image'
  resource_type TEXT, -- 'users', 'devices', 'network_devices', 'tickets', 'assets', etc.
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
  file_path TEXT,
  result_summary JSONB DEFAULT '{}',
  error_details TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create network_diagrams table for storing network topology diagrams
CREATE TABLE public.network_diagrams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID REFERENCES public.branches(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  diagram_json JSONB DEFAULT '{}', -- nodes, edges, layout data
  image_path TEXT, -- path to rendered diagram image
  is_company_wide BOOLEAN DEFAULT false, -- true for overall company network
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create cloud_networks table for Nymbis RDP and other cloud networks
CREATE TABLE public.cloud_networks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  provider TEXT NOT NULL DEFAULT 'nymbis', -- 'nymbis', 'aws', 'azure', 'gcp', etc.
  network_type TEXT, -- 'rdp', 'vpn', 'hybrid', etc.
  description TEXT,
  diagram_json JSONB DEFAULT '{}',
  image_path TEXT, -- path to uploaded diagram image (PNG/JPG/JPEG)
  metadata JSONB DEFAULT '{}', -- flexible storage for provider-specific data
  branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create indexes for performance
CREATE INDEX idx_import_jobs_branch_id ON public.import_jobs(branch_id);
CREATE INDEX idx_import_jobs_uploader ON public.import_jobs(uploader);
CREATE INDEX idx_import_jobs_status ON public.import_jobs(status);
CREATE INDEX idx_import_jobs_created_at ON public.import_jobs(created_at DESC);

CREATE INDEX idx_network_diagrams_branch_id ON public.network_diagrams(branch_id);
CREATE INDEX idx_network_diagrams_created_by ON public.network_diagrams(created_by);
CREATE INDEX idx_network_diagrams_is_company_wide ON public.network_diagrams(is_company_wide);

CREATE INDEX idx_cloud_networks_provider ON public.cloud_networks(provider);
CREATE INDEX idx_cloud_networks_branch_id ON public.cloud_networks(branch_id);
CREATE INDEX idx_cloud_networks_created_by ON public.cloud_networks(created_by);

-- Enable RLS on new tables
ALTER TABLE public.import_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_diagrams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cloud_networks ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for import_jobs
CREATE POLICY "Authenticated users can view all import jobs"
  ON public.import_jobs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create import jobs"
  ON public.import_jobs FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update import jobs"
  ON public.import_jobs FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete import jobs"
  ON public.import_jobs FOR DELETE
  TO authenticated
  USING (true);

-- Create RLS policies for network_diagrams
CREATE POLICY "Authenticated users can view all network diagrams"
  ON public.network_diagrams FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create network diagrams"
  ON public.network_diagrams FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update network diagrams"
  ON public.network_diagrams FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete network diagrams"
  ON public.network_diagrams FOR DELETE
  TO authenticated
  USING (true);

-- Create RLS policies for cloud_networks
CREATE POLICY "Authenticated users can view all cloud networks"
  ON public.cloud_networks FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create cloud networks"
  ON public.cloud_networks FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update cloud networks"
  ON public.cloud_networks FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete cloud networks"
  ON public.cloud_networks FOR DELETE
  TO authenticated
  USING (true);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_import_jobs_updated_at
  BEFORE UPDATE ON public.import_jobs
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_network_diagrams_updated_at
  BEFORE UPDATE ON public.network_diagrams
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_cloud_networks_updated_at
  BEFORE UPDATE ON public.cloud_networks
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

-- Add comments for documentation
COMMENT ON TABLE public.import_jobs IS 'Tracks CSV and file import operations for branches';
COMMENT ON TABLE public.network_diagrams IS 'Stores network topology diagrams for branches and company-wide view';
COMMENT ON TABLE public.cloud_networks IS 'Stores cloud network configurations including Nymbis RDP, AWS, Azure, etc.';
