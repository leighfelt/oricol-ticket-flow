-- Create directory_users table for Microsoft 365 directory sync (separate from auth profiles)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'directory_users'
  ) THEN
    CREATE TABLE public.directory_users (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      aad_id text,
      display_name text,
      email text,
      user_principal_name text,
      job_title text,
      department text,
      account_enabled boolean,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    );
  END IF;
END $$;

-- Unique constraints for reliable upserts
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'directory_users_aad_id_key'
  ) THEN
    ALTER TABLE public.directory_users
    ADD CONSTRAINT directory_users_aad_id_key UNIQUE (aad_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'directory_users_email_key'
  ) THEN
    ALTER TABLE public.directory_users
    ADD CONSTRAINT directory_users_email_key UNIQUE (email);
  END IF;
END $$;

-- Enable RLS and allow only admins/support to read via client
ALTER TABLE public.directory_users ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'directory_users' AND policyname = 'Admins and support can view directory users'
  ) THEN
    CREATE POLICY "Admins and support can view directory users"
    ON public.directory_users
    FOR SELECT
    USING (
      has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'support_staff'::app_role)
    );
  END IF;
END $$;

-- updated_at trigger
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'handle_updated_at_directory_users'
  ) THEN
    CREATE TRIGGER handle_updated_at_directory_users
    BEFORE UPDATE ON public.directory_users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END $$;