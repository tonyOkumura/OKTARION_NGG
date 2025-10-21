-- Contact Microservice Webhook Integration
-- This script automatically creates webhook triggers for user registration and email confirmation
-- It will be executed during database initialization

-- Enable pg_net extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_net SCHEMA extensions;

-- Create a function to send webhook to contact microservice
CREATE OR REPLACE FUNCTION public.send_contact_webhook()
RETURNS TRIGGER AS $$
DECLARE
    webhook_url TEXT := 'http://contact_microservice:8040/webhook/supabase';
    payload JSONB;
    request_id BIGINT;
BEGIN
    -- Build the payload based on the event type
    IF TG_OP = 'INSERT' THEN
        payload := jsonb_build_object(
            'type', 'INSERT',
            'table', TG_TABLE_NAME,
            'schema', TG_TABLE_SCHEMA,
            'record', row_to_json(NEW)
        );
    ELSIF TG_OP = 'UPDATE' THEN
        payload := jsonb_build_object(
            'type', 'UPDATE',
            'table', TG_TABLE_NAME,
            'schema', TG_TABLE_SCHEMA,
            'record', row_to_json(NEW),
            'old_record', row_to_json(OLD)
        );
    ELSE
        RETURN NEW; -- Do nothing for other operations
    END IF;

    -- Send the HTTP POST request
    SELECT net.http_post(
        url := webhook_url,
        body := payload,
        headers := jsonb_build_object('Content-Type', 'application/json'),
        timeout_ms := 5000
    ) INTO request_id;

    RAISE NOTICE 'Webhook sent to % with request_id % for user %', webhook_url, request_id, NEW.email;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing triggers if they exist to prevent duplicates on re-run
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;

-- Trigger for new user registration (INSERT)
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.send_contact_webhook();

-- Trigger for user updates (e.g., email confirmation)
CREATE TRIGGER on_auth_user_updated
AFTER UPDATE ON auth.users
FOR EACH ROW WHEN (OLD.email_confirmed_at IS DISTINCT FROM NEW.email_confirmed_at)
EXECUTE FUNCTION public.send_contact_webhook();

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.send_contact_webhook() TO postgres, supabase_auth_admin;
GRANT USAGE ON SCHEMA extensions TO postgres, supabase_auth_admin;

-- Log the webhook configuration
DO $$
BEGIN
    RAISE NOTICE 'Contact microservice webhook integration initialized successfully';
END $$;
