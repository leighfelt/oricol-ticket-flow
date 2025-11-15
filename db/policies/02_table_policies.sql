-- Profiles: restrict to owner or service_role
ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "profiles_select_own" ON public.profiles
  FOR SELECT USING ( auth.role() = 'service_role' OR auth.uid() = id );

CREATE POLICY IF NOT EXISTS "profiles_update_own" ON public.profiles
  FOR UPDATE USING ( auth.role() = 'service_role' OR auth.uid() = id )
  WITH CHECK ( auth.role() = 'service_role' OR auth.uid() = id );

-- Tickets: restrict reads/updates to owner or staff/service_role
ALTER TABLE IF EXISTS public.tickets ENABLE ROW LEVEL SECURITY;

-- Adjust role-check to your schema. This example expects a user_roles table with (user_id, role)
CREATE POLICY IF NOT EXISTS "tickets_owner_select" ON public.tickets
  FOR SELECT USING (
    auth.role() = 'service_role' OR
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.user_roles ur WHERE ur.user_id = auth.uid() AND ur.role = 'staff'
    )
  );

CREATE POLICY IF NOT EXISTS "tickets_owner_update" ON public.tickets
  FOR UPDATE USING (
    auth.role() = 'service_role' OR
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.user_roles ur WHERE ur.user_id = auth.uid() AND ur.role = 'staff'
    )
  )
  WITH CHECK (
    auth.role() = 'service_role' OR
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.user_roles ur WHERE ur.user_id = auth.uid() AND ur.role = 'staff'
    )
  );
