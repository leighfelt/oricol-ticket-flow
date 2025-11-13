-- Drop all existing role-based RLS policies and create new policies for authenticated users
-- This migration aligns the database security model with the UI changes that removed role-based access controls

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

CREATE POLICY "Authenticated users can view all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert profiles"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update profiles"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (true);

-- ============================================================================
-- TICKETS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view own or assigned tickets" ON public.tickets;
DROP POLICY IF EXISTS "Support staff can view all tickets" ON public.tickets;
DROP POLICY IF EXISTS "Users can create tickets" ON public.tickets;
DROP POLICY IF EXISTS "Users can update own or assigned tickets" ON public.tickets;
DROP POLICY IF EXISTS "Support staff can update all tickets" ON public.tickets;
DROP POLICY IF EXISTS "Admins can delete tickets" ON public.tickets;

CREATE POLICY "Authenticated users can view all tickets"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create tickets"
  ON public.tickets FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update tickets"
  ON public.tickets FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete tickets"
  ON public.tickets FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- TICKET COMMENTS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view comments on accessible tickets" ON public.ticket_comments;
DROP POLICY IF EXISTS "Users can create comments on accessible tickets" ON public.ticket_comments;

CREATE POLICY "Authenticated users can view all comments"
  ON public.ticket_comments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create comments"
  ON public.ticket_comments FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update comments"
  ON public.ticket_comments FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete comments"
  ON public.ticket_comments FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- TICKET TIME LOGS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Support staff can view time logs" ON public.ticket_time_logs;
DROP POLICY IF EXISTS "Support staff can log time" ON public.ticket_time_logs;

CREATE POLICY "Authenticated users can view time logs"
  ON public.ticket_time_logs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can log time"
  ON public.ticket_time_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update time logs"
  ON public.ticket_time_logs FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete time logs"
  ON public.ticket_time_logs FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- ASSETS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view assigned assets" ON public.assets;
DROP POLICY IF EXISTS "Admins can create assets" ON public.assets;
DROP POLICY IF EXISTS "Admins can update assets" ON public.assets;
DROP POLICY IF EXISTS "Admins can delete assets" ON public.assets;

CREATE POLICY "Authenticated users can view all assets"
  ON public.assets FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create assets"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update assets"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete assets"
  ON public.assets FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- HARDWARE INVENTORY TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view assigned hardware" ON public.hardware_inventory;
DROP POLICY IF EXISTS "Admins and support can view all hardware" ON public.hardware_inventory;
DROP POLICY IF EXISTS "Admins can insert hardware" ON public.hardware_inventory;
DROP POLICY IF EXISTS "Admins can update hardware" ON public.hardware_inventory;
DROP POLICY IF EXISTS "Admins can delete hardware" ON public.hardware_inventory;

CREATE POLICY "Authenticated users can view all hardware"
  ON public.hardware_inventory FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create hardware"
  ON public.hardware_inventory FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update hardware"
  ON public.hardware_inventory FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete hardware"
  ON public.hardware_inventory FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- SOFTWARE INVENTORY TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view assigned software" ON public.software_inventory;
DROP POLICY IF EXISTS "Admins and support can view all software" ON public.software_inventory;
DROP POLICY IF EXISTS "Admins can insert software" ON public.software_inventory;
DROP POLICY IF EXISTS "Admins can update software" ON public.software_inventory;
DROP POLICY IF EXISTS "Admins can delete software" ON public.software_inventory;

CREATE POLICY "Authenticated users can view all software"
  ON public.software_inventory FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create software"
  ON public.software_inventory FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update software"
  ON public.software_inventory FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete software"
  ON public.software_inventory FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- LICENSES TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view assigned licenses" ON public.licenses;
DROP POLICY IF EXISTS "Admins and support can view all licenses" ON public.licenses;
DROP POLICY IF EXISTS "Admins can insert licenses" ON public.licenses;
DROP POLICY IF EXISTS "Admins can update licenses" ON public.licenses;
DROP POLICY IF EXISTS "Admins can delete licenses" ON public.licenses;

CREATE POLICY "Authenticated users can view all licenses"
  ON public.licenses FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create licenses"
  ON public.licenses FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update licenses"
  ON public.licenses FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete licenses"
  ON public.licenses FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- JOBS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view all jobs" ON public.jobs;
DROP POLICY IF EXISTS "Admins and support can create jobs" ON public.jobs;
DROP POLICY IF EXISTS "Admins and support can update jobs" ON public.jobs;
DROP POLICY IF EXISTS "Admins can delete jobs" ON public.jobs;

CREATE POLICY "Authenticated users can view all jobs"
  ON public.jobs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create jobs"
  ON public.jobs FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update jobs"
  ON public.jobs FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete jobs"
  ON public.jobs FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- JOB UPDATE REQUESTS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view update requests" ON public.job_update_requests;
DROP POLICY IF EXISTS "Anyone can create update requests" ON public.job_update_requests;
DROP POLICY IF EXISTS "Admins and support can update requests" ON public.job_update_requests;

CREATE POLICY "Authenticated users can view all update requests"
  ON public.job_update_requests FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create update requests"
  ON public.job_update_requests FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update update requests"
  ON public.job_update_requests FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete update requests"
  ON public.job_update_requests FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- MAINTENANCE REQUESTS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view their own requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Admins and support can view all requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Anyone can create maintenance requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Admins and support can update requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Admins can delete requests" ON public.maintenance_requests;

