package com.conversation_micro.model

import kotlinx.coroutines.*
import kotlinx.serialization.Serializable
import java.sql.Connection
import java.sql.Statement
import java.util.*

@Serializable
data class ParticipantCreateRequest(
    val conversationId: String,
    val contactId: String,
    val role: String = "member",
    val alias: String? = null
)

@Serializable
data class ParticipantUpdateRequest(
    val role: String? = null,
    val alias: String? = null,
    val unreadCount: Int? = null,
    val lastReadAt: String? = null,
    val lastMessageReadId: String? = null
)

@Serializable
data class Participant(
    val conversationId: String,
    val contactId: String,
    val role: String,
    val joinedAt: String,
    val invitedBy: String?,
    val invitedAt: String?,
    val alias: String?,
    val unreadCount: Int,
    val lastReadAt: String?,
    val lastMessageReadId: String?
)

@Serializable
data class ParticipantListResponse(
    val participants: List<Participant>
)

class ParticipantService(private val connection: Connection) {
    companion object {
        private const val SELECT_PARTICIPANT_BY_CONVERSATION_AND_CONTACT = """
            SELECT conversation_id, contact_id, role, joined_at, invited_by, invited_at, 
                   alias, unread_count, last_read_at, last_message_read_id
            FROM conversation_participants 
            WHERE conversation_id = ?::uuid AND contact_id = ?::uuid
        """
        
        private const val SELECT_PARTICIPANTS_BY_CONVERSATION = """
            SELECT conversation_id, contact_id, role, joined_at, invited_by, invited_at, 
                   alias, unread_count, last_read_at, last_message_read_id
            FROM conversation_participants 
            WHERE conversation_id = ?::uuid
            ORDER BY joined_at ASC
        """
        
        private const val INSERT_PARTICIPANT = """
            INSERT INTO conversation_participants (conversation_id, contact_id, role, joined_at, alias)
            VALUES (?::uuid, ?::uuid, ?, NOW(), ?)
        """
        
        private const val UPDATE_PARTICIPANT = """
            UPDATE conversation_participants 
            SET role = COALESCE(?, role), 
                alias = COALESCE(?, alias),
                unread_count = COALESCE(?, unread_count),
                last_read_at = COALESCE(?, last_read_at),
                last_message_read_id = COALESCE(?, last_message_read_id)
            WHERE conversation_id = ?::uuid AND contact_id = ?::uuid
        """
        
        private const val DELETE_PARTICIPANT = """
            DELETE FROM conversation_participants 
            WHERE conversation_id = ?::uuid AND contact_id = ?::uuid
        """
        
        private const val CHECK_CONVERSATION_EXISTS = """
            SELECT 1 FROM conversations WHERE id = ?::uuid
        """
        
        private const val CHECK_PARTICIPANT_EXISTS = """
            SELECT 1 FROM conversation_participants WHERE conversation_id = ?::uuid AND contact_id = ?::uuid
        """
    }

    // Create new participant
    suspend fun create(request: ParticipantCreateRequest, invitedBy: String): Participant = withContext(Dispatchers.IO) {
        // Check if conversation exists
        val conversationCheck = connection.prepareStatement(CHECK_CONVERSATION_EXISTS)
        conversationCheck.setString(1, request.conversationId)
        val conversationResult = conversationCheck.executeQuery()
        if (!conversationResult.next()) {
            throw Exception("Conversation not found")
        }
        
        // Check if participant already exists
        val participantCheck = connection.prepareStatement(CHECK_PARTICIPANT_EXISTS)
        participantCheck.setString(1, request.conversationId)
        participantCheck.setString(2, request.contactId)
        val participantResult = participantCheck.executeQuery()
        if (participantResult.next()) {
            throw Exception("Participant already exists in this conversation")
        }
        
        // Insert participant
        val statement = connection.prepareStatement(INSERT_PARTICIPANT)
        statement.setString(1, request.conversationId)
        statement.setString(2, request.contactId)
        statement.setString(3, request.role)
        statement.setString(4, request.alias)
        statement.executeUpdate()
        
        // Return created participant
        readByConversationAndContact(request.conversationId, request.contactId)
    }

    // Read participant by conversation ID and contact ID
    suspend fun readByConversationAndContact(conversationId: String, contactId: String): Participant = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(SELECT_PARTICIPANT_BY_CONVERSATION_AND_CONTACT)
        statement.setString(1, conversationId)
        statement.setString(2, contactId)
        val resultSet = statement.executeQuery()

        if (!resultSet.next()) {
            throw Exception("Participant not found")
        }

        Participant(
            conversationId = resultSet.getString("conversation_id"),
            contactId = resultSet.getString("contact_id"),
            role = resultSet.getString("role"),
            joinedAt = resultSet.getTimestamp("joined_at").toString(),
            invitedBy = resultSet.getString("invited_by"),
            invitedAt = resultSet.getTimestamp("invited_at")?.toString(),
            alias = resultSet.getString("alias"),
            unreadCount = resultSet.getInt("unread_count"),
            lastReadAt = resultSet.getTimestamp("last_read_at")?.toString(),
            lastMessageReadId = resultSet.getString("last_message_read_id")
        )
    }

    // Read all participants by conversation ID
    suspend fun readAllByConversation(conversationId: String): ParticipantListResponse = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(SELECT_PARTICIPANTS_BY_CONVERSATION)
        statement.setString(1, conversationId)
        val resultSet = statement.executeQuery()

        val participants = mutableListOf<Participant>()
        while (resultSet.next()) {
            participants.add(Participant(
                conversationId = resultSet.getString("conversation_id"),
                contactId = resultSet.getString("contact_id"),
                role = resultSet.getString("role"),
                joinedAt = resultSet.getTimestamp("joined_at").toString(),
                invitedBy = resultSet.getString("invited_by"),
                invitedAt = resultSet.getTimestamp("invited_at")?.toString(),
                alias = resultSet.getString("alias"),
                unreadCount = resultSet.getInt("unread_count"),
                lastReadAt = resultSet.getTimestamp("last_read_at")?.toString(),
                lastMessageReadId = resultSet.getString("last_message_read_id")
            ))
        }

        ParticipantListResponse(participants = participants)
    }

    // Update participant
    suspend fun update(conversationId: String, contactId: String, request: ParticipantUpdateRequest): Participant = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(UPDATE_PARTICIPANT)
        statement.setString(1, request.role)
        statement.setString(2, request.alias)
        statement.setObject(3, request.unreadCount)
        
        // Handle timestamp conversion for lastReadAt
        if (request.lastReadAt != null) {
            try {
                statement.setTimestamp(4, java.sql.Timestamp.valueOf(request.lastReadAt))
            } catch (e: Exception) {
                throw Exception("Invalid timestamp format for lastReadAt: ${request.lastReadAt}")
            }
        } else {
            statement.setNull(4, java.sql.Types.TIMESTAMP)
        }
        
        statement.setString(5, request.lastMessageReadId)
        statement.setString(6, conversationId)
        statement.setString(7, contactId)
        
        val rowsAffected = statement.executeUpdate()
        if (rowsAffected == 0) {
            throw Exception("Participant not found")
        }
        
        readByConversationAndContact(conversationId, contactId)
    }

    // Delete participant
    suspend fun delete(conversationId: String, contactId: String) = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(DELETE_PARTICIPANT)
        statement.setString(1, conversationId)
        statement.setString(2, contactId)
        
        val rowsAffected = statement.executeUpdate()
        if (rowsAffected == 0) {
            throw Exception("Participant not found")
        }
    }
}
