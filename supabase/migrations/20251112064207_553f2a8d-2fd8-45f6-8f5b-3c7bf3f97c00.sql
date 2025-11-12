-- Add tracking columns to provider_emails table
ALTER TABLE public.provider_emails
ADD COLUMN confirmation_token TEXT UNIQUE,
ADD COLUMN confirmed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN confirmed_by TEXT,
ADD COLUMN provider_notes TEXT;

-- Create index for faster token lookups
CREATE INDEX idx_provider_emails_confirmation_token ON public.provider_emails(confirmation_token);

-- Create function to generate random tokens
CREATE OR REPLACE FUNCTION generate_confirmation_token()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN encode(gen_random_bytes(32), 'hex');
END;
$$;