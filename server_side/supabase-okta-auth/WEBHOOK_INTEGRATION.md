# Supabase Contact Microservice Webhook Integration

## Overview
This document describes the webhook integration between Supabase Auth and the Contact Microservice, enabling automatic contact creation when users register and email confirmation updates.

## Architecture

```
Supabase Auth (auth.users) 
    ↓ Database Trigger
    ↓ HTTP Webhook
Kong API Gateway 
    ↓ Route: /api/v1/webhook/supabase
Contact Microservice 
    ↓ Process Webhook
    ↓ Create/Update Contact
PostgreSQL Database (contacts table)
```

## Components

### 1. Database Trigger (Supabase)
- **File**: `volumes/db/init/contact_webhook.sql`
- **Function**: `send_contact_webhook()`
- **Triggers**: 
  - `trigger_send_contact_webhook_insert` - Fires on user registration
  - `trigger_send_contact_webhook_update` - Fires on email confirmation

### 2. Kong API Gateway
- **Route**: `/api/v1/webhook/supabase`
- **Target**: `http://contact_microservice:8040/webhook/supabase`
- **Configuration**: `volumes/api/kong.yml`

### 3. Contact Microservice
- **Endpoint**: `POST /webhook/supabase`
- **Models**: `WebhookModels.kt`
- **Service**: `WebhookService.kt`
- **Controller**: `WebhookRouting.kt`

## Webhook Payload Format

### User Registration (INSERT)
```json
{
  "type": "INSERT",
  "table": "users",
  "schema": "auth",
  "record": {
    "id": "uuid",
    "email": "user@example.com",
    "email_confirmed_at": null,
    "phone": null,
    "created_at": "2025-01-17T10:30:00.000Z",
    "updated_at": "2025-01-17T10:30:00.000Z",
    "confirmed_at": null,
    "last_sign_in_at": null,
    "app_metadata": {},
    "user_metadata": {},
    "aud": "authenticated",
    "role": "authenticated"
  }
}
```

### Email Confirmation (UPDATE)
```json
{
  "type": "UPDATE",
  "table": "users",
  "schema": "auth",
  "record": {
    "id": "uuid",
    "email": "user@example.com",
    "email_confirmed_at": "2025-01-17T10:35:00.000Z",
    "phone": null,
    "created_at": "2025-01-17T10:30:00.000Z",
    "updated_at": "2025-01-17T10:35:00.000Z",
    "confirmed_at": "2025-01-17T10:35:00.000Z",
    "last_sign_in_at": null,
    "app_metadata": {},
    "user_metadata": {},
    "aud": "authenticated",
    "role": "authenticated"
  },
  "old_record": {
    "id": "uuid",
    "email": "user@example.com",
    "email_confirmed_at": null,
    "phone": null,
    "created_at": "2025-01-17T10:30:00.000Z",
    "updated_at": "2025-01-17T10:30:00.000Z",
    "confirmed_at": null,
    "last_sign_in_at": null,
    "app_metadata": {},
    "user_metadata": {},
    "aud": "authenticated",
    "role": "authenticated"
  }
}
```

## Contact Creation Logic

### User Registration
1. Extract user data from webhook payload
2. Check if contact with email already exists
3. Create new contact with:
   - `id`: Generated UUID
   - `email`: From Supabase user
   - `username`: Extracted from email (before @)
   - `displayName`: Same as username
   - `role`: "user"
   - `locale`: "ru"
   - `timezone`: "Europe/Moscow"
   - `isOnline`: false
   - `createdAt`/`updatedAt`: Current timestamp

### Email Confirmation
1. Find existing contact by email
2. Update `updatedAt` timestamp
3. Log confirmation status change

## API Endpoints

### Webhook Endpoint
```
POST /api/v1/webhook/supabase
Content-Type: application/json

Response:
{
  "success": true,
  "message": "Contact created successfully",
  "contactId": "uuid"
}
```

### Health Check
```
GET /api/v1/webhook/health

Response:
{
  "status": "healthy",
  "service": "webhook",
  "timestamp": 1642512000000
}
```

## Testing

### Manual Testing
```bash
# Run the test script
./test-webhook-integration.sh
```

### Test Scenarios
1. **Health Check**: Verify webhook endpoint is accessible
2. **User Registration**: Create user via Supabase Auth
3. **Webhook Processing**: Check if contact is created automatically
4. **Direct Webhook**: Test webhook endpoint directly
5. **Email Confirmation**: Test email confirmation webhook

### Database Monitoring
```sql
-- Check webhook status
SELECT * FROM webhook_status ORDER BY created_at DESC LIMIT 10;

-- Test webhook manually
SELECT test_contact_webhook();
```

## Error Handling

### Webhook Service Errors
- **Duplicate Email**: Returns error if contact already exists
- **Missing Email**: Returns error if user email is null
- **Database Errors**: Catches and logs database exceptions

### Response Codes
- **200 OK**: Webhook processed successfully
- **400 Bad Request**: Invalid payload or business logic error
- **500 Internal Server Error**: Server-side error

## Security Considerations

### Webhook Validation
- Webhook endpoint is accessible only through Kong API Gateway
- No authentication required (internal network communication)
- Payload validation ensures required fields are present

### Database Security
- Triggers run with `SECURITY DEFINER` privileges
- Limited to specific operations (INSERT/UPDATE on auth.users)
- Webhook requests are logged for audit purposes

## Monitoring and Logging

### Supabase Logs
- Database trigger execution logs
- HTTP request logs in `supabase_functions.hooks` table

### Contact Microservice Logs
- Webhook payload processing logs
- Contact creation/update logs
- Error logs for failed operations

### Kong Logs
- Request routing logs
- Response status logs

## Troubleshooting

### Common Issues

1. **Webhook Not Triggered**
   - Check if triggers are installed: `\d+ auth.users`
   - Verify webhook function exists: `\df send_contact_webhook`

2. **Contact Not Created**
   - Check Contact microservice logs
   - Verify Kong routing configuration
   - Test webhook endpoint directly

3. **Database Connection Issues**
   - Verify Contact microservice database connection
   - Check network connectivity between services

### Debug Commands
```bash
# Check Supabase logs
docker logs supabase-db

# Check Contact microservice logs
docker logs contact_microservice

# Check Kong logs
docker logs supabase-kong

# Test webhook endpoint
curl -X POST http://localhost:8008/api/v1/webhook/supabase \
  -H "Content-Type: application/json" \
  -d '{"type":"INSERT","table":"users","schema":"auth","record":{"id":"test","email":"test@example.com"}}'
```

## Future Enhancements

1. **Retry Logic**: Implement retry mechanism for failed webhooks
2. **Batch Processing**: Handle multiple webhook events in batch
3. **Webhook Signatures**: Add signature verification for security
4. **Metrics**: Add Prometheus metrics for webhook processing
5. **Dead Letter Queue**: Implement queue for failed webhook processing
