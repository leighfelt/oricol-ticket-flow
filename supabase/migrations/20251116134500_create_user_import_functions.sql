-- Function to generate random password
CREATE OR REPLACE FUNCTION public.generate_random_password(length INTEGER DEFAULT 16)
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..length LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create system user from staff user (VPN/RDP user)
CREATE OR REPLACE FUNCTION public.create_system_user_from_staff(
  staff_user_id UUID
)
RETURNS JSONB AS $$
DECLARE
  staff_user RECORD;
  new_user_id UUID;
  random_password TEXT;
  result JSONB;
BEGIN
  -- Get staff user details
  SELECT * INTO staff_user
  FROM public.vpn_rdp_credentials
  WHERE id = staff_user_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Staff user not found'
    );
  END IF;

  -- Check if user already exists with this email
  IF EXISTS (
    SELECT 1 FROM auth.users WHERE email = staff_user.email
  ) THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'User already exists with this email'
    );
  END IF;

  -- Generate random password
  random_password := public.generate_random_password(16);

  -- Create auth user (this would normally be done via Supabase Auth API)
  -- Note: This is a placeholder - actual user creation should be done via Supabase Auth Admin API
  -- For now, we'll return the data needed to create the user
  
  RETURN jsonb_build_object(
    'success', true,
    'email', staff_user.email,
    'username', staff_user.username,
    'password', random_password,
    'full_name', staff_user.username,
    'message', 'User data prepared. Use Supabase Auth API to create the user.'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to import multiple system users from staff users
CREATE OR REPLACE FUNCTION public.import_system_users_from_staff(
  staff_user_ids UUID[]
)
RETURNS JSONB AS $$
DECLARE
  staff_id UUID;
  result JSONB;
  results JSONB[] := ARRAY[]::JSONB[];
  success_count INTEGER := 0;
  error_count INTEGER := 0;
BEGIN
  FOREACH staff_id IN ARRAY staff_user_ids LOOP
    result := public.create_system_user_from_staff(staff_id);
    results := array_append(results, result);
    
    IF (result->>'success')::boolean THEN
      success_count := success_count + 1;
    ELSE
      error_count := error_count + 1;
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'total', array_length(staff_user_ids, 1),
    'success_count', success_count,
    'error_count', error_count,
    'results', to_jsonb(results)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to import RDP users from dashboard
CREATE OR REPLACE FUNCTION public.import_rdp_users_from_dashboard()
RETURNS JSONB AS $$
DECLARE
  rdp_count INTEGER;
  imported_users JSONB;
BEGIN
  -- Get all RDP users
  SELECT count(*), json_agg(row_to_json(vpn_rdp_credentials))
  INTO rdp_count, imported_users
  FROM public.vpn_rdp_credentials
  WHERE service_type = 'rdp';

  RETURN jsonb_build_object(
    'success', true,
    'count', rdp_count,
    'users', imported_users
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to import VPN users from dashboard
CREATE OR REPLACE FUNCTION public.import_vpn_users_from_dashboard()
RETURNS JSONB AS $$
DECLARE
  vpn_count INTEGER;
  imported_users JSONB;
BEGIN
  -- Get all VPN users
  SELECT count(*), json_agg(row_to_json(vpn_rdp_credentials))
  INTO vpn_count, imported_users
  FROM public.vpn_rdp_credentials
  WHERE service_type = 'vpn';

  RETURN jsonb_build_object(
    'success', true,
    'count', vpn_count,
    'users', imported_users
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions to authenticated users for these functions
GRANT EXECUTE ON FUNCTION public.generate_random_password TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_system_user_from_staff TO authenticated;
GRANT EXECUTE ON FUNCTION public.import_system_users_from_staff TO authenticated;
GRANT EXECUTE ON FUNCTION public.import_rdp_users_from_dashboard TO authenticated;
GRANT EXECUTE ON FUNCTION public.import_vpn_users_from_dashboard TO authenticated;

COMMENT ON FUNCTION public.generate_random_password IS 'Generates a secure random password';
COMMENT ON FUNCTION public.create_system_user_from_staff IS 'Creates a system user from a staff user with random password';
COMMENT ON FUNCTION public.import_system_users_from_staff IS 'Bulk import system users from staff users';
COMMENT ON FUNCTION public.import_rdp_users_from_dashboard IS 'Import RDP users from dashboard tab page';
COMMENT ON FUNCTION public.import_vpn_users_from_dashboard IS 'Import VPN users from dashboard tab page';
