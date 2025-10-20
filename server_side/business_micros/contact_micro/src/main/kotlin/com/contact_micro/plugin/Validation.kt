package com.contact_micro.plugin

import com.contact_micro.model.ContactCreateRequest
import com.contact_micro.model.ContactUpdateRequest
import com.contact_micro.model.ValidationError
import io.ktor.server.application.*
import io.ktor.server.plugins.requestvalidation.*
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException
import java.util.regex.Pattern

// Contact validation functions
fun validateContactCreate(contact: ContactCreateRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Username validation (обязательное поле)
    if (contact.username.isNullOrBlank()) {
        errors.add(ValidationError("username", "Username is required"))
    } else {
        if (contact.username.length < 3) {
            errors.add(ValidationError("username", "Username must be at least 3 characters"))
        } else if (contact.username.length > 255) {
            errors.add(ValidationError("username", "Username cannot exceed 255 characters"))
        } else if (!contact.username.matches(Regex("^[a-zA-Z0-9_-]+$"))) {
            errors.add(ValidationError("username", "Username can only contain letters, numbers, underscores and hyphens"))
        }
    }
    
    // Email validation (опциональное поле)
    if (contact.email != null) {
        if (!isValidEmail(contact.email)) {
            errors.add(ValidationError("email", "Invalid email format"))
        } else if (contact.email.length > 255) {
            errors.add(ValidationError("email", "Email cannot exceed 255 characters"))
        }
    }
    
    // Phone validation (опциональное поле)
    if (contact.phone != null) {
        if (!isValidPhone(contact.phone)) {
            errors.add(ValidationError("phone", "Invalid phone format"))
        } else if (contact.phone.length > 30) {
            errors.add(ValidationError("phone", "Phone cannot exceed 30 characters"))
        }
    }
    
    // Name validation (опциональные поля)
    if (contact.firstName != null && contact.firstName.length > 100) {
        errors.add(ValidationError("firstName", "First name cannot exceed 100 characters"))
    }
    
    if (contact.lastName != null && contact.lastName.length > 100) {
        errors.add(ValidationError("lastName", "Last name cannot exceed 100 characters"))
    }
    
    if (contact.displayName != null && contact.displayName.length > 255) {
        errors.add(ValidationError("displayName", "Display name cannot exceed 255 characters"))
    }
    
    // Status message validation
    if (contact.statusMessage != null && contact.statusMessage.length > 255) {
        errors.add(ValidationError("statusMessage", "Status message cannot exceed 255 characters"))
    }
    
    // Role validation
    if (!isValidRole(contact.role)) {
        errors.add(ValidationError("role", "Invalid role. Must be one of: user, admin, moderator"))
    }
    
    // Department validation
    if (contact.department != null && contact.department.length > 255) {
        errors.add(ValidationError("department", "Department cannot exceed 255 characters"))
    }
    
    // Rank validation
    if (contact.rank != null && contact.rank.length > 100) {
        errors.add(ValidationError("rank", "Rank cannot exceed 100 characters"))
    }
    
    // Position validation
    if (contact.position != null && contact.position.length > 255) {
        errors.add(ValidationError("position", "Position cannot exceed 255 characters"))
    }
    
    // Company validation
    if (contact.company != null && contact.company.length > 255) {
        errors.add(ValidationError("company", "Company cannot exceed 255 characters"))
    }
    
    // Avatar URL validation
    if (contact.avatarUrl != null && !isValidUrl(contact.avatarUrl)) {
        errors.add(ValidationError("avatarUrl", "Avatar URL must be a valid URL"))
    }
    
    // Date of birth validation
    if (contact.dateOfBirth != null && !isValidDate(contact.dateOfBirth)) {
        errors.add(ValidationError("dateOfBirth", "Date of birth must be in YYYY-MM-DD format"))
    }
    
    // Locale validation
    if (!isValidLocale(contact.locale)) {
        errors.add(ValidationError("locale", "Invalid locale format"))
    }
    
    // Timezone validation
    if (!isValidTimezone(contact.timezone)) {
        errors.add(ValidationError("timezone", "Invalid timezone format"))
    }
    
    return errors
}

