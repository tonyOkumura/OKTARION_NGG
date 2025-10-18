package com.conversation_micro.plugin

import com.conversation_micro.model.ConversationCreateRequest
import com.conversation_micro.model.ConversationUpdateRequest
import com.conversation_micro.model.ParticipantCreateRequest
import com.conversation_micro.model.ParticipantUpdateRequest
import com.conversation_micro.model.AddParticipantsRequest
import com.conversation_micro.model.RemoveParticipantsRequest
import com.conversation_micro.model.ValidationError
import io.ktor.server.application.*
import io.ktor.server.plugins.requestvalidation.*
import java.util.UUID

fun Application.configureValidation() {
    install(RequestValidation) {
        // Validation for conversations will be handled manually in controllers
    }
}

// Conversation validation functions
fun validateConversationCreate(request: ConversationCreateRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Validate name (optional but if provided, should be valid)
    if (request.name != null) {
        if (request.name.isBlank()) {
            errors.add(ValidationError("name", "Conversation name cannot be blank"))
        } else if (request.name.length > 100) {
            errors.add(ValidationError("name", "Conversation name cannot exceed 100 characters"))
        }
    }
    
    // Validate category (optional but if provided, should be valid)
    if (request.category != null) {
        if (request.category.isBlank()) {
            errors.add(ValidationError("category", "Category cannot be blank"))
        } else if (request.category.length > 50) {
            errors.add(ValidationError("category", "Category cannot exceed 50 characters"))
        }
    }
    
    // Validate avatar file ID (optional but if provided, should be valid UUID)
    if (request.avatarFileId != null) {
        if (request.avatarFileId.isBlank()) {
            errors.add(ValidationError("avatarFileId", "Avatar file ID cannot be blank"))
        } else {
            try {
                UUID.fromString(request.avatarFileId)
            } catch (e: IllegalArgumentException) {
                errors.add(ValidationError("avatarFileId", "Avatar file ID must be a valid UUID"))
            }
        }
    }
    
    // Validate participants (optional but if provided, should be valid UUIDs)
    // Note: participants list excludes the creator, who is automatically added
    request.participants.forEachIndexed { index, participantId ->
        if (participantId.isBlank()) {
            errors.add(ValidationError("participants[$index]", "Participant ID cannot be blank"))
        } else {
            try {
                UUID.fromString(participantId)
            } catch (e: IllegalArgumentException) {
                errors.add(ValidationError("participants[$index]", "Participant ID must be a valid UUID"))
            }
        }
    }
    
    return errors
}

fun validateConversationUpdate(request: ConversationUpdateRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Validate name (optional but if provided, should be valid)
    if (request.name != null) {
        if (request.name.isBlank()) {
            errors.add(ValidationError("name", "Conversation name cannot be blank"))
        } else if (request.name.length > 100) {
            errors.add(ValidationError("name", "Conversation name cannot exceed 100 characters"))
        }
    }
    
    // Validate category (optional but if provided, should be valid)
    if (request.category != null) {
        if (request.category.isBlank()) {
            errors.add(ValidationError("category", "Category cannot be blank"))
        } else if (request.category.length > 50) {
            errors.add(ValidationError("category", "Category cannot exceed 50 characters"))
        }
    }
    
    // Validate avatar file ID (optional but if provided, should be valid UUID)
    if (request.avatarFileId != null) {
        if (request.avatarFileId.isBlank()) {
            errors.add(ValidationError("avatarFileId", "Avatar file ID cannot be blank"))
        } else {
            try {
                UUID.fromString(request.avatarFileId)
            } catch (e: IllegalArgumentException) {
                errors.add(ValidationError("avatarFileId", "Avatar file ID must be a valid UUID"))
            }
        }
    }
    
    return errors
}

// Participant validation functions
fun validateParticipantCreate(request: ParticipantCreateRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Validate conversation ID
    if (request.conversationId.isBlank()) {
        errors.add(ValidationError("conversationId", "Conversation ID cannot be blank"))
    } else {
        try {
            UUID.fromString(request.conversationId)
        } catch (e: IllegalArgumentException) {
            errors.add(ValidationError("conversationId", "Conversation ID must be a valid UUID"))
        }
    }
    
    // Validate contact ID
    if (request.contactId.isBlank()) {
        errors.add(ValidationError("contactId", "Contact ID cannot be blank"))
    } else {
        try {
            UUID.fromString(request.contactId)
        } catch (e: IllegalArgumentException) {
            errors.add(ValidationError("contactId", "Contact ID must be a valid UUID"))
        }
    }
    
    // Validate role
    if (request.role.isBlank()) {
        errors.add(ValidationError("role", "Role cannot be blank"))
    } else if (!request.role.matches(Regex("^(owner|admin|member)$"))) {
        errors.add(ValidationError("role", "Role must be one of: owner, admin, member"))
    }
    
    // Validate alias (optional but if provided, should be valid)
    if (request.alias != null) {
        if (request.alias.isBlank()) {
            errors.add(ValidationError("alias", "Alias cannot be blank"))
        } else if (request.alias.length > 100) {
            errors.add(ValidationError("alias", "Alias cannot exceed 100 characters"))
        }
    }
    
    return errors
}

