-- Migration to backfill missing profiles for existing auth users
-- This fixes the "user not found" error that prevents users from viewing/adding tickets
--
-- Issue: Some users can authenticate but don't have profile records
-- Root cause: handle_new_user() trigger may not have fired during signup or profiles were deleted
-- Solution: Create missing profiles for all auth users who don't have one

-- Insert missing profiles for all auth users who don't have a profile record
INSERT INTO public.profiles (user_id, full_name, email)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'full_name', ''),
  au.email
FROM auth.users au
LEFT JOIN public.profiles p ON p.user_id = au.id
WHERE p.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- Update the handle_new_user function to be more robust
-- Add error handling to prevent profile creation failures
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Create profile for the new user
  -- Use ON CONFLICT to handle race conditions
  INSERT INTO public.profiles (user_id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email
  )
  ON CONFLICT (user_id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name);
  
  -- Automatically assign admin role to craig@zerobitone.co.za
  IF NEW.email = 'craig@zerobitone.co.za' THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'admin'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  
  -- Automatically assign admin role to admin@oricol.co.za
  IF NEW.email = 'admin@oricol.co.za' THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'admin'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  
  -- Automatically assign admin role to admin@zerobitone.co.za
  IF NEW.email = 'admin@zerobitone.co.za' THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'admin'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  
  -- Automatically assign CEO role to Graeme Smart
  IF NEW.email ILIKE '%graeme%smart%' 
     OR NEW.email ILIKE '%smart%graeme%'
     OR LOWER(COALESCE(NEW.raw_user_meta_data->>'full_name', '')) LIKE '%graeme%smart%' THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'ceo'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  
  -- Assign default 'user' role to all users
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'user'::app_role)
  ON CONFLICT (user_id, role) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the user creation
    RAISE WARNING 'Error in handle_new_user for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Add a helpful comment
COMMENT ON MIGRATION IS 'Backfills missing profiles for existing auth users and adds error handling to handle_new_user() trigger';
