#!/bin/bash

# Test script for Supabase Contact Microservice Webhook Integration
# This script tests the webhook integration by creating a test user and checking the webhook response

set -e

# Configuration
SUPABASE_URL="http://localhost:8008"
CONTACT_SERVICE_URL="http://localhost:8008/api/v1/webhook"
API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE"

echo "🧪 Testing Supabase Contact Microservice Webhook Integration"
echo "============================================================"

# Test 1: Check webhook health endpoint
echo "1. Testing webhook health endpoint..."
HEALTH_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/health_response.json "$CONTACT_SERVICE_URL/health")
HEALTH_CODE="${HEALTH_RESPONSE: -3}"

if [ "$HEALTH_CODE" = "200" ]; then
    echo "✅ Webhook health check passed"
    cat /tmp/health_response.json | jq .
else
    echo "❌ Webhook health check failed with code: $HEALTH_CODE"
    cat /tmp/health_response.json
    exit 1
fi

echo ""

# Test 2: Create a test user via Supabase Auth
echo "2. Creating test user via Supabase Auth..."
TEST_EMAIL="test-$(date +%s)@example.com"
TEST_PASSWORD="testpassword123"

USER_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/user_response.json \
    -X POST "$SUPABASE_URL/auth/v1/signup" \
    -H "Content-Type: application/json" \
    -H "apikey: $API_KEY" \
    -d "{
        \"email\": \"$TEST_EMAIL\",
        \"password\": \"$TEST_PASSWORD\"
    }")

USER_CODE="${USER_RESPONSE: -3}"

if [ "$USER_CODE" = "200" ] || [ "$USER_CODE" = "201" ]; then
    echo "✅ Test user created successfully"
    cat /tmp/user_response.json | jq .
    
    # Extract user ID for further testing
    USER_ID=$(cat /tmp/user_response.json | jq -r '.user.id // empty')
    if [ -n "$USER_ID" ]; then
        echo "📝 User ID: $USER_ID"
    fi
else
    echo "❌ Failed to create test user with code: $USER_CODE"
    cat /tmp/user_response.json
    exit 1
fi

echo ""

# Test 3: Wait a moment for webhook processing
echo "3. Waiting for webhook processing..."
sleep 3

# Test 4: Check if contact was created in the microservice
echo "4. Checking if contact was created in microservice..."
if [ -n "$USER_ID" ]; then
    CONTACT_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/contact_response.json \
        -X GET "$CONTACT_SERVICE_URL/../contacts/" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Okta-User-ID: $USER_ID")
    
    CONTACT_CODE="${CONTACT_RESPONSE: -3}"
    
    if [ "$CONTACT_CODE" = "200" ]; then
        echo "✅ Contact microservice accessible"
        cat /tmp/contact_response.json | jq .
    else
        echo "⚠️  Contact microservice returned code: $CONTACT_CODE"
        cat /tmp/contact_response.json
    fi
fi

echo ""

# Test 5: Test webhook endpoint directly (simulation)
echo "5. Testing webhook endpoint directly..."
WEBHOOK_PAYLOAD='{
    "type": "INSERT",
    "table": "users",
    "schema": "auth",
    "record": {
        "id": "'$USER_ID'",
        "email": "'$TEST_EMAIL'",
        "email_confirmed_at": null,
        "created_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
        "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"
    }
}'

DIRECT_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/direct_response.json \
    -X POST "$CONTACT_SERVICE_URL/supabase" \
    -H "Content-Type: application/json" \
    -d "$WEBHOOK_PAYLOAD")

DIRECT_CODE="${DIRECT_RESPONSE: -3}"

if [ "$DIRECT_CODE" = "200" ]; then
    echo "✅ Direct webhook test passed"
    cat /tmp/direct_response.json | jq .
else
    echo "❌ Direct webhook test failed with code: $DIRECT_CODE"
    cat /tmp/direct_response.json
fi

echo ""

# Test 6: Test email confirmation webhook
echo "6. Testing email confirmation webhook..."
CONFIRMATION_PAYLOAD='{
    "type": "UPDATE",
    "table": "users",
    "schema": "auth",
    "record": {
        "id": "'$USER_ID'",
        "email": "'$TEST_EMAIL'",
        "email_confirmed_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
        "created_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
        "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"
    },
    "old_record": {
        "id": "'$USER_ID'",
        "email": "'$TEST_EMAIL'",
        "email_confirmed_at": null,
        "created_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
        "updated_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"
    }
}'

CONFIRMATION_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/confirmation_response.json \
    -X POST "$CONTACT_SERVICE_URL/supabase" \
    -H "Content-Type: application/json" \
    -d "$CONFIRMATION_PAYLOAD")

CONFIRMATION_CODE="${CONFIRMATION_RESPONSE: -3}"

if [ "$CONFIRMATION_CODE" = "200" ]; then
    echo "✅ Email confirmation webhook test passed"
    cat /tmp/confirmation_response.json | jq .
else
    echo "❌ Email confirmation webhook test failed with code: $CONFIRMATION_CODE"
    cat /tmp/confirmation_response.json
fi

echo ""
echo "🎉 Webhook integration test completed!"
echo "======================================"
echo "Test user email: $TEST_EMAIL"
echo "User ID: $USER_ID"
echo ""
echo "Next steps:"
echo "1. Check Supabase logs for webhook triggers"
echo "2. Check Contact microservice logs for webhook processing"
echo "3. Verify contact creation in the database"
echo "4. Test with real user registration flow"
