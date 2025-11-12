-- Create branches table
CREATE TABLE public.branches (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  postal_code TEXT,
  country TEXT,
  phone TEXT,
  email TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on branches
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;

-- Create policies for branches
CREATE POLICY "Admins and support can view branches"
ON public.branches
FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'support_staff'::app_role));

CREATE POLICY "Admins can insert branches"
ON public.branches
FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update branches"
ON public.branches
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete branches"
ON public.branches
FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- Create network_devices table for printers, switches, routers, etc.
CREATE TABLE public.network_devices (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branch_id UUID REFERENCES public.branches(id) ON DELETE CASCADE,
  device_name TEXT NOT NULL,
  device_type TEXT NOT NULL, -- printer, switch, router, firewall, access_point, etc.
  manufacturer TEXT,
  model TEXT,
  serial_number TEXT,
  ip_address TEXT,
  mac_address TEXT,
  location TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  purchase_date DATE,
  warranty_expires DATE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on network_devices
ALTER TABLE public.network_devices ENABLE ROW LEVEL SECURITY;

-- Create policies for network_devices
CREATE POLICY "Admins and support can view network devices"
ON public.network_devices
FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'support_staff'::app_role));

CREATE POLICY "Admins can insert network devices"
ON public.network_devices
FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update network devices"
ON public.network_devices
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete network devices"
ON public.network_devices
FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- Create network_diagrams table for storing diagram images
CREATE TABLE public.network_diagrams (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branch_id UUID REFERENCES public.branches(id) ON DELETE CASCADE NOT NULL,
  diagram_name TEXT NOT NULL,
  diagram_url TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on network_diagrams
ALTER TABLE public.network_diagrams ENABLE ROW LEVEL SECURITY;

-- Create policies for network_diagrams
CREATE POLICY "Admins and support can view network diagrams"
ON public.network_diagrams
FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'support_staff'::app_role));

CREATE POLICY "Admins can insert network diagrams"
ON public.network_diagrams
FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update network diagrams"
ON public.network_diagrams
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete network diagrams"
ON public.network_diagrams
FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- Add trigger for updated_at on branches
CREATE TRIGGER update_branches_updated_at
BEFORE UPDATE ON public.branches
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Add trigger for updated_at on network_devices
CREATE TRIGGER update_network_devices_updated_at
BEFORE UPDATE ON public.network_devices
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Add trigger for updated_at on network_diagrams
CREATE TRIGGER update_network_diagrams_updated_at
BEFORE UPDATE ON public.network_diagrams
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();