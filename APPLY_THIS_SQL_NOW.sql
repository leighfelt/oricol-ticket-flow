-- ============================================================================
-- ORICOL CRM SETUP - APPLY THIS SQL IN SUPABASE SQL EDITOR
-- ============================================================================
-- This SQL creates all the tables needed for the Oricol CRM system.
-- 
-- 🔑 IMPORTANT FOR LOVABLE USERS:
-- Lovable does not run SQL automatically. You must:
-- 1. Access Supabase directly at https://supabase.com/dashboard
-- 2. Log in to your Supabase account (same one connected to Lovable)
-- 3. Find your project (check VITE_SUPABASE_PROJECT_ID in Lovable settings)
-- 4. Click "SQL Editor" in the left sidebar
-- 5. Copy THIS ENTIRE FILE and paste it into a new query
-- 6. Click "Run" to execute
--
-- Alternative: This same SQL exists in the migration file at:
-- supabase/migrations/20251119080900_create_crm_system.sql
-- 
-- HOW TO USE (Step-by-Step):
-- 1. Go to https://supabase.com/dashboard
-- 2. Log in to your Supabase account
-- 3. Select your project (match the project ID from Lovable env vars)
-- 4. Click "SQL Editor" in the left sidebar
-- 5. Click "New query"
-- 6. Copy this ENTIRE file (Ctrl+A, Ctrl+C in your editor)
-- 7. Paste it into the Supabase SQL Editor (Ctrl+V)
-- 8. Click "Run" (or press Ctrl+Enter / Cmd+Enter)
-- 9. You should see "Success. No rows returned"
-- 10. Go back to your Oricol app and refresh the CRM page
--
-- If you see "relation already exists" errors, that's OK - it means the
-- tables are already created. Just ignore those errors.
-- ============================================================================

-- Create CRM Companies table
CREATE TABLE IF NOT EXISTS crm_companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  industry TEXT,
  size TEXT,
  website TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  postal_code TEXT,
  notes TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'prospect')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Create CRM Contacts table
CREATE TABLE IF NOT EXISTS crm_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES crm_companies(id) ON DELETE SET NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  mobile TEXT,
  job_title TEXT,
  department TEXT,
  is_primary BOOLEAN DEFAULT FALSE,
  notes TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Create CRM Deals/Opportunities table
