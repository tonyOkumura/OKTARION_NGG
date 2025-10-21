package com.contact_micro.model

import kotlinx.serialization.Serializable
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.*

@Serializable
data class Contact(
    val id: String? = null, // UUID
    val username: String? = null,
    val firstName: String? = null,
    val lastName: String? = null,
    val displayName: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val isOnline: Boolean = false,
    val lastSeenAt: String? = null, // ISO timestamp string
    val statusMessage: String? = null,
    val role: String = "user",
    val department: String? = null,
    val rank: String? = null,
    val position: String? = null,
    val company: String? = null,
    val avatarUrl: String? = null, // Avatar URL
    val dateOfBirth: String? = null, // ISO date string
    val locale: String = "ru",
    val timezone: String = "Europe/Moscow",
    val createdAt: String? = null, // ISO timestamp string
    val updatedAt: String? = null // ISO timestamp string
)

@Serializable
data class ContactCreateRequest(
    val email: String
)

@Serializable
data class ContactUpdateRequest(
    val username: String? = null,
    val firstName: String? = null,
    val lastName: String? = null,
    val displayName: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val isOnline: Boolean? = null,
    val statusMessage: String? = null,
    val role: String? = null,
    val department: String? = null,
    val rank: String? = null,
    val position: String? = null,
    val company: String? = null,
    val avatarUrl: String? = null,
    val dateOfBirth: String? = null,
    val locale: String? = null,
    val timezone: String? = null
)

@Serializable
data class ContactSearchResponse(
    val contacts: List<Contact>,
    val hasMore: Boolean,
    val nextCursor: String? = null,
    val totalCount: Int? = null
)
