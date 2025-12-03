-- =====================================================
-- SUPABASE DATA EXPORT - ORICOL TICKET SYSTEM
-- Generated: 2025-12-03
-- Run this in your NEW Supabase SQL Editor
-- =====================================================

-- IMPORTANT: Run sections in order!
-- Some tables depend on others (foreign keys)

-- =====================================================
-- 1. TENANTS (Run First)
-- =====================================================
INSERT INTO public.tenants (id, name, slug, primary_color, is_active, settings, created_at, updated_at)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Default Organization',
  'default',
  '#3b82f6',
  true,
  '{}',
  '2025-12-01 08:47:05.517375+00',
  '2025-12-01 08:47:05.517375+00'
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. BRANCHES
-- =====================================================
INSERT INTO public.branches (id, name, city, country, tenant_id, created_at, updated_at) VALUES
('366bcc97-dfc8-4356-b0d4-5b508d4e7057', 'Durban', 'Durban', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00'),
('a6e6bb15-20f8-4a0b-8163-24955c135391', 'JHB (Spartan)', 'Johannesburg', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00'),
('e0aab1cc-86f6-4069-9258-f6e190ddae3d', 'CPT', 'Cape Town', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00'),
('4d862215-7099-49a0-a09b-b1be652d8dcb', 'PE', 'Port Elizabeth', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. USER ROLES (After you create users in auth.users)
-- Replace USER_IDs with your actual user IDs from auth.users
-- =====================================================
-- EXAMPLE: First find your user ID by running:
-- SELECT id, email FROM auth.users;
-- Then insert roles:

-- For craig@zerobitone.co.za user, run:
-- INSERT INTO public.user_roles (user_id, role) 
-- SELECT id, 'admin' FROM auth.users WHERE email = 'craig@zerobitone.co.za'
-- ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. USER TENANT MEMBERSHIPS (After user_roles)
-- =====================================================
-- INSERT INTO public.user_tenant_memberships (user_id, tenant_id, role, is_default)
-- SELECT id, '00000000-0000-0000-0000-000000000001', 'admin', false 
-- FROM auth.users WHERE email = 'craig@zerobitone.co.za'
-- ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. PROFILES (Auto-created on signup, but backup data)
-- =====================================================
-- Profiles are typically auto-created via trigger
-- If needed, update existing profiles:
-- UPDATE public.profiles SET full_name = 'Craig Felt' WHERE email = 'craig@zerobitone.co.za';

-- =====================================================
-- 6. TICKETS
-- =====================================================
INSERT INTO public.tickets (id, title, description, branch, category, fault_type, priority, status, user_email, tenant_id, time_spent_minutes, created_at, updated_at) VALUES
('0ff2feb8-f8c0-4e62-a17a-1ac42bcaa128', 'Teams Meeting with Byran from Qwerti about Network Assessment Tool to be deployed at each branch', 'Teams Meeting with Byran from Qwerti about Network Assessment Tool to be deployed at each branch', 'DBN', NULL, 'Other', 'medium', 'closed', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-27 09:02:18.603717+00', '2025-12-01 09:27:42.436584+00'),
('27d3e8bd-bea8-4ef2-be95-f0d95f341258', 'Qwerti - Network Assessment Report Tool to be deployed - Craig to assist Qwerti where needed', 'Qwerti - Network Assessment Report Tool to be deployed - Craig to assist Qwerti where needed', 'DBN', NULL, 'Other', 'high', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-27 09:01:15.88073+00', '2025-12-01 08:47:05.517375+00'),
('990be599-3097-48ee-94d7-e9585678e308', 'Migration / Backup Image Testing - no impact to Oricol users - Ransomware testing on offline copy of image', 'Migration / Backup Image Testing - no impact to Oricol users - Ransomware testing on offline copy of RDP Server images', 'DBN', NULL, 'RDP', 'high', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-28 04:25:55.859643+00', '2025-12-01 08:47:05.517375+00'),
('1e17944f-5ae5-4053-8465-95bbaf67b234', 'Microsoft 365 Policy Testing for security best Practices according to latest Threat Knowledge', 'Microsoft 365 Policy Testing for security best Practices according to latest Threat Knowledge', 'DBN', 'software', 'Email', 'medium', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-28 04:27:27.136224+00', '2025-12-01 08:47:05.517375+00'),
('8f91f968-5e46-4790-bd3f-6607d7a7c731', 'Harry old laptop - Hdd needs ssd upgrade & more ram needed', 'Harry old laptop - Hdd needs ssd upgrade & more ram needed', 'CPT', 'Hardware & software', 'CDrive', 'medium', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-13 23:08:17.261698+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO UPDATE SET 
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  branch = EXCLUDED.branch,
  status = EXCLUDED.status,
  priority = EXCLUDED.priority,
  tenant_id = EXCLUDED.tenant_id;

-- =====================================================
-- 7. LICENSES
-- =====================================================
INSERT INTO public.licenses (id, license_name, license_type, vendor, total_seats, used_seats, status, tenant_id, notes, created_at, updated_at) VALUES
('0027b6f2-fc94-401c-9c41-ccf7f75163c5', 'SPB', 'subscription', 'Microsoft', 85, 84, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46', '2025-11-12 04:59:05.687731+00', '2025-12-03 02:00:29.470428+00'),
('12d5e1d1-2d5f-48b9-947d-e90532bb5bbf', 'POWER_BI_STANDARD', 'subscription', 'Microsoft', 1000000, 2, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: a403ebcc-fae0-4ca2-8c8c-7a907fd6c235', '2025-11-11 10:01:20.378125+00', '2025-12-03 02:00:29.510364+00'),
('c9cb9bdc-0a69-465e-afcc-80379b2008c1', 'OFFICESUBSCRIPTION', 'subscription', 'Microsoft', 1, 0, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: c2273bd0-dff7-4215-9ef5-2c7bcfb06425', '2025-11-11 10:01:20.420471+00', '2025-12-03 02:00:29.552159+00'),
('10803dfd-0ab4-46eb-8140-8bfada80efc1', 'EXCHANGEENTERPRISE', 'subscription', 'Microsoft', 4, 4, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: 19ec0d23-8335-4cbd-94ac-6050e30712fa', '2025-11-11 10:01:20.463609+00', '2025-12-03 02:00:29.594716+00'),
('e7670a6f-3656-4a7f-807b-4d1065ae45bf', 'RIGHTSMANAGEMENT_ADHOC', 'subscription', 'Microsoft', 50000, 0, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: 8c4ce438-32a7-4ac5-91a6-e22ae08d9c8b', '2025-11-11 10:01:20.507004+00', '2025-12-03 02:00:29.639712+00'),
('315b53e3-933f-44b3-b3f3-4433ca29d757', '365 Business Premium', 'Microsoft 365', 'Braintree', 85, 84, 'active', '00000000-0000-0000-0000-000000000001', '', '2025-11-12 07:41:13.31837+00', '2025-12-01 08:47:05.517375+00'),
('3a680712-38c3-445b-84b2-797e6d29fcf8', '365 Business Premium', 'subscription', 'Microsoft', 85, 84, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46', '2025-11-11 10:01:20.33239+00', '2025-12-01 08:47:05.517375+00'),
('8338e6c9-44b0-4de5-a12e-25e14396b649', 'Microsoft_365_Copilot', 'subscription', 'Microsoft', 2, 2, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: 639dec6b-bb19-468b-871c-c5c441c4b0cb', '2025-11-11 10:01:20.211005+00', '2025-12-03 02:00:29.392938+00'),
('e7347587-1773-4e75-8d15-b2c6c5cbfdfb', 'FLOW_FREE', 'subscription', 'Microsoft', 10000, 15, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: f30db892-07e9-47e9-837c-80727f46fd3d', '2025-11-11 10:01:20.283495+00', '2025-12-03 02:00:29.433529+00')
ON CONFLICT (id) DO UPDATE SET 
  license_name = EXCLUDED.license_name,
  total_seats = EXCLUDED.total_seats,
  used_seats = EXCLUDED.used_seats,
  tenant_id = EXCLUDED.tenant_id;

-- =====================================================
-- 8. MAINTENANCE REQUESTS
-- =====================================================
INSERT INTO public.maintenance_requests (id, title, description, request_type, courier_platform, pickup_address, delivery_address, status, priority, tenant_id, created_at, updated_at) VALUES
('a3d37075-43f2-466e-bf20-67f94515043f', 'Collect laptop from Craig in DBN for Tania in CPT', 'Collect laptop from Craig in DBN for Tania in CPT', 'courier', 'courier_guy', '11 Carlisle Crescent, Durban North', '12 Constantia Place, CPT', 'pending', 'medium', '00000000-0000-0000-0000-000000000001', '2025-11-13 06:33:14.011151+00', '2025-12-01 08:47:05.517375+00'),
('36e60d7a-af88-4bc3-aeb6-7a83e36ab064', 'Harrys old Laptop - courier from CPT to Durban', 'Harrys old Laptop - courier from CPT to Durban', 'courier', 'courier_guy', 'CPT', '11 Carlisle Crescent
Durban North', 'pending', 'medium', '00000000-0000-0000-0000-000000000001', '2025-11-16 06:56:09.269006+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 9. NETWORK DEVICES
-- =====================================================
INSERT INTO public.network_devices (id, device_name, device_type, ip_address, status, tenant_id, notes, created_at, updated_at) VALUES
('42bfa250-5097-42bb-9745-0f7bf052e4d8', 'Router IP = 192.168.12.1', 'router', '192.168.12.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00'),
('2ebaf1a1-24d8-4ac8-b1c5-04b56b3d4eb6', 'Router IP = 192.168.16.1', 'router', '192.168.16.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00'),
('a362a6c7-072b-4561-8f85-0cd20c7e3133', 'Router IP = 192.168.10.1', 'router', '192.168.10.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00'),
('d8fc60a4-b465-49db-a588-ca2196f19e15', 'Router IP = 192.168.11.1', 'router', '192.168.11.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 10. VPN/RDP CREDENTIALS (Sensitive - review before import)
-- =====================================================
INSERT INTO public.vpn_rdp_credentials (id, username, password, email, service_type, tenant_id, notes, created_at, updated_at) VALUES
('d7819b76-d26f-4ee5-8e45-e8633ac9c3f0', 'KeithN', '321KeithN!@', 'Keith.Nayger@oricoles.co.za', 'VPN', '00000000-0000-0000-0000-000000000001', 'Blending321P
KeithN!@', '2025-11-12 08:07:35.606294+00', '2025-12-01 13:00:48.675139+00'),
('76c4b753-a370-4103-9814-58383e8dd35e', 'TyrelleW', '321TyrelleW!@', 'Tyrelle.Wood@oricoles.co.za', 'VPN', '00000000-0000-0000-0000-000000000001', NULL, '2025-11-12 08:07:35.606294+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SETUP USER ROLES & MEMBERSHIPS
-- Run this AFTER creating your user account
-- =====================================================

-- Step 1: Find your user ID
-- SELECT id, email FROM auth.users WHERE email = 'craig@zerobitone.co.za';

-- Step 2: Create profile if not exists
INSERT INTO public.profiles (user_id, email, full_name)
SELECT id, email, 'Craig Felt' 
FROM auth.users 
WHERE email = 'craig@zerobitone.co.za'
ON CONFLICT (user_id) DO UPDATE SET full_name = 'Craig Felt';

-- Step 3: Add admin role
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin' 
FROM auth.users 
WHERE email = 'craig@zerobitone.co.za'
ON CONFLICT DO NOTHING;

-- Step 4: Add tenant membership
INSERT INTO public.user_tenant_memberships (user_id, tenant_id, role, is_default)
SELECT id, '00000000-0000-0000-0000-000000000001', 'admin', true 
FROM auth.users 
WHERE email = 'craig@zerobitone.co.za'
ON CONFLICT DO NOTHING;

-- =====================================================
-- VERIFY DATA
-- =====================================================
-- SELECT COUNT(*) as tenant_count FROM public.tenants;
-- SELECT COUNT(*) as branch_count FROM public.branches;
-- SELECT COUNT(*) as ticket_count FROM public.tickets;
-- SELECT COUNT(*) as license_count FROM public.licenses;
-- SELECT * FROM public.user_roles WHERE user_id = (SELECT id FROM auth.users WHERE email = 'craig@zerobitone.co.za');
-- SELECT * FROM public.user_tenant_memberships WHERE user_id = (SELECT id FROM auth.users WHERE email = 'craig@zerobitone.co.za');
