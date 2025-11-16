-- Fix admin access to ensure admins can see and edit all tickets
-- This addresses the issue where Craig@zerobitone.co.za cannot see all tickets

-- Drop existing restrictive ticket policies
DROP POLICY IF EXISTS "Users can view all tickets" ON public.tickets;
DROP POLICY IF EXISTS "Users can create tickets" ON public.tickets;
DROP POLICY IF EXISTS "Users can update tickets" ON public.tickets;
DROP POLICY IF EXISTS "Users can delete tickets" ON public.tickets;

-- Create new admin-friendly policies for tickets
-- Admins can view ALL tickets
CREATE POLICY "Admins can view all tickets"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Regular users can view tickets they created or are assigned to
CREATE POLICY "Users can view own tickets"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (
    NOT EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    AND (
      created_by IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
      OR assigned_to IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
    )
  );

-- Anyone authenticated can create tickets
CREATE POLICY "Authenticated users can create tickets"
  ON public.tickets FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Admins can update ALL tickets
CREATE POLICY "Admins can update all tickets"
  ON public.tickets FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Support staff can update tickets assigned to them or that they created
CREATE POLICY "Support staff can update assigned tickets"
  ON public.tickets FOR UPDATE
  TO authenticated
  USING (
    NOT EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    AND (
      created_by IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
      OR assigned_to IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
      OR EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE user_id = auth.uid() AND role = 'support_staff'
      )
    )
  );

-- Admins can delete ALL tickets
CREATE POLICY "Admins can delete all tickets"
  ON public.tickets FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- Only admins can delete tickets (no other users)
CREATE POLICY "Only admins can delete tickets"
  ON public.tickets FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

COMMENT ON POLICY "Admins can view all tickets" ON public.tickets IS 'Admins should see ALL tickets in the system';
COMMENT ON POLICY "Admins can update all tickets" ON public.tickets IS 'Admins should be able to fully edit ALL tickets';
COMMENT ON POLICY "Admins can delete all tickets" ON public.tickets IS 'Admins should be able to delete ANY ticket';
