-- Create table for VPN/RDP credentials
CREATE TABLE public.vpn_rdp_credentials (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  service_type TEXT NOT NULL CHECK (service_type IN ('VPN', 'RDP')),
  email TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.vpn_rdp_credentials ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Admins and support can view credentials" 
ON public.vpn_rdp_credentials 
FOR SELECT 
USING (has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'support_staff'::app_role));

CREATE POLICY "Admins can insert credentials" 
ON public.vpn_rdp_credentials 
FOR INSERT 
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update credentials" 
ON public.vpn_rdp_credentials 
FOR UPDATE 
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete credentials" 
ON public.vpn_rdp_credentials 
FOR DELETE 
USING (has_role(auth.uid(), 'admin'::app_role));

-- Add trigger for updated_at
CREATE TRIGGER update_vpn_rdp_credentials_updated_at
BEFORE UPDATE ON public.vpn_rdp_credentials
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();