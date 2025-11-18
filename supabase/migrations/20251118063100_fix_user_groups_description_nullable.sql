-- Fix: Make description column nullable in user_groups table
-- This fixes the error: null value in column "description" of relation "user_groups" violates not-null constraint
-- Error code: 23502

-- The description field should be optional when creating user groups
-- This aligns with the frontend code which allows users to skip the description field

ALTER TABLE public.user_groups 
ALTER COLUMN description DROP NOT NULL;

-- Add comment to document this change
COMMENT ON COLUMN public.user_groups.description IS 'Optional description of the user group purpose';
