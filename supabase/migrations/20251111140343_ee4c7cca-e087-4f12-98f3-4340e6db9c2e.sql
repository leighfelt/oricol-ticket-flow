-- Update remote_sessions table to support different connection types
ALTER TABLE public.remote_sessions 
ADD COLUMN connection_type TEXT DEFAULT 'screen_share' CHECK (connection_type IN ('screen_share', 'chrome_remote', 'rdp', 'vnc')),
ADD COLUMN connection_details JSONB;

-- Add comment for clarity
COMMENT ON COLUMN public.remote_sessions.connection_type IS 'Type of remote connection: screen_share, chrome_remote, rdp, or vnc';
COMMENT ON COLUMN public.remote_sessions.connection_details IS 'Connection-specific details like RDP hostname, VNC port, Chrome Remote code, etc.';