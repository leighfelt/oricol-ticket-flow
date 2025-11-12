-- Update handle_new_user function to automatically assign roles
-- This ensures craig@zerobitone.co.za gets admin role when profile is created
-- and all other users get the default 'user' role

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Create profile for the new user
  INSERT INTO public.profiles (user_id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email
  );
  
  -- Automatically assign admin role to craig@zerobitone.co.za
  -- This ensures admin access regardless of where the app is running (Lovable or local)
  IF NEW.email = 'craig@zerobitone.co.za' THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'admin'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  
  -- Assign default 'user' role to all users (including admin)
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'user'::app_role)
  ON CONFLICT (user_id, role) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Also ensure that if craig@zerobitone.co.za already exists, they get the admin role
-- This handles the case where the user was created before this migration
INSERT INTO public.user_roles (user_id, role)
SELECT 
  au.id,
  'admin'::app_role
FROM auth.users au
WHERE au.email = 'craig@zerobitone.co.za'
ON CONFLICT (user_id, role) DO NOTHING;
