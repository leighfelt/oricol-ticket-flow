-- Add unique constraints required for upserts in sync-microsoft-365 function
-- 1) Licenses: onConflict('license_name,vendor')
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'licenses_license_name_vendor_key'
  ) THEN
    ALTER TABLE public.licenses
    ADD CONSTRAINT licenses_license_name_vendor_key UNIQUE (license_name, vendor);
  END IF;
END $$;

-- 2) Hardware inventory: onConflict('serial_number')
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'hardware_inventory_serial_number_key'
  ) THEN
    ALTER TABLE public.hardware_inventory
    ADD CONSTRAINT hardware_inventory_serial_number_key UNIQUE (serial_number);
  END IF;
END $$;

-- 3) Profiles: onConflict('email')
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'profiles_email_key'
  ) THEN
    ALTER TABLE public.profiles
    ADD CONSTRAINT profiles_email_key UNIQUE (email);
  END IF;
END $$;