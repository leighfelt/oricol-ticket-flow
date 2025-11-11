-- Create hardware_inventory table
CREATE TABLE public.hardware_inventory (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  device_name TEXT NOT NULL,
  device_type TEXT NOT NULL, -- Desktop, Laptop, Server, etc.
  manufacturer TEXT,
  model TEXT,
  serial_number TEXT,
  processor TEXT,
  ram_gb INTEGER,
  storage_gb INTEGER,
  os TEXT,
  os_version TEXT,
  assigned_to UUID REFERENCES auth.users(id),
  location TEXT,
  branch TEXT,
  purchase_date DATE,
  warranty_expires DATE,
  status TEXT NOT NULL DEFAULT 'active',
  last_seen TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create software_inventory table
CREATE TABLE public.software_inventory (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  software_name TEXT NOT NULL,
  version TEXT,
  vendor TEXT,
  license_key TEXT,
  license_type TEXT, -- per-user, per-device, site, etc.
  installed_on UUID REFERENCES public.hardware_inventory(id),
  assigned_to UUID REFERENCES auth.users(id),
  install_date DATE,
  expiry_date DATE,
  status TEXT NOT NULL DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create licenses table
CREATE TABLE public.licenses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  license_name TEXT NOT NULL,
  license_type TEXT NOT NULL, -- RDP, Microsoft 365, etc.
  vendor TEXT NOT NULL,
  license_key TEXT,
  total_seats INTEGER NOT NULL,
  used_seats INTEGER NOT NULL DEFAULT 0,
  assigned_to UUID REFERENCES auth.users(id),
  purchase_date DATE,
  renewal_date DATE,
  cost DECIMAL(10, 2),
  status TEXT NOT NULL DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.hardware_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.software_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.licenses ENABLE ROW LEVEL SECURITY;

-- RLS Policies for hardware_inventory
CREATE POLICY "Admins and support can view all hardware"
ON public.hardware_inventory
FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR 
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Users can view assigned hardware"
ON public.hardware_inventory
FOR SELECT
USING (auth.uid() = assigned_to);

CREATE POLICY "Admins can insert hardware"
ON public.hardware_inventory
FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update hardware"
ON public.hardware_inventory
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete hardware"
ON public.hardware_inventory
FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for software_inventory
CREATE POLICY "Admins and support can view all software"
ON public.software_inventory
FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR 
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Users can view assigned software"
ON public.software_inventory
FOR SELECT
USING (auth.uid() = assigned_to);

CREATE POLICY "Admins can insert software"
ON public.software_inventory
FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update software"
ON public.software_inventory
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete software"
ON public.software_inventory
FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for licenses
CREATE POLICY "Admins and support can view all licenses"
ON public.licenses
FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR 
  has_role(auth.uid(), 'support_staff'::app_role)
);

CREATE POLICY "Users can view assigned licenses"
ON public.licenses
FOR SELECT
USING (auth.uid() = assigned_to);

CREATE POLICY "Admins can insert licenses"
ON public.licenses
FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update licenses"
ON public.licenses
FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete licenses"
ON public.licenses
FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- Add triggers for updated_at
CREATE TRIGGER update_hardware_inventory_updated_at
BEFORE UPDATE ON public.hardware_inventory
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_software_inventory_updated_at
BEFORE UPDATE ON public.software_inventory
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_licenses_updated_at
BEFORE UPDATE ON public.licenses
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();