CREATE POLICY "Authenticated users can view all maintenance requests"
  ON public.maintenance_requests FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create maintenance requests"
  ON public.maintenance_requests FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update maintenance requests"
  ON public.maintenance_requests FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete maintenance requests"
  ON public.maintenance_requests FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- BRANCHES TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view branches" ON public.branches;
DROP POLICY IF EXISTS "Admins can insert branches" ON public.branches;
DROP POLICY IF EXISTS "Admins can update branches" ON public.branches;
DROP POLICY IF EXISTS "Admins can delete branches" ON public.branches;

CREATE POLICY "Authenticated users can view all branches"
  ON public.branches FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create branches"
  ON public.branches FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update branches"
  ON public.branches FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete branches"
  ON public.branches FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- NETWORK DEVICES TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view network devices" ON public.network_devices;
DROP POLICY IF EXISTS "Admins can insert network devices" ON public.network_devices;
DROP POLICY IF EXISTS "Admins can update network devices" ON public.network_devices;
DROP POLICY IF EXISTS "Admins can delete network devices" ON public.network_devices;

CREATE POLICY "Authenticated users can view all network devices"
  ON public.network_devices FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create network devices"
  ON public.network_devices FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update network devices"
  ON public.network_devices FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete network devices"
  ON public.network_devices FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- INTERNET CONNECTIVITY TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view internet connectivity" ON public.internet_connectivity;
DROP POLICY IF EXISTS "Admins can insert internet connectivity" ON public.internet_connectivity;
DROP POLICY IF EXISTS "Admins can update internet connectivity" ON public.internet_connectivity;
DROP POLICY IF EXISTS "Admins can delete internet connectivity" ON public.internet_connectivity;

CREATE POLICY "Authenticated users can view all internet connectivity"
  ON public.internet_connectivity FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create internet connectivity"
  ON public.internet_connectivity FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update internet connectivity"
  ON public.internet_connectivity FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete internet connectivity"
  ON public.internet_connectivity FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- NETWORK DIAGRAMS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view network diagrams" ON public.network_diagrams;
DROP POLICY IF EXISTS "Admins can insert network diagrams" ON public.network_diagrams;
DROP POLICY IF EXISTS "Admins can update network diagrams" ON public.network_diagrams;
DROP POLICY IF EXISTS "Admins can delete network diagrams" ON public.network_diagrams;

CREATE POLICY "Authenticated users can view all network diagrams"
  ON public.network_diagrams FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create network diagrams"
  ON public.network_diagrams FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update network diagrams"
  ON public.network_diagrams FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete network diagrams"
  ON public.network_diagrams FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- VPN RDP CREDENTIALS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view credentials" ON public.vpn_rdp_credentials;
DROP POLICY IF EXISTS "Admins can insert credentials" ON public.vpn_rdp_credentials;
DROP POLICY IF EXISTS "Admins can update credentials" ON public.vpn_rdp_credentials;
DROP POLICY IF EXISTS "Admins can delete credentials" ON public.vpn_rdp_credentials;

CREATE POLICY "Authenticated users can view all credentials"
  ON public.vpn_rdp_credentials FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create credentials"
  ON public.vpn_rdp_credentials FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update credentials"
  ON public.vpn_rdp_credentials FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete credentials"
  ON public.vpn_rdp_credentials FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- REMOTE SESSIONS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Support staff can view all remote sessions" ON public.remote_sessions;
DROP POLICY IF EXISTS "Anyone can create remote sessions" ON public.remote_sessions;
DROP POLICY IF EXISTS "Support staff can update remote sessions" ON public.remote_sessions;
DROP POLICY IF EXISTS "Support staff can delete remote sessions" ON public.remote_sessions;

CREATE POLICY "Authenticated users can view all remote sessions"
  ON public.remote_sessions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create remote sessions"
  ON public.remote_sessions FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update remote sessions"
  ON public.remote_sessions FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete remote sessions"
  ON public.remote_sessions FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- REMOTE CLIENTS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Authenticated users can view remote clients" ON public.remote_clients;
DROP POLICY IF EXISTS "Anyone can register a client" ON public.remote_clients;
DROP POLICY IF EXISTS "Anyone can update client status" ON public.remote_clients;

CREATE POLICY "Authenticated users can view all remote clients"
  ON public.remote_clients FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create remote clients"
  ON public.remote_clients FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update remote clients"
  ON public.remote_clients FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete remote clients"
  ON public.remote_clients FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- PROVIDER EMAILS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view email logs" ON public.provider_emails;
DROP POLICY IF EXISTS "System can insert email logs" ON public.provider_emails;
DROP POLICY IF EXISTS "Admins can update email logs" ON public.provider_emails;

CREATE POLICY "Authenticated users can view all provider emails"
  ON public.provider_emails FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create provider emails"
  ON public.provider_emails FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update provider emails"
  ON public.provider_emails FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete provider emails"
  ON public.provider_emails FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- CHAT MESSAGES TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Users can view all chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can create their own messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Support staff can create support replies" ON public.chat_messages;

CREATE POLICY "Authenticated users can view all chat messages"
  ON public.chat_messages FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create chat messages"
  ON public.chat_messages FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update chat messages"
  ON public.chat_messages FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete chat messages"
  ON public.chat_messages FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- DIRECTORY USERS TABLE
-- ============================================================================
DROP POLICY IF EXISTS "Admins and support can view directory users" ON public.directory_users;

CREATE POLICY "Authenticated users can view all directory users"
  ON public.directory_users FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create directory users"
  ON public.directory_users FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update directory users"
  ON public.directory_users FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete directory users"
  ON public.directory_users FOR DELETE
  TO authenticated
  USING (true);