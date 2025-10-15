package com.contact_micro.service

import com.contact_micro.model.Contact
import com.contact_micro.model.ContactCreateRequest
import com.contact_micro.model.ContactUpdateRequest
import com.contact_micro.model.ContactSearchResponse
import com.contact_micro.config.PaginationConfig
import kotlinx.coroutines.*
import java.sql.Connection
import java.sql.PreparedStatement
import java.sql.ResultSet
import java.sql.Statement
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*

class ContactService(private val connection: Connection, private val paginationConfig: PaginationConfig) {
    companion object {
        private const val SELECT_CONTACT_BY_ID = """
            SELECT id, username, first_name, last_name, display_name, email, phone, 
                   is_online, last_seen_at, status_message, role, department, rank, 
                   position, company, avatar_file_id, date_of_birth, locale, timezone, 
                   created_at, updated_at 
            FROM contacts WHERE id = ?
        """
        
        private const val SELECT_ALL_CONTACTS = """
            SELECT id, username, first_name, last_name, display_name, email, phone, 
                   is_online, last_seen_at, status_message, role, department, rank, 
                   position, company, avatar_file_id, date_of_birth, locale, timezone, 
                   created_at, updated_at 
            FROM contacts 
            WHERE (? IS NULL OR (
                LOWER(username) LIKE LOWER(?) OR
                LOWER(first_name) LIKE LOWER(?) OR
                LOWER(last_name) LIKE LOWER(?) OR
                LOWER(display_name) LIKE LOWER(?) OR
                LOWER(email) LIKE LOWER(?) OR
                LOWER(phone) LIKE LOWER(?) OR
                LOWER(status_message) LIKE LOWER(?) OR
                LOWER(department) LIKE LOWER(?) OR
                LOWER(rank) LIKE LOWER(?) OR
                LOWER(position) LIKE LOWER(?) OR
                LOWER(company) LIKE LOWER(?)
            ))
            AND (? IS NULL OR created_at < ?::timestamp)
            ORDER BY created_at DESC
            LIMIT ?
        """
        
        private const val INSERT_CONTACT = """
            INSERT INTO contacts (id, username, first_name, last_name, display_name, email, phone, 
                                 status_message, role, department, rank, position, company, 
                                 avatar_file_id, date_of_birth, locale, timezone) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        private const val UPDATE_CONTACT = """
            UPDATE contacts SET username = ?, first_name = ?, last_name = ?, display_name = ?, 
                               email = ?, phone = ?, is_online = ?, status_message = ?, role = ?, 
                               department = ?, rank = ?, position = ?, company = ?, avatar_file_id = ?, 
                               date_of_birth = ?, locale = ?, timezone = ?, updated_at = NOW() 
            WHERE id = ?
        """
        
        private const val DELETE_CONTACT = "DELETE FROM contacts WHERE id = ?"
        
        private const val SELECT_CONTACT_BY_EMAIL = "SELECT id FROM contacts WHERE email = ?"
        private const val SELECT_CONTACT_BY_USERNAME = "SELECT id FROM contacts WHERE username = ?"
        private const val SELECT_CONTACT_BY_PHONE = "SELECT id FROM contacts WHERE phone = ?"
    }
    
    private val dateTimeFormatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME
    private val dateFormatter = DateTimeFormatter.ISO_LOCAL_DATE

    // Create new contact
    suspend fun create(contact: ContactCreateRequest, userId: String): String = withContext(Dispatchers.IO) {
        // Проверяем уникальность email, username, phone
        validateUniqueFields(contact.email, contact.username, contact.phone)
        
        val statement = connection.prepareStatement(INSERT_CONTACT)
        
        // Устанавливаем ID из заголовка Okta-User-ID
        statement.setObject(1, UUID.fromString(userId))
        statement.setString(2, contact.username)
        statement.setString(3, contact.firstName)
        statement.setString(4, contact.lastName)
        statement.setString(5, contact.displayName)
        statement.setString(6, contact.email)
        statement.setString(7, contact.phone)
        statement.setString(8, contact.statusMessage)
        statement.setString(9, contact.role)
        statement.setString(10, contact.department)
        statement.setString(11, contact.rank)
        statement.setString(12, contact.position)
        statement.setString(13, contact.company)
        if (contact.avatarFileId != null) {
            statement.setObject(14, UUID.fromString(contact.avatarFileId))
        } else {
            statement.setObject(14, null)
        }
        if (contact.dateOfBirth != null) {
            statement.setDate(15, java.sql.Date.valueOf(contact.dateOfBirth))
        } else {
            statement.setDate(15, null)
        }
        statement.setString(16, contact.locale)
        statement.setString(17, contact.timezone)

        statement.executeUpdate()
        
        return@withContext userId
    }

    // Read a contact by ID
    suspend fun readById(id: String): Contact = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(SELECT_CONTACT_BY_ID)
        statement.setObject(1, UUID.fromString(id))
        val resultSet = statement.executeQuery()

        if (resultSet.next()) {
            return@withContext mapResultSetToContact(resultSet)
        } else {
            throw Exception("Contact not found")
        }
    }
    
    // Read all contacts with search and pagination
    suspend fun readAll(searchQuery: String? = null, cursor: String? = null, limit: Int? = null): ContactSearchResponse = withContext(Dispatchers.IO) {
        val actualLimit = limit ?: paginationConfig.defaultLimit
        val statement = connection.prepareStatement(SELECT_ALL_CONTACTS)
        
        // Подготавливаем поисковый запрос
        val searchPattern = if (!searchQuery.isNullOrBlank()) "%$searchQuery%" else null
        
        // Устанавливаем параметры поиска (12 параметров: 1 для проверки + 11 для полей)
        statement.setString(1, searchPattern) // проверка на null
        for (i in 2..12) {
            statement.setString(i, searchPattern) // 11 полей для поиска
        }
        
        // Устанавливаем параметры курсора (2 параметра)
        statement.setString(13, cursor) // cursor check
        statement.setString(14, cursor) // cursor value
        
        // Устанавливаем лимит
        statement.setInt(15, actualLimit + 1) // +1 чтобы проверить hasMore
        
        val resultSet = statement.executeQuery()
        
        val contacts = mutableListOf<Contact>()
        var hasMore = false
        
        var count = 0
        while (resultSet.next()) {
            if (count < actualLimit) {
                contacts.add(mapResultSetToContact(resultSet))
                count++
            } else {
                hasMore = true
                break
            }
        }
        
        // Генерируем следующий курсор (время создания последнего контакта)
        val nextCursor = if (hasMore && contacts.isNotEmpty()) {
            contacts.last().createdAt
        } else null
        
        return@withContext ContactSearchResponse(
            contacts = contacts,
            hasMore = hasMore,
            nextCursor = nextCursor
        )
    }

    // Update a contact
    suspend fun update(id: String, contact: ContactUpdateRequest) = withContext(Dispatchers.IO) {
        // Проверяем уникальность email, username, phone (исключая текущий контакт)
        validateUniqueFieldsForUpdate(id, contact.email, contact.username, contact.phone)
        
        // Строим динамический SQL запрос только для переданных полей
        val updateFields = mutableListOf<String>()
        val parameters = mutableListOf<Any>()
        
        contact.username?.let {
            updateFields.add("username = ?")
            parameters.add(it)
        }
        contact.firstName?.let {
            updateFields.add("first_name = ?")
            parameters.add(it)
        }
        contact.lastName?.let {
            updateFields.add("last_name = ?")
            parameters.add(it)
        }
        contact.displayName?.let {
            updateFields.add("display_name = ?")
            parameters.add(it)
        }
        contact.email?.let {
            updateFields.add("email = ?")
            parameters.add(it)
        }
        contact.phone?.let {
            updateFields.add("phone = ?")
            parameters.add(it)
        }
        contact.isOnline?.let {
            updateFields.add("is_online = ?")
            parameters.add(it)
        }
        contact.statusMessage?.let {
            updateFields.add("status_message = ?")
            parameters.add(it)
        }
        contact.role?.let {
            updateFields.add("role = ?")
            parameters.add(it)
        }
        contact.department?.let {
            updateFields.add("department = ?")
            parameters.add(it)
        }
        contact.rank?.let {
            updateFields.add("rank = ?")
            parameters.add(it)
        }
        contact.position?.let {
            updateFields.add("position = ?")
            parameters.add(it)
        }
        contact.company?.let {
            updateFields.add("company = ?")
            parameters.add(it)
        }
        contact.avatarFileId?.let {
            updateFields.add("avatar_file_id = ?")
            parameters.add(UUID.fromString(it))
        }
        contact.dateOfBirth?.let {
            updateFields.add("date_of_birth = ?")
            parameters.add(java.sql.Date.valueOf(it))
        }
        contact.locale?.let {
            updateFields.add("locale = ?")
            parameters.add(it)
        }
        contact.timezone?.let {
            updateFields.add("timezone = ?")
            parameters.add(it)
        }
        
        if (updateFields.isEmpty()) {
            throw Exception("No fields to update")
        }
        
        // Добавляем updated_at и id
        updateFields.add("updated_at = NOW()")
        parameters.add(UUID.fromString(id))
        
        val sql = "UPDATE contacts SET ${updateFields.joinToString(", ")} WHERE id = ?"
        val statement = connection.prepareStatement(sql)
        
        // Устанавливаем параметры
        parameters.forEachIndexed { index, param ->
            when (param) {
                is String -> statement.setString(index + 1, param)
                is Boolean -> statement.setBoolean(index + 1, param)
                is UUID -> statement.setObject(index + 1, param)
                is java.sql.Date -> statement.setDate(index + 1, param)
                else -> statement.setObject(index + 1, param)
            }
        }
        
        val rowsAffected = statement.executeUpdate()
        if (rowsAffected == 0) {
            throw Exception("Contact not found")
        }
    }

    // Delete a contact
    suspend fun delete(id: String) = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(DELETE_CONTACT)
        statement.setObject(1, UUID.fromString(id))
        
        val rowsAffected = statement.executeUpdate()
        if (rowsAffected == 0) {
            throw Exception("Contact not found")
        }
    }
    
    // Helper method to map ResultSet to Contact
    private fun mapResultSetToContact(resultSet: ResultSet): Contact {
        return Contact(
            id = resultSet.getString("id"),
            username = resultSet.getString("username"),
            firstName = resultSet.getString("first_name"),
            lastName = resultSet.getString("last_name"),
            displayName = resultSet.getString("display_name"),
            email = resultSet.getString("email"),
            phone = resultSet.getString("phone"),
            isOnline = resultSet.getBoolean("is_online"),
            lastSeenAt = resultSet.getTimestamp("last_seen_at")?.toLocalDateTime()?.format(dateTimeFormatter),
            statusMessage = resultSet.getString("status_message"),
            role = resultSet.getString("role"),
            department = resultSet.getString("department"),
            rank = resultSet.getString("rank"),
            position = resultSet.getString("position"),
            company = resultSet.getString("company"),
            avatarFileId = resultSet.getString("avatar_file_id"),
            dateOfBirth = resultSet.getDate("date_of_birth")?.toLocalDate()?.format(dateFormatter),
            locale = resultSet.getString("locale"),
            timezone = resultSet.getString("timezone"),
            createdAt = resultSet.getTimestamp("created_at")?.toLocalDateTime()?.format(dateTimeFormatter),
            updatedAt = resultSet.getTimestamp("updated_at")?.toLocalDateTime()?.format(dateTimeFormatter)
        )
    }
    
    // Validate unique fields for create
    private fun validateUniqueFields(email: String?, username: String?, phone: String?) {
        if (email != null && isEmailExists(email)) {
            throw Exception("Email already exists: $email")
        }
        if (username != null && isUsernameExists(username)) {
            throw Exception("Username already exists: $username")
        }
        if (phone != null && isPhoneExists(phone)) {
            throw Exception("Phone already exists: $phone")
        }
    }
    
    // Validate unique fields for update (excluding current contact)
    private fun validateUniqueFieldsForUpdate(currentId: String, email: String?, username: String?, phone: String?) {
        if (email != null && isEmailExistsForOtherContact(email, currentId)) {
            throw Exception("Email already exists: $email")
        }
        if (username != null && isUsernameExistsForOtherContact(username, currentId)) {
            throw Exception("Username already exists: $username")
        }
        if (phone != null && isPhoneExistsForOtherContact(phone, currentId)) {
            throw Exception("Phone already exists: $phone")
        }
    }
    
    private fun isEmailExists(email: String): Boolean {
        val statement = connection.prepareStatement(SELECT_CONTACT_BY_EMAIL)
        statement.setString(1, email)
        val resultSet = statement.executeQuery()
        return resultSet.next()
    }
    
    private fun isUsernameExists(username: String): Boolean {
        val statement = connection.prepareStatement(SELECT_CONTACT_BY_USERNAME)
        statement.setString(1, username)
        val resultSet = statement.executeQuery()
        return resultSet.next()
    }
    
    private fun isPhoneExists(phone: String): Boolean {
        val statement = connection.prepareStatement(SELECT_CONTACT_BY_PHONE)
        statement.setString(1, phone)
        val resultSet = statement.executeQuery()
        return resultSet.next()
    }
    
    private fun isEmailExistsForOtherContact(email: String, currentId: String): Boolean {
        val statement = connection.prepareStatement("SELECT id FROM contacts WHERE email = ? AND id != ?")
        statement.setString(1, email)
        statement.setObject(2, UUID.fromString(currentId))
        val resultSet = statement.executeQuery()
        return resultSet.next()
    }
    
    private fun isUsernameExistsForOtherContact(username: String, currentId: String): Boolean {
        val statement = connection.prepareStatement("SELECT id FROM contacts WHERE username = ? AND id != ?")
        statement.setString(1, username)
        statement.setObject(2, UUID.fromString(currentId))
        val resultSet = statement.executeQuery()
        return resultSet.next()
    }
    
    private fun isPhoneExistsForOtherContact(phone: String, currentId: String): Boolean {
        val statement = connection.prepareStatement("SELECT id FROM contacts WHERE phone = ? AND id != ?")
        statement.setString(1, phone)
        statement.setObject(2, UUID.fromString(currentId))
        val resultSet = statement.executeQuery()
        return resultSet.next()
    }
}
