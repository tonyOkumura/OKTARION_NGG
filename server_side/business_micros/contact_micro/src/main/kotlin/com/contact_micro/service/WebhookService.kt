package com.contact_micro.service

import com.contact_micro.model.Contact
import com.contact_micro.model.ContactCreateRequest
import com.contact_micro.model.SupabaseUser
import com.contact_micro.model.WebhookResponse
import java.sql.Connection
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*

class WebhookService(private val dbConnection: Connection) {
    
    fun processUserRegistration(user: SupabaseUser): WebhookResponse {
        return try {
            // Проверяем, существует ли уже контакт с таким email
            val existingContact = findContactByEmail(user.email ?: return WebhookResponse(
                success = false, 
                message = "User email is null"
            ))
            
            if (existingContact != null) {
                return WebhookResponse(
                    success = false,
                    message = "Contact with email ${user.email} already exists"
                )
            }
            
            // Создаем новый контакт
            val contactId = createContactFromUser(user)
            
            WebhookResponse(
                success = true,
                message = "Contact created successfully",
                contactId = contactId
            )
        } catch (e: Exception) {
            WebhookResponse(
                success = false,
                message = "Failed to create contact: ${e.message}"
            )
        }
    }
    
    fun processEmailConfirmation(user: SupabaseUser): WebhookResponse {
        return try {
            val contact = findContactByEmail(user.email ?: return WebhookResponse(
                success = false,
                message = "User email is null"
            ))
            
            if (contact == null) {
                return WebhookResponse(
                    success = false,
                    message = "Contact with email ${user.email} not found"
                )
            }
            
            // Обновляем статус подтверждения email
            updateContactEmailConfirmation(contact.id ?: return WebhookResponse(
                success = false,
                message = "Contact ID is null"
            ), user.email_confirmed_at != null)
            
            WebhookResponse(
                success = true,
                message = "Email confirmation status updated",
                contactId = contact.id
            )
        } catch (e: Exception) {
            WebhookResponse(
                success = false,
                message = "Failed to update email confirmation: ${e.message}"
            )
        }
    }
    
    private fun findContactByEmail(email: String): Contact? {
        val query = "SELECT * FROM contacts WHERE email = ?"
        return dbConnection.prepareStatement(query).use { stmt ->
            stmt.setString(1, email)
            val rs = stmt.executeQuery()
            if (rs.next()) {
                Contact(
                    id = rs.getString("id"),
                    email = rs.getString("email"),
                    username = rs.getString("username"),
                    firstName = rs.getString("first_name"),
                    lastName = rs.getString("last_name"),
                    displayName = rs.getString("display_name"),
                    phone = rs.getString("phone"),
                    isOnline = rs.getBoolean("is_online"),
                    lastSeenAt = rs.getString("last_seen_at"),
                    statusMessage = rs.getString("status_message"),
                    role = rs.getString("role") ?: "user",
                    department = rs.getString("department"),
                    rank = rs.getString("rank"),
                    position = rs.getString("position"),
                    company = rs.getString("company"),
                    avatarUrl = rs.getString("avatar_url"),
                    dateOfBirth = rs.getString("date_of_birth"),
                    locale = rs.getString("locale") ?: "ru",
                    timezone = rs.getString("timezone") ?: "Europe/Moscow",
                    createdAt = rs.getString("created_at"),
                    updatedAt = rs.getString("updated_at")
                )
            } else null
        }
    }
    
    private fun createContactFromUser(user: SupabaseUser): String {
        // Используем ID пользователя из Supabase как ID контакта
        val contactId = user.id
        
        val query = """
            INSERT INTO contacts (
                id, username, first_name, last_name, display_name, email, phone, 
                is_online, last_seen_at, status_message, role, department, rank, 
                position, company, avatar_url, date_of_birth, locale, timezone, 
                created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """.trimIndent()
        
        dbConnection.prepareStatement(query).use { stmt ->
            stmt.setObject(1, java.util.UUID.fromString(contactId)) // id - UUID
            stmt.setString(2, user.email?.substringBefore("@")) // username
            stmt.setString(3, null) // first_name
            stmt.setString(4, null) // last_name
            stmt.setString(5, user.email?.substringBefore("@")) // display_name
            stmt.setString(6, user.email) // email
            stmt.setString(7, user.phone) // phone
            stmt.setBoolean(8, false) // is_online
            stmt.setTimestamp(9, null) // last_seen_at - null для новых пользователей
            stmt.setString(10, null) // status_message
            stmt.setString(11, "user") // role
            stmt.setString(12, null) // department
            stmt.setString(13, null) // rank
            stmt.setString(14, null) // position
            stmt.setString(15, null) // company
            stmt.setString(16, null) // avatar_url
            stmt.setDate(17, null) // date_of_birth
            stmt.setString(18, "ru") // locale
            stmt.setString(19, "Europe/Moscow") // timezone
            stmt.setTimestamp(20, java.sql.Timestamp.valueOf(LocalDateTime.now())) // created_at
            stmt.setTimestamp(21, java.sql.Timestamp.valueOf(LocalDateTime.now())) // updated_at
            
            stmt.executeUpdate()
        }
        
        return contactId
    }
    
    private fun updateContactEmailConfirmation(contactId: String, isConfirmed: Boolean) {
        val query = "UPDATE contacts SET updated_at = ? WHERE id = ?"
        dbConnection.prepareStatement(query).use { stmt ->
            stmt.setTimestamp(1, java.sql.Timestamp.valueOf(LocalDateTime.now()))
            stmt.setObject(2, java.util.UUID.fromString(contactId))
            stmt.executeUpdate()
        }
    }
}
