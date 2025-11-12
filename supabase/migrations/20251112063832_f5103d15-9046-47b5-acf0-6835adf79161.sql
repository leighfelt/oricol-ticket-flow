-- Create email tracking table
CREATE TABLE public.provider_emails (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  
  -- Email metadata
  email_type TEXT NOT NULL, -- 'staff_onboarding', 'license_request', etc.
  provider TEXT NOT NULL, -- 'qwerti', 'braintree', 'armata'
  subject TEXT NOT NULL,
  
  -- Recipients
  to_addresses TEXT[] NOT NULL,
  cc_addresses TEXT[],
  
  -- Content
  html_content TEXT NOT NULL,
  
  -- Status tracking
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'sent', 'failed', 'resent'
  error_message TEXT,
  sent_at TIMESTAMP WITH TIME ZONE,
  resend_count INTEGER DEFAULT 0,
  
  -- Related data
  staff_member_id UUID,
  staff_member_name TEXT,
  staff_member_email TEXT,
  
  -- Request data for resending
  request_data JSONB
);

-- Enable RLS
ALTER TABLE public.provider_emails ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Admins and support can view email logs"
  ON public.provider_emails
  FOR SELECT
  USING (
    has_role(auth.uid(), 'admin'::app_role) OR 
    has_role(auth.uid(), 'support_staff'::app_role)
  );

CREATE POLICY "System can insert email logs"
  ON public.provider_emails
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admins can update email logs"
  ON public.provider_emails
  FOR UPDATE
  USING (has_role(auth.uid(), 'admin'::app_role));

-- Create index for better query performance
CREATE INDEX idx_provider_emails_status ON public.provider_emails(status);
CREATE INDEX idx_provider_emails_provider ON public.provider_emails(provider);
CREATE INDEX idx_provider_emails_created_at ON public.provider_emails(created_at DESC);
CREATE INDEX idx_provider_emails_staff_member_id ON public.provider_emails(staff_member_id);

-- Create trigger for updated_at
CREATE TRIGGER update_provider_emails_updated_at
  BEFORE UPDATE ON public.provider_emails
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();