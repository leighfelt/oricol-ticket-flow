-- Add time tracking and reminder fields to tickets table
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'tickets' AND column_name = 'time_spent_minutes'
  ) THEN
    ALTER TABLE public.tickets ADD COLUMN time_spent_minutes integer DEFAULT 0;
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'tickets' AND column_name = 'last_activity_at'
  ) THEN
    ALTER TABLE public.tickets ADD COLUMN last_activity_at timestamptz;
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'tickets' AND column_name = 'reminder_sent_at'
  ) THEN
    ALTER TABLE public.tickets ADD COLUMN reminder_sent_at timestamptz;
  END IF;
END $$;

-- Create ticket_time_logs table for detailed time tracking
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'ticket_time_logs'
  ) THEN
    CREATE TABLE public.ticket_time_logs (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      ticket_id uuid NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
      user_id uuid NOT NULL,
      minutes integer NOT NULL,
      notes text,
      logged_at timestamptz NOT NULL DEFAULT now(),
      created_at timestamptz NOT NULL DEFAULT now()
    );
  END IF;
END $$;

-- Enable RLS on ticket_time_logs
ALTER TABLE public.ticket_time_logs ENABLE ROW LEVEL SECURITY;

-- Allow support staff and admins to view and log time
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'ticket_time_logs' AND policyname = 'Support staff can view time logs'
  ) THEN
    CREATE POLICY "Support staff can view time logs"
    ON public.ticket_time_logs
    FOR SELECT
    USING (
      has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'support_staff'::app_role)
    );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'ticket_time_logs' AND policyname = 'Support staff can log time'
  ) THEN
    CREATE POLICY "Support staff can log time"
    ON public.ticket_time_logs
    FOR INSERT
    WITH CHECK (
      has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'support_staff'::app_role)
    );
  END IF;
END $$;

-- Update last_activity_at on ticket updates
CREATE OR REPLACE FUNCTION update_ticket_activity()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_activity_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'update_ticket_activity_trigger'
  ) THEN
    CREATE TRIGGER update_ticket_activity_trigger
    BEFORE UPDATE ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_ticket_activity();
  END IF;
END $$;