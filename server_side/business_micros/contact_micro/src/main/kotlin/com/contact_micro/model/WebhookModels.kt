package com.contact_micro.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonIgnoreUnknownKeys

@Serializable
data class SupabaseWebhookPayload(
    val type: String,
    val table: String,
    val schema: String,
    val record: SupabaseUser? = null,
    val old_record: SupabaseUser? = null
)

@Serializable
@JsonIgnoreUnknownKeys
data class SupabaseUser(
    val id: String,
    val email: String? = null,
    val email_confirmed_at: String? = null,
    val phone: String? = null,
    val phone_confirmed_at: String? = null,
    val created_at: String,
    val updated_at: String,
    val confirmed_at: String? = null,
    val last_sign_in_at: String? = null,
    val app_metadata: Map<String, String>? = null,
    val user_metadata: Map<String, String>? = null,
    val aud: String? = null,
    val role: String? = null
)

@Serializable
data class WebhookResponse(
    val success: Boolean,
    val message: String,
    val contactId: String? = null
)