CREATE TABLE IF NOT EXISTS crm_deals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES crm_companies(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES crm_contacts(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  value DECIMAL(15, 2),
  currency TEXT DEFAULT 'USD',
  stage TEXT DEFAULT 'lead' CHECK (stage IN ('lead', 'qualified', 'proposal', 'negotiation', 'won', 'lost')),
  probability INTEGER DEFAULT 0 CHECK (probability >= 0 AND probability <= 100),
  expected_close_date DATE,
  actual_close_date DATE,
  assigned_to UUID REFERENCES auth.users(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Create CRM Activities table
CREATE TABLE IF NOT EXISTS crm_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES crm_companies(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES crm_contacts(id) ON DELETE CASCADE,
  deal_id UUID REFERENCES crm_deals(id) ON DELETE CASCADE,
  activity_type TEXT NOT NULL CHECK (activity_type IN ('call', 'email', 'meeting', 'note', 'task', 'follow_up')),
  subject TEXT NOT NULL,
  description TEXT,
  scheduled_date TIMESTAMPTZ,
  completed_date TIMESTAMPTZ,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_crm_companies_name ON crm_companies(name);
CREATE INDEX IF NOT EXISTS idx_crm_companies_status ON crm_companies(status);
CREATE INDEX IF NOT EXISTS idx_crm_contacts_company_id ON crm_contacts(company_id);
CREATE INDEX IF NOT EXISTS idx_crm_contacts_email ON crm_contacts(email);
CREATE INDEX IF NOT EXISTS idx_crm_deals_company_id ON crm_deals(company_id);
CREATE INDEX IF NOT EXISTS idx_crm_deals_stage ON crm_deals(stage);
CREATE INDEX IF NOT EXISTS idx_crm_deals_assigned_to ON crm_deals(assigned_to);
CREATE INDEX IF NOT EXISTS idx_crm_activities_company_id ON crm_activities(company_id);
CREATE INDEX IF NOT EXISTS idx_crm_activities_contact_id ON crm_activities(contact_id);
CREATE INDEX IF NOT EXISTS idx_crm_activities_deal_id ON crm_activities(deal_id);
CREATE INDEX IF NOT EXISTS idx_crm_activities_status ON crm_activities(status);

-- Enable Row Level Security
ALTER TABLE crm_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_activities ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Admins can view all companies" ON crm_companies;
DROP POLICY IF EXISTS "Admins can insert companies" ON crm_companies;
DROP POLICY IF EXISTS "Admins can update companies" ON crm_companies;
DROP POLICY IF EXISTS "Admins can delete companies" ON crm_companies;

DROP POLICY IF EXISTS "Admins can view all contacts" ON crm_contacts;
DROP POLICY IF EXISTS "Admins can insert contacts" ON crm_contacts;
DROP POLICY IF EXISTS "Admins can update contacts" ON crm_contacts;
DROP POLICY IF EXISTS "Admins can delete contacts" ON crm_contacts;

DROP POLICY IF EXISTS "Admins can view all deals" ON crm_deals;
DROP POLICY IF EXISTS "Admins can insert deals" ON crm_deals;
DROP POLICY IF EXISTS "Admins can update deals" ON crm_deals;
DROP POLICY IF EXISTS "Admins can delete deals" ON crm_deals;

DROP POLICY IF EXISTS "Admins can view all activities" ON crm_activities;
DROP POLICY IF EXISTS "Admins can insert activities" ON crm_activities;
DROP POLICY IF EXISTS "Admins can update activities" ON crm_activities;
DROP POLICY IF EXISTS "Admins can delete activities" ON crm_activities;

-- Create RLS Policies for crm_companies
CREATE POLICY "Admins can view all companies" ON crm_companies
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert companies" ON crm_companies
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update companies" ON crm_companies
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete companies" ON crm_companies
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

-- Create RLS Policies for crm_contacts
CREATE POLICY "Admins can view all contacts" ON crm_contacts
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert contacts" ON crm_contacts
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update contacts" ON crm_contacts
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete contacts" ON crm_contacts
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

-- Create RLS Policies for crm_deals
CREATE POLICY "Admins can view all deals" ON crm_deals
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert deals" ON crm_deals
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update deals" ON crm_deals
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete deals" ON crm_deals
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

-- Create RLS Policies for crm_activities
CREATE POLICY "Admins can view all activities" ON crm_activities
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert activities" ON crm_activities
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update activities" ON crm_activities
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete activities" ON crm_activities
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'admin'
    )
  );

-- Create trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_crm_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist (to avoid conflicts)
DROP TRIGGER IF EXISTS update_crm_companies_updated_at ON crm_companies;
DROP TRIGGER IF EXISTS update_crm_contacts_updated_at ON crm_contacts;
DROP TRIGGER IF EXISTS update_crm_deals_updated_at ON crm_deals;
DROP TRIGGER IF EXISTS update_crm_activities_updated_at ON crm_activities;

-- Create triggers
CREATE TRIGGER update_crm_companies_updated_at
  BEFORE UPDATE ON crm_companies
  FOR EACH ROW
  EXECUTE FUNCTION update_crm_updated_at();

CREATE TRIGGER update_crm_contacts_updated_at
  BEFORE UPDATE ON crm_contacts
  FOR EACH ROW
  EXECUTE FUNCTION update_crm_updated_at();

CREATE TRIGGER update_crm_deals_updated_at
  BEFORE UPDATE ON crm_deals
  FOR EACH ROW
  EXECUTE FUNCTION update_crm_updated_at();

CREATE TRIGGER update_crm_activities_updated_at
  BEFORE UPDATE ON crm_activities
  FOR EACH ROW
  EXECUTE FUNCTION update_crm_updated_at();

-- ============================================================================
-- DONE! You should see "Success. No rows returned" 
-- Now go to your Oricol app and refresh the CRM page - it should work!
-- ============================================================================
