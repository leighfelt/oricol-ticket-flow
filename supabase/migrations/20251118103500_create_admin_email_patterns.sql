-- Create table to store admin email patterns
-- This replaces hardcoded admin emails in the frontend code

CREATE TABLE IF NOT EXISTS public.admin_email_patterns (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email_pattern TEXT NOT NULL UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.admin_email_patterns ENABLE ROW LEVEL SECURITY;

-- Only authenticated users can view admin email patterns
CREATE POLICY "Authenticated users can view admin email patterns"
  ON public.admin_email_patterns FOR SELECT
  TO authenticated
  USING (true);

-- Only admins can manage admin email patterns (insert, update, delete)
CREATE POLICY "Only admins can manage admin email patterns"
  ON public.admin_email_patterns FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Insert default admin email patterns
INSERT INTO public.admin_email_patterns (email_pattern, description) VALUES
  ('craig@zerobitone.co.za', 'Craig - Primary Admin'),
  ('admin@oricol.co.za', 'Oricol Admin Account'),
  ('admin@zerobitone.co.za', 'ZeroBitOne Admin Account')
ON CONFLICT (email_pattern) DO NOTHING;

-- Create function to check if an email matches any admin pattern
CREATE OR REPLACE FUNCTION public.is_admin_email(email_to_check TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  is_match BOOLEAN;
BEGIN
  -- Check if the email (case-insensitive) matches any active admin pattern
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_email_patterns
    WHERE is_active = true
    AND LOWER(email_pattern) = LOWER(email_to_check)
  ) INTO is_match;
  
  RETURN is_match;
END;
$$;

-- Add comment for documentation
COMMENT ON TABLE public.admin_email_patterns IS 'Stores email patterns that automatically receive admin role';
COMMENT ON FUNCTION public.is_admin_email(TEXT) IS 'Checks if an email should automatically receive admin role';

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_admin_email_patterns_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_admin_email_patterns_updated_at
  BEFORE UPDATE ON public.admin_email_patterns
  FOR EACH ROW
  EXECUTE FUNCTION public.update_admin_email_patterns_updated_at();