fun validateParticipantUpdate(request: ParticipantUpdateRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Validate role (optional but if provided, should be valid)
    if (request.role != null) {
        if (request.role.isBlank()) {
            errors.add(ValidationError("role", "Role cannot be blank"))
        } else if (!request.role.matches(Regex("^(owner|admin|member)$"))) {
            errors.add(ValidationError("role", "Role must be one of: owner, admin, member"))
        }
    }
    
    // Validate alias (optional but if provided, should be valid)
    if (request.alias != null) {
        if (request.alias.isBlank()) {
            errors.add(ValidationError("alias", "Alias cannot be blank"))
        } else if (request.alias.length > 100) {
            errors.add(ValidationError("alias", "Alias cannot exceed 100 characters"))
        }
    }
    
    // Validate unread count (optional but if provided, should be non-negative)
    if (request.unreadCount != null) {
        if (request.unreadCount < 0) {
            errors.add(ValidationError("unreadCount", "Unread count cannot be negative"))
        }
    }
    
    // Validate last read at (optional but if provided, should be valid timestamp)
    if (request.lastReadAt != null) {
        if (request.lastReadAt.isBlank()) {
            errors.add(ValidationError("lastReadAt", "Last read at cannot be blank"))
        } else {
            try {
                java.sql.Timestamp.valueOf(request.lastReadAt)
            } catch (e: IllegalArgumentException) {
                errors.add(ValidationError("lastReadAt", "Last read at must be a valid timestamp (yyyy-MM-dd HH:mm:ss)"))
            }
        }
    }
    
    // Validate last message read ID (optional but if provided, should be valid UUID)
    if (request.lastMessageReadId != null) {
        if (request.lastMessageReadId.isBlank()) {
            errors.add(ValidationError("lastMessageReadId", "Last message read ID cannot be blank"))
        } else {
            try {
                UUID.fromString(request.lastMessageReadId)
            } catch (e: IllegalArgumentException) {
                errors.add(ValidationError("lastMessageReadId", "Last message read ID must be a valid UUID"))
            }
        }
    }
    
    return errors
}

// Add/Remove participants validation functions
fun validateAddParticipants(request: AddParticipantsRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Validate contact IDs list
    if (request.contactIds.isEmpty()) {
        errors.add(ValidationError("contactIds", "At least one contact ID is required"))
    } else if (request.contactIds.size > 50) {
        errors.add(ValidationError("contactIds", "Cannot add more than 50 participants at once"))
    }
    
    // Validate each contact ID
    request.contactIds.forEachIndexed { index, contactId ->
        if (contactId.isBlank()) {
            errors.add(ValidationError("contactIds[$index]", "Contact ID cannot be blank"))
        } else {
            try {
                UUID.fromString(contactId)
            } catch (e: IllegalArgumentException) {
                errors.add(ValidationError("contactIds[$index]", "Contact ID must be a valid UUID"))
            }
        }
    }
    
    // Check for duplicates
    val duplicates = request.contactIds.groupingBy { it }.eachCount().filter { it.value > 1 }
    if (duplicates.isNotEmpty()) {
        errors.add(ValidationError("contactIds", "Duplicate contact IDs are not allowed"))
    }
    
    return errors
}

fun validateRemoveParticipants(request: RemoveParticipantsRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Validate contact IDs list
    if (request.contactIds.isEmpty()) {
        errors.add(ValidationError("contactIds", "At least one contact ID is required"))
    } else if (request.contactIds.size > 50) {
        errors.add(ValidationError("contactIds", "Cannot remove more than 50 participants at once"))
    }
    
    // Validate each contact ID
    request.contactIds.forEachIndexed { index, contactId ->
        if (contactId.isBlank()) {
            errors.add(ValidationError("contactIds[$index]", "Contact ID cannot be blank"))
        } else {
            try {
                UUID.fromString(contactId)
            } catch (e: IllegalArgumentException) {
                errors.add(ValidationError("contactIds[$index]", "Contact ID must be a valid UUID"))
            }
        }
    }
    
    // Check for duplicates
    val duplicates = request.contactIds.groupingBy { it }.eachCount().filter { it.value > 1 }
    if (duplicates.isNotEmpty()) {
        errors.add(ValidationError("contactIds", "Duplicate contact IDs are not allowed"))
    }
    
    return errors
}
