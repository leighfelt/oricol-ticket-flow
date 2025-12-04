-- =====================================================
-- COMPLETE SUPABASE DATA EXPORT - ORICOL TICKET SYSTEM
-- Generated: 2025-12-04
-- Run this in your NEW Supabase SQL Editor
-- =====================================================

-- CRITICAL: Run these sections IN ORDER!

-- =====================================================
-- STEP 1: CREATE DEFAULT TENANT (Run First!)
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
-- STEP 2: BRANCHES
-- =====================================================
INSERT INTO public.branches (id, name, city, country, tenant_id, created_at, updated_at) VALUES
('366bcc97-dfc8-4356-b0d4-5b508d4e7057', 'Durban', 'Durban', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00'),
('a6e6bb15-20f8-4a0b-8163-24955c135391', 'JHB (Spartan)', 'Johannesburg', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00'),
('e0aab1cc-86f6-4069-9258-f6e190ddae3d', 'CPT', 'Cape Town', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00'),
('4d862215-7099-49a0-a09b-b1be652d8dcb', 'PE', 'Port Elizabeth', 'South Africa', '00000000-0000-0000-0000-000000000001', '2025-11-12 05:50:08.224583+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STEP 3: TICKETS
-- =====================================================
INSERT INTO public.tickets (id, title, description, branch, category, fault_type, priority, status, user_email, tenant_id, time_spent_minutes, created_at, updated_at) VALUES
('0ff2feb8-f8c0-4e62-a17a-1ac42bcaa128', 'Teams Meeting with Byran from Qwerti about Network Assessment Tool to be deployed at each branch', 'Teams Meeting with Byran from Qwerti about Network Assessment Tool to be deployed at each branch', 'DBN', NULL, 'Other', 'medium', 'closed', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-27 09:02:18.603717+00', '2025-12-01 09:27:42.436584+00'),
('27d3e8bd-bea8-4ef2-be95-f0d95f341258', 'Qwerti - Network Assessment Report Tool to be deployed - Craig to assist Qwerti where needed', 'Qwerti - Network Assessment Report Tool to be deployed - Craig to assist Qwerti where needed', 'DBN', NULL, 'Other', 'high', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-27 09:01:15.88073+00', '2025-12-01 08:47:05.517375+00'),
('990be599-3097-48ee-94d7-e9585678e308', 'Migration / Backup Image Testing - no impact to Oricol users - Ransomware testing on offline copy of image', 'Migration / Backup Image Testing - no impact to Oricol users - Ransomware testing on offline copy of RDP Server images', 'DBN', NULL, 'RDP', 'high', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-28 04:25:55.859643+00', '2025-12-01 08:47:05.517375+00'),
('1e17944f-5ae5-4053-8465-95bbaf67b234', 'Microsoft 365 Policy Testing for security best Practices according to latest Threat Knowledge', 'Microsoft 365 Policy Testing for security best Practices according to latest Threat Knowledge', 'DBN', 'software', 'Email', 'medium', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-28 04:27:27.136224+00', '2025-12-01 08:47:05.517375+00'),
('8f91f968-5e46-4790-bd3f-6607d7a7c731', 'Harry old laptop - Hdd needs ssd upgrade & more ram needed', 'Harry old laptop - Hdd needs ssd upgrade & more ram needed', 'CPT', 'Hardware & software', 'CDrive', 'medium', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-13 23:08:17.261698+00', '2025-12-01 08:47:05.517375+00'),
('a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 'CSAT Tool scan, report completion - teams meeting with John @ Microsoft to run through', 'CSAT Tool scan, report completion - teams meeting with John @ Microsoft to run through', 'DBN', 'Software', 'Other', 'medium', 'open', 'craig@zerobitone.co.za', '00000000-0000-0000-0000-000000000001', 0, '2025-11-13 23:11:39.988342+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO UPDATE SET 
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  tenant_id = EXCLUDED.tenant_id;

-- =====================================================
-- STEP 4: LICENSES
-- =====================================================
INSERT INTO public.licenses (id, license_name, license_type, vendor, total_seats, used_seats, status, tenant_id, notes, created_at, updated_at) VALUES
('8338e6c9-44b0-4de5-a12e-25e14396b649', 'Microsoft_365_Copilot', 'subscription', 'Microsoft', 2, 2, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: 639dec6b-bb19-468b-871c-c5c441c4b0cb', '2025-11-11 10:01:20.211005+00', '2025-12-04 02:00:28.435372+00'),
('e7347587-1773-4e75-8d15-b2c6c5cbfdfb', 'FLOW_FREE', 'subscription', 'Microsoft', 10000, 15, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: f30db892-07e9-47e9-837c-80727f46fd3d', '2025-11-11 10:01:20.283495+00', '2025-12-04 02:00:28.478842+00'),
('0027b6f2-fc94-401c-9c41-ccf7f75163c5', 'SPB', 'subscription', 'Microsoft', 85, 84, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46', '2025-11-12 04:59:05.687731+00', '2025-12-04 02:00:28.518632+00'),
('315b53e3-933f-44b3-b3f3-4433ca29d757', '365 Business Premium', 'Microsoft 365', 'Braintree', 85, 84, 'active', '00000000-0000-0000-0000-000000000001', '', '2025-11-12 07:41:13.31837+00', '2025-12-01 08:47:05.517375+00'),
('3a680712-38c3-445b-84b2-797e6d29fcf8', '365 Business Premium', 'subscription', 'Microsoft', 85, 84, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46', '2025-11-11 10:01:20.33239+00', '2025-12-01 08:47:05.517375+00'),
('12d5e1d1-2d5f-48b9-947d-e90532bb5bbf', 'POWER_BI_STANDARD', 'subscription', 'Microsoft', 1000000, 2, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: a403ebcc-fae0-4ca2-8c8c-7a907fd6c235', '2025-11-11 10:01:20.378125+00', '2025-12-04 02:00:28.559446+00'),
('c9cb9bdc-0a69-465e-afcc-80379b2008c1', 'OFFICESUBSCRIPTION', 'subscription', 'Microsoft', 1, 0, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: c2273bd0-dff7-4215-9ef5-2c7bcfb06425', '2025-11-11 10:01:20.420471+00', '2025-12-04 02:00:28.595905+00'),
('10803dfd-0ab4-46eb-8140-8bfada80efc1', 'EXCHANGEENTERPRISE', 'subscription', 'Microsoft', 4, 4, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: 19ec0d23-8335-4cbd-94ac-6050e30712fa', '2025-11-11 10:01:20.463609+00', '2025-12-04 02:00:28.63515+00'),
('e7670a6f-3656-4a7f-807b-4d1065ae45bf', 'RIGHTSMANAGEMENT_ADHOC', 'subscription', 'Microsoft', 50000, 0, 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - SKU ID: 8c4ce438-32a7-4ac5-91a6-e22ae08d9c8b', '2025-11-11 10:01:20.507004+00', '2025-12-04 02:00:28.672808+00')
ON CONFLICT (id) DO UPDATE SET 
  license_name = EXCLUDED.license_name,
  total_seats = EXCLUDED.total_seats,
  used_seats = EXCLUDED.used_seats,
  tenant_id = EXCLUDED.tenant_id;

-- =====================================================
-- STEP 5: MAINTENANCE REQUESTS
-- =====================================================
INSERT INTO public.maintenance_requests (id, title, description, request_type, courier_platform, pickup_address, delivery_address, status, priority, tenant_id, created_at, updated_at) VALUES
('a3d37075-43f2-466e-bf20-67f94515043f', 'Collect laptop from Craig in DBN for Tania in CPT', 'Collect laptop from Craig in DBN for Tania in CPT', 'courier', 'courier_guy', '11 Carlisle Crescent, Durban North', '12 Constantia Place, CPT', 'pending', 'medium', '00000000-0000-0000-0000-000000000001', '2025-11-13 06:33:14.011151+00', '2025-12-01 08:47:05.517375+00'),
('36e60d7a-af88-4bc3-aeb6-7a83e36ab064', 'Harrys old Laptop - courier from CPT to Durban', 'Harrys old Laptop - courier from CPT to Durban', 'courier', 'courier_guy', 'CPT', '11 Carlisle Crescent, Durban North', 'pending', 'medium', '00000000-0000-0000-0000-000000000001', '2025-11-16 06:56:09.269006+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STEP 6: NETWORK DEVICES
-- =====================================================
INSERT INTO public.network_devices (id, device_name, device_type, ip_address, status, tenant_id, notes, created_at, updated_at) VALUES
('42bfa250-5097-42bb-9745-0f7bf052e4d8', 'Router IP = 192.168.12.1', 'router', '192.168.12.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00'),
('2ebaf1a1-24d8-4ac8-b1c5-04b56b3d4eb6', 'Router IP = 192.168.16.1', 'router', '192.168.16.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00'),
('a362a6c7-072b-4561-8f85-0cd20c7e3133', 'Router IP = 192.168.10.1', 'router', '192.168.10.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00'),
('d8fc60a4-b465-49db-a588-ca2196f19e15', 'Router IP = 192.168.11.1', 'router', '192.168.11.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 06:25:25.885536+00', '2025-12-01 08:47:05.517375+00'),
('9808de56-7d01-473a-a3ea-a0bc4d81726d', 'Router IP = 192.168.12.1 (2)', 'router', '192.168.12.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 08:20:39.148953+00', '2025-12-01 08:47:05.517375+00'),
('acc1d98b-b1e3-4da6-a0f1-245cd33285df', 'Router IP = 192.168.16.1 (2)', 'router', '192.168.16.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 08:20:39.148953+00', '2025-12-01 08:47:05.517375+00'),
('3e13246b-3111-44cb-a747-05a5c4bce782', 'Router IP = 192.168.10.1 (2)', 'router', '192.168.10.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 08:20:39.148953+00', '2025-12-01 08:47:05.517375+00'),
('9544f86c-722c-403f-83f1-0a5e64621dcb', 'Router IP = 192.168.11.1 (2)', 'router', '192.168.11.1', 'active', '00000000-0000-0000-0000-000000000001', 'Imported from document', '2025-11-26 08:20:39.148953+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STEP 7: VPN/RDP CREDENTIALS (Sample - sensitive data)
-- =====================================================
INSERT INTO public.vpn_rdp_credentials (id, username, password, email, service_type, tenant_id, notes, created_at, updated_at) VALUES
('d7819b76-d26f-4ee5-8e45-e8633ac9c3f0', 'KeithN', '321KeithN!@', 'Keith.Nayger@oricoles.co.za', 'VPN', '00000000-0000-0000-0000-000000000001', 'Blending321P KeithN!@', '2025-11-12 08:07:35.606294+00', '2025-12-01 13:00:48.675139+00'),
('76c4b753-a370-4103-9814-58383e8dd35e', 'TyrelleW', '321TyrelleW!@', 'Tyrelle.Wood@oricoles.co.za', 'VPN', '00000000-0000-0000-0000-000000000001', NULL, '2025-11-12 08:07:35.606294+00', '2025-12-01 08:47:05.517375+00')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STEP 8: HARDWARE INVENTORY (Sample)
-- =====================================================
INSERT INTO public.hardware_inventory (id, device_name, device_type, manufacturer, model, serial_number, os, os_version, status, tenant_id, notes, created_at, updated_at) VALUES
('9fdbdbe1-c718-45c3-bfb7-12f467db0435', 'KYLIEHPNEW', 'Windows', 'HP', 'HP 250 15.6 inch G10 Notebook PC', '5CD5260995', 'Windows', '10.0.26100.6584', 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - User: Kylie.Labuschagne@Oricoles.co.za', '2025-11-11 10:01:13.393392+00', '2025-12-04 02:00:13.764658+00'),
('22681f7c-e4d0-46d7-b8b4-5df5a9b72b02', 'ROSSWORKSTATION', 'Windows', 'Dell Inc.', 'Inspiron 15 3511', '8KJPYM3', 'Windows', '10.0.26200.7171', 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - User: Ross.Arde@Oricoles.co.za', '2025-11-11 10:01:15.069452+00', '2025-12-04 02:00:10.092234+00'),
('157568cb-9d07-4702-9005-025d71d745f9', 'BERNADETTENEWHP', 'Windows', 'HP', 'HP 250 G7 Notebook PC', 'CND90924DP', 'Windows', '10.0.26100.6899', 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - User: Bernadette.Williams@Oricoles.co.za', '2025-11-11 10:01:15.155302+00', '2025-12-04 02:00:11.594152+00'),
('dd2cf38c-46c2-484b-b957-680ce79a0312', 'HEATHERPC', 'Windows', 'To be filled by O.E.M.', 'To be filled by O.E.M.', 'TobefilledbyO.E.M.', 'Windows', '10.0.26100.7171', 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - User: Heather.Landsberg@Oricoles.co.za', '2025-11-11 10:01:13.300425+00', '2025-12-04 02:00:12.188807+00'),
('247097e2-0653-4bba-8bcb-7ddc3aa5bd9a', 'MEGS', 'Windows', 'LENOVO', '82QD', 'PF4ZLZCZ', 'Windows', '10.0.26200.7171', 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - User: Megan.Bennet@Oricoles.co.za', '2025-11-11 10:01:14.984109+00', '2025-12-04 02:00:13.086158+00'),
('c5a3042d-8271-42a3-a114-958212302385', 'Ntombizandile-Laptop', 'Windows', 'HP', 'HP 250 15.6 inch G9 Notebook PC', 'CND4210CCC', 'Windows', '10.0.26200.7171', 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - User: Ntombizandile.Tyhulu@Oricoles.co.za', '2025-11-11 10:01:14.803267+00', '2025-12-04 02:00:13.463202+00'),
('8a1c9ea7-6c14-4e5d-a199-0ef1caf4ee96', 'DEWALD-LAPTOP', 'Windows', 'HP', 'HP 250 G8 Notebook PC', 'CND312078N', 'Windows', '10.0.22631.3880', 'active', '00000000-0000-0000-0000-000000000001', 'Synced from Microsoft 365 - User: dewald.els@Oricoles.co.za', '2025-11-11 10:01:14.712432+00', '2025-12-04 02:00:13.910651+00')
ON CONFLICT (id) DO UPDATE SET 
  device_name = EXCLUDED.device_name,
  tenant_id = EXCLUDED.tenant_id;

-- =====================================================
-- STEP 9: DIRECTORY USERS (Sample)
-- =====================================================
INSERT INTO public.directory_users (id, aad_id, display_name, email, user_principal_name, account_enabled, tenant_id, created_at, updated_at) VALUES
('95b254a1-98e2-4844-a7bb-e5b821566a3f', '7d9badd9-2e36-4959-ac83-b9ddb55a6ee0', 'Graeme Smart', 'admin@oricoleserv.onmicrosoft.com', 'admin@oricoleserv.onmicrosoft.com', true, '00000000-0000-0000-0000-000000000001', '2025-11-11 10:09:40.387848+00', '2025-12-04 02:00:14.536728+00'),
('935a4f1e-7695-495e-a266-39517a3308f8', '6b37c219-f454-4c3e-950a-4cf36f75b6a1', 'Ameer Peerbhai', 'Ameer.peerbhai@Oricoles.co.za', 'Ameer.peerbhai@Oricoles.co.za', true, '00000000-0000-0000-0000-000000000001', '2025-11-11 10:09:40.585206+00', '2025-12-04 02:00:24.28119+00'),
('49eab426-beb2-4236-ae18-aba40b60a4f5', 'cdf4ea8f-71a3-4e8f-bb6a-79d6243ce621', 'Keith Nayger', 'Keith.Nayger@Oricoles.co.za', 'Keith.Nayger@Oricoles.co.za', true, '00000000-0000-0000-0000-000000000001', '2025-11-11 10:09:43.004666+00', '2025-12-04 02:00:26.31875+00'),
('1ac0224a-50fa-45c2-aa19-ad69bb09864d', '5ac39b3b-7cfa-4c90-a65a-e686e856b6e6', 'Mary Mkwana', 'Mary.Mkwana@oricoles.co.za', 'Mary.Mkwana@Oricoles.co.za', true, '00000000-0000-0000-0000-000000000001', '2025-11-11 10:09:43.853104+00', '2025-12-04 02:00:27.062177+00'),
('fa0b8a8f-0d5a-40ee-b944-e4472045a31e', '7483c3a9-54b7-4ea2-a419-5483695b534d', 'Megan Bennet', 'Megan.bennet@oricoles.co.za', 'Megan.Bennet@Oricoles.co.za', true, '00000000-0000-0000-0000-000000000001', '2025-11-11 10:09:44.054645+00', '2025-12-04 02:00:27.223755+00'),
('04e209c9-13aa-4642-bbba-5d2f30d208ab', '44a906cb-1b06-4ea1-b5f0-26a653acce59', 'Richard Sanders', 'Richard.Sanders@oricoles.co.za', 'Richard.Sanders@Oricoles.co.za', true, '00000000-0000-0000-0000-000000000001', '2025-11-11 10:09:44.779081+00', '2025-12-04 02:00:27.941065+00'),
('c1f42e5c-5147-469a-986b-7cda0e654f0c', '88063a5d-54f6-4521-a7a1-b26e1b797a85', 'Robin Conway', 'robin.conway@Oricoles.co.za', 'robin.conway@Oricoles.co.za', true, '00000000-0000-0000-0000-000000000001', '2025-11-11 10:09:44.881705+00', '2025-12-04 02:00:28.025506+00')
ON CONFLICT (id) DO UPDATE SET 
  display_name = EXCLUDED.display_name,
  tenant_id = EXCLUDED.tenant_id;

-- =====================================================
-- STEP 10: CRITICAL - SETUP YOUR USER ACCESS
-- Run this AFTER you sign up with craig@zerobitone.co.za
-- =====================================================

-- First, find your user ID:
-- SELECT id, email FROM auth.users WHERE email = 'craig@zerobitone.co.za';

-- Then run these with YOUR actual user ID:

-- Create profile
INSERT INTO public.profiles (user_id, email, full_name)
SELECT id, email, 'Craig Felt' 
FROM auth.users 
WHERE email = 'craig@zerobitone.co.za'
ON CONFLICT (user_id) DO UPDATE SET full_name = 'Craig Felt';

-- Add admin role
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin' 
FROM auth.users 
WHERE email = 'craig@zerobitone.co.za'
ON CONFLICT DO NOTHING;

-- Add tenant membership (CRITICAL for menu visibility!)
INSERT INTO public.user_tenant_memberships (user_id, tenant_id, role, is_default)
SELECT id, '00000000-0000-0000-0000-000000000001', 'admin', true 
FROM auth.users 
WHERE email = 'craig@zerobitone.co.za'
ON CONFLICT DO NOTHING;

-- =====================================================
-- VERIFICATION QUERIES
-- Run these to confirm everything worked:
-- =====================================================
-- SELECT COUNT(*) as tenant_count FROM public.tenants;
-- SELECT COUNT(*) as branch_count FROM public.branches;
-- SELECT COUNT(*) as ticket_count FROM public.tickets;
-- SELECT COUNT(*) as license_count FROM public.licenses;
-- SELECT COUNT(*) as hardware_count FROM public.hardware_inventory;
-- SELECT COUNT(*) as network_device_count FROM public.network_devices;
-- SELECT * FROM public.user_roles WHERE user_id = (SELECT id FROM auth.users WHERE email = 'craig@zerobitone.co.za');
-- SELECT * FROM public.user_tenant_memberships WHERE user_id = (SELECT id FROM auth.users WHERE email = 'craig@zerobitone.co.za');
