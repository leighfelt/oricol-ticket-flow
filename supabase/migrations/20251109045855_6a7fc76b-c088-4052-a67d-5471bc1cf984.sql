-- Create app_role enum
CREATE TYPE app_role AS ENUM ('admin', 'support_staff', 'user');

-- Create user_roles table
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (user_id, role)
);

-- Enable RLS on user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_roles
CREATE POLICY "Users can view own roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Only admins can insert roles"
  ON public.user_roles FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Create security definer function for role checking
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- Update profiles table policies
DROP POLICY "Users can view all profiles" ON public.profiles;

CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Update tickets table policies
DROP POLICY "Users can view all tickets" ON public.tickets;
DROP POLICY "Users can update tickets" ON public.tickets;

CREATE POLICY "Users can view own or assigned tickets"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (auth.uid() = created_by OR auth.uid() = assigned_to);

CREATE POLICY "Support staff can view all tickets"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'support_staff'));

CREATE POLICY "Users can update own or assigned tickets"
  ON public.tickets FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by OR auth.uid() = assigned_to);

CREATE POLICY "Support staff can update all tickets"
  ON public.tickets FOR UPDATE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'support_staff'));

CREATE POLICY "Admins can delete tickets"
  ON public.tickets FOR DELETE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Update assets table policies
DROP POLICY "Users can view all assets" ON public.assets;
DROP POLICY "Users can create assets" ON public.assets;
DROP POLICY "Users can update assets" ON public.assets;

CREATE POLICY "Users can view assigned assets"
  ON public.assets FOR SELECT
  TO authenticated
  USING (auth.uid() = assigned_to OR public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can create assets"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update assets"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete assets"
  ON public.assets FOR DELETE
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'));

-- Update ticket_comments table policies
DROP POLICY "Users can view all comments" ON public.ticket_comments;
DROP POLICY "Users can create comments" ON public.ticket_comments;

CREATE POLICY "Users can view comments on accessible tickets"
  ON public.ticket_comments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.tickets
      WHERE tickets.id = ticket_comments.ticket_id
      AND (tickets.created_by = auth.uid() OR tickets.assigned_to = auth.uid())
    ) OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'support_staff')
  );

CREATE POLICY "Users can create comments on accessible tickets"
  ON public.ticket_comments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.tickets
      WHERE tickets.id = ticket_comments.ticket_id
      AND (tickets.created_by = auth.uid() OR tickets.assigned_to = auth.uid())
    ) OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'support_staff')
  );

-- Remove the insecure role column from profiles
ALTER TABLE public.profiles DROP COLUMN IF EXISTS role;