-- Add version history tracking for shared files
-- This allows tracking of file changes, who modified them, and when

-- Create file version history table
CREATE TABLE IF NOT EXISTS public.shared_file_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id UUID REFERENCES public.documents(id) ON DELETE CASCADE NOT NULL,
  version_number INTEGER NOT NULL,
  filename TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  storage_path TEXT NOT NULL,
  modified_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  change_description TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (file_id, version_number)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_file_versions_file_id ON public.shared_file_versions(file_id);
CREATE INDEX IF NOT EXISTS idx_file_versions_modified_by ON public.shared_file_versions(modified_by);

-- Add last modified tracking to documents table
ALTER TABLE public.documents
ADD COLUMN IF NOT EXISTS last_modified_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS last_modified_at TIMESTAMPTZ DEFAULT now();

-- Enable RLS
ALTER TABLE public.shared_file_versions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for file versions
CREATE POLICY "Authenticated users can view file versions"
  ON public.shared_file_versions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create file versions"
  ON public.shared_file_versions FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Add trigger to update last_modified_at on documents
CREATE OR REPLACE FUNCTION update_document_last_modified()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_modified_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_documents_last_modified
  BEFORE UPDATE ON public.documents
  FOR EACH ROW
  EXECUTE FUNCTION update_document_last_modified();

-- Function to create version history when a file is updated
CREATE OR REPLACE FUNCTION create_file_version()
RETURNS TRIGGER AS $$
DECLARE
  next_version INTEGER;
BEGIN
  -- Get the next version number for this file
  SELECT COALESCE(MAX(version_number), 0) + 1
  INTO next_version
  FROM public.shared_file_versions
  WHERE file_id = NEW.id;

  -- Create version history record
  INSERT INTO public.shared_file_versions (
    file_id,
    version_number,
    filename,
    file_size,
    storage_path,
    modified_by,
    change_description
  ) VALUES (
    NEW.id,
    next_version,
    NEW.filename,
    NEW.file_size,
    NEW.storage_path,
    NEW.last_modified_by,
    'File updated'
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically create version history on document update
CREATE TRIGGER create_document_version_on_update
  AFTER UPDATE ON public.documents
  FOR EACH ROW
  WHEN (OLD.filename IS DISTINCT FROM NEW.filename OR OLD.file_size IS DISTINCT FROM NEW.file_size)
  EXECUTE FUNCTION create_file_version();

-- Add comments
COMMENT ON TABLE public.shared_file_versions IS 'Version history for shared files';
COMMENT ON COLUMN public.shared_file_versions.version_number IS 'Sequential version number for each file';
COMMENT ON COLUMN public.shared_file_versions.modified_by IS 'User who created this version';
COMMENT ON COLUMN public.documents.last_modified_by IS 'User who last modified the document';
COMMENT ON COLUMN public.documents.last_modified_at IS 'Timestamp of last modification';