fun validateContactUpdate(contact: ContactUpdateRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Email validation
    if (contact.email != null) {
        if (!isValidEmail(contact.email)) {
            errors.add(ValidationError("email", "Invalid email format"))
        } else if (contact.email.length > 255) {
            errors.add(ValidationError("email", "Email cannot exceed 255 characters"))
        }
    }
    
    // Username validation
    if (contact.username != null) {
        if (contact.username.length < 3) {
            errors.add(ValidationError("username", "Username must be at least 3 characters"))
        } else if (contact.username.length > 255) {
            errors.add(ValidationError("username", "Username cannot exceed 255 characters"))
        } else if (!contact.username.matches(Regex("^[a-zA-Z0-9_-]+$"))) {
            errors.add(ValidationError("username", "Username can only contain letters, numbers, underscores and hyphens"))
        }
    }
    
    // Phone validation
    if (contact.phone != null) {
        if (!isValidPhone(contact.phone)) {
            errors.add(ValidationError("phone", "Invalid phone format"))
        } else if (contact.phone.length > 30) {
            errors.add(ValidationError("phone", "Phone cannot exceed 30 characters"))
        }
    }
    
    // Name validation
    if (contact.firstName != null && contact.firstName.length > 100) {
        errors.add(ValidationError("firstName", "First name cannot exceed 100 characters"))
    }
    
    if (contact.lastName != null && contact.lastName.length > 100) {
        errors.add(ValidationError("lastName", "Last name cannot exceed 100 characters"))
    }
    
    if (contact.displayName != null && contact.displayName.length > 255) {
        errors.add(ValidationError("displayName", "Display name cannot exceed 255 characters"))
    }
    
    // Status message validation
    if (contact.statusMessage != null && contact.statusMessage.length > 255) {
        errors.add(ValidationError("statusMessage", "Status message cannot exceed 255 characters"))
    }
    
    // Role validation
    if (contact.role != null && !isValidRole(contact.role)) {
        errors.add(ValidationError("role", "Invalid role. Must be one of: user, admin, moderator"))
    }
    
    // Department validation
    if (contact.department != null && contact.department.length > 255) {
        errors.add(ValidationError("department", "Department cannot exceed 255 characters"))
    }
    
    // Rank validation
    if (contact.rank != null && contact.rank.length > 100) {
        errors.add(ValidationError("rank", "Rank cannot exceed 100 characters"))
    }
    
    // Position validation
    if (contact.position != null && contact.position.length > 255) {
        errors.add(ValidationError("position", "Position cannot exceed 255 characters"))
    }
    
    // Company validation
    if (contact.company != null && contact.company.length > 255) {
        errors.add(ValidationError("company", "Company cannot exceed 255 characters"))
    }
    
    // Avatar URL validation
    if (contact.avatarUrl != null && !isValidUrl(contact.avatarUrl)) {
        errors.add(ValidationError("avatarUrl", "Avatar URL must be a valid URL"))
    }
    
    // Date of birth validation
    if (contact.dateOfBirth != null && !isValidDate(contact.dateOfBirth)) {
        errors.add(ValidationError("dateOfBirth", "Date of birth must be in YYYY-MM-DD format"))
    }
    
    // Locale validation
    if (contact.locale != null && !isValidLocale(contact.locale)) {
        errors.add(ValidationError("locale", "Invalid locale format"))
    }
    
    // Timezone validation
    if (contact.timezone != null && !isValidTimezone(contact.timezone)) {
        errors.add(ValidationError("timezone", "Invalid timezone format"))
    }
    
    return errors
}

// Helper validation functions
private fun isValidEmail(email: String): Boolean {
    val emailPattern = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    return emailPattern.matcher(email).matches()
}

private fun isValidPhone(phone: String): Boolean {
    val phonePattern = Pattern.compile("^[+]?[0-9\\s\\-\\(\\)]{7,30}$")
    return phonePattern.matcher(phone).matches()
}

private fun isValidRole(role: String): Boolean {
    return role in listOf("user", "admin", "moderator")
}

private fun isValidUUID(uuid: String): Boolean {
    val uuidPattern = Pattern.compile("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", Pattern.CASE_INSENSITIVE)
    val uuidWithoutDashesPattern = Pattern.compile("^[0-9a-f]{32}$", Pattern.CASE_INSENSITIVE)
    return uuidPattern.matcher(uuid).matches() || uuidWithoutDashesPattern.matcher(uuid).matches()
}

private fun isValidUrl(url: String): Boolean {
    try {
        java.net.URL(url)
        return true
    } catch (e: Exception) {
        return false
    }
}

private fun isValidDate(date: String): Boolean {
    return try {
        LocalDate.parse(date, DateTimeFormatter.ISO_LOCAL_DATE)
        true
    } catch (e: DateTimeParseException) {
        false
    }
}

private fun isValidLocale(locale: String): Boolean {
    val localePattern = Pattern.compile("^[a-z]{2}(-[A-Z]{2})?$")
    return localePattern.matcher(locale).matches()
}

private fun isValidTimezone(timezone: String): Boolean {
    // Basic timezone validation - should be in format like "Europe/Moscow", "America/New_York", etc.
    val timezonePattern = Pattern.compile("^[A-Za-z]+/[A-Za-z_]+$")
    return timezonePattern.matcher(timezone).matches()
}

fun Application.configureValidation() {
    install(RequestValidation) {
        validate<ContactCreateRequest> { contact ->
            val errors = validateContactCreate(contact)
            if (errors.isEmpty()) {
                ValidationResult.Valid
            } else {
                ValidationResult.Invalid(errors.joinToString(", ") { "${it.field}: ${it.message}" })
            }
        }
        
        validate<ContactUpdateRequest> { contact ->
            val errors = validateContactUpdate(contact)
            if (errors.isEmpty()) {
                ValidationResult.Valid
            } else {
                ValidationResult.Invalid(errors.joinToString(", ") { "${it.field}: ${it.message}" })
            }
        }
    }
}
