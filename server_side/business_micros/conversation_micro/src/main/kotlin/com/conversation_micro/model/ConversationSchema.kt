package com.conversation_micro.model

import com.conversation_micro.config.PaginationConfig
import kotlinx.coroutines.*
import kotlinx.serialization.Serializable
import java.sql.Connection
import java.sql.Statement
import java.util.*

@Serializable
data class ConversationCreateRequest(
    val name: String? = null,
    val avatarFileId: String? = null,
    val category: String? = null,
    val participants: List<String> = emptyList() // List of contact IDs (excluding creator)
)

@Serializable
data class ConversationUpdateRequest(
    val name: String? = null,
    val avatarFileId: String? = null,
    val category: String? = null
)

@Serializable
data class Conversation(
    val id: String,
    val name: String?,
    val isGroupChat: Boolean,
    val ownerId: String,
    val avatarFileId: String?,
    val category: String?,
    val lastMessageId: String?,
    val createdAt: String,
    val updatedAt: String,
    val participants: List<ConversationParticipant> = emptyList()
)

@Serializable
data class ConversationParticipant(
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
data class ConversationListResponse(
    val conversations: List<Conversation>,
    val hasMore: Boolean,
    val nextCursor: String?
)

@Serializable
data class AddParticipantsRequest(
    val contactIds: List<String> // List of contact IDs to add
)

@Serializable
data class RemoveParticipantsRequest(
    val contactIds: List<String> // List of contact IDs to remove
)

@Serializable
data class AddParticipantsResponse(
    val message: String,
    val addedCount: Int,
    val participants: List<Participant>
)

@Serializable
data class RemoveParticipantsResponse(
    val message: String,
    val removedCount: Int
)

class ConversationService(private val connection: Connection, private val paginationConfig: PaginationConfig) {
    companion object {
        private const val SELECT_CONVERSATION_BY_ID = """
            SELECT c.id, c.name, c.is_group_chat, c.owner_id, c.avatar_file_id, c.category, 
                   c.last_message_id, c.created_at, c.updated_at
            FROM conversations c
            WHERE c.id = ?::uuid
        """
        
        private const val SELECT_CONVERSATIONS_WITH_PARTICIPANTS = """
            SELECT c.id, c.name, c.is_group_chat, c.owner_id, c.avatar_file_id, c.category, 
                   c.last_message_id, c.created_at, c.updated_at,
                   cp.contact_id, cp.role, cp.joined_at, cp.invited_by, cp.invited_at, 
                   cp.alias, cp.unread_count, cp.last_read_at, cp.last_message_read_id
            FROM conversations c
            LEFT JOIN conversation_participants cp ON c.id = cp.conversation_id
            WHERE c.id = ?::uuid
        """
        
        private const val INSERT_CONVERSATION = """
            INSERT INTO conversations (name, is_group_chat, owner_id, avatar_file_id, category)
            VALUES (?, ?, ?::uuid, ?::uuid, ?)
        """
        
        private const val INSERT_PARTICIPANT = """
            INSERT INTO conversation_participants (conversation_id, contact_id, role, joined_at)
            VALUES (?::uuid, ?::uuid, ?, NOW())
        """
        
        private const val UPDATE_CONVERSATION = """
            UPDATE conversations 
            SET name = ?, avatar_file_id = ?::uuid, category = ?, updated_at = NOW()
            WHERE id = ?::uuid
        """
        
        private const val DELETE_CONVERSATION = "DELETE FROM conversations WHERE id = ?::uuid"
        
        private const val DELETE_PARTICIPANTS = "DELETE FROM conversation_participants WHERE conversation_id = ?::uuid"
        
        private const val SELECT_CONVERSATIONS_PAGINATED = """
            SELECT c.id, c.name, c.is_group_chat, c.owner_id, c.avatar_file_id, c.category, 
                   c.last_message_id, c.created_at, c.updated_at
            FROM conversations c
            INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
            WHERE cp.contact_id = ?::uuid
            ORDER BY c.updated_at DESC
            LIMIT ?
        """
        
        private const val SELECT_CONVERSATIONS_PAGINATED_WITH_SEARCH = """
            SELECT c.id, c.name, c.is_group_chat, c.owner_id, c.avatar_file_id, c.category, 
                   c.last_message_id, c.created_at, c.updated_at
            FROM conversations c
            INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
            WHERE cp.contact_id = ?::uuid AND c.name ILIKE ?
            ORDER BY c.updated_at DESC
            LIMIT ?
        """
        
        private const val SELECT_CONVERSATIONS_PAGINATED_WITH_CURSOR = """
            SELECT c.id, c.name, c.is_group_chat, c.owner_id, c.avatar_file_id, c.category, 
                   c.last_message_id, c.created_at, c.updated_at
            FROM conversations c
            INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
            WHERE cp.contact_id = ?::uuid AND c.updated_at < ?
            ORDER BY c.updated_at DESC
            LIMIT ?
        """
        
        private const val SELECT_CONVERSATIONS_PAGINATED_WITH_CURSOR_AND_SEARCH = """
            SELECT c.id, c.name, c.is_group_chat, c.owner_id, c.avatar_file_id, c.category, 
                   c.last_message_id, c.created_at, c.updated_at
            FROM conversations c
            INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
            WHERE cp.contact_id = ?::uuid AND c.updated_at < ? AND c.name ILIKE ?
            ORDER BY c.updated_at DESC
            LIMIT ?
        """
        
        private const val DELETE_PARTICIPANT = """
            DELETE FROM conversation_participants 
            WHERE conversation_id = ?::uuid AND contact_id = ?::uuid
        """
        
        private const val CHECK_EXISTING_PRIVATE_CHAT = """
            SELECT c.id 
            FROM conversations c
            INNER JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
            INNER JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
            WHERE c.is_group_chat = false 
            AND cp1.contact_id = ?::uuid 
            AND cp2.contact_id = ?::uuid
            AND cp1.contact_id != cp2.contact_id
        """
    }

    // Create new conversation
    suspend fun create(request: ConversationCreateRequest, ownerId: String): String = withContext(Dispatchers.IO) {
        connection.autoCommit = false
        try {
            // Determine if this is a group chat based on number of participants
            // If only 1 participant (excluding creator), it's a private chat
            // If more than 1 participant, it's a group chat
            val isGroupChat = request.participants.size > 1
            
            // For private chats (2 participants), check if conversation already exists
            if (!isGroupChat && request.participants.isNotEmpty()) {
                val otherParticipant = request.participants.first()
                val checkStatement = connection.prepareStatement(CHECK_EXISTING_PRIVATE_CHAT)
                checkStatement.setString(1, ownerId)
                checkStatement.setString(2, otherParticipant)
                val resultSet = checkStatement.executeQuery()
                
                if (resultSet.next()) {
                    val existingConversationId = resultSet.getString("id")
                    connection.commit()
                    return@withContext existingConversationId // Return existing conversation ID
                }
            }
            
            // Insert conversation
            val conversationStatement = connection.prepareStatement(INSERT_CONVERSATION, Statement.RETURN_GENERATED_KEYS)
            conversationStatement.setString(1, request.name)
            conversationStatement.setBoolean(2, isGroupChat)
            conversationStatement.setString(3, ownerId)
            conversationStatement.setString(4, request.avatarFileId)
            conversationStatement.setString(5, request.category)
            conversationStatement.executeUpdate()

            val generatedKeys = conversationStatement.generatedKeys
            if (!generatedKeys.next()) {
                throw Exception("Unable to retrieve the id of the newly inserted conversation")
            }
            
            val conversationId = generatedKeys.getString(1)
            
            // Add owner as participant with "owner" role
            val participantStatement = connection.prepareStatement(INSERT_PARTICIPANT)
            participantStatement.setString(1, conversationId)
            participantStatement.setString(2, ownerId)
            participantStatement.setString(3, "owner")
            participantStatement.executeUpdate()
            
            // Add other participants with "member" role
            for (contactId in request.participants) {
                if (contactId != ownerId) {
                    participantStatement.setString(1, conversationId)
                    participantStatement.setString(2, contactId)
                    participantStatement.setString(3, "member")
                    participantStatement.executeUpdate()
                }
            }
            
            connection.commit()
            conversationId
        } catch (e: Exception) {
            connection.rollback()
            throw e
        } finally {
            connection.autoCommit = true
        }
    }

    // Read conversation by ID
    suspend fun readById(id: String): Conversation = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(SELECT_CONVERSATIONS_WITH_PARTICIPANTS)
        statement.setString(1, id)
        val resultSet = statement.executeQuery()

        if (!resultSet.next()) {
            throw Exception("Conversation not found")
        }

        val conversation = Conversation(
            id = resultSet.getString("id"),
            name = resultSet.getString("name"),
            isGroupChat = resultSet.getBoolean("is_group_chat"),
            ownerId = resultSet.getString("owner_id"),
            avatarFileId = resultSet.getString("avatar_file_id"),
            category = resultSet.getString("category"),
            lastMessageId = resultSet.getString("last_message_id"),
            createdAt = resultSet.getTimestamp("created_at").toString(),
            updatedAt = resultSet.getTimestamp("updated_at").toString(),
            participants = mutableListOf()
        )

        // Add first participant
        val participants = mutableListOf<ConversationParticipant>()
        participants.add(ConversationParticipant(
            conversationId = resultSet.getString("id"),
            contactId = resultSet.getString("contact_id") ?: "",
            role = resultSet.getString("role") ?: "",
            joinedAt = resultSet.getTimestamp("joined_at")?.toString() ?: "",
            invitedBy = resultSet.getString("invited_by"),
            invitedAt = resultSet.getTimestamp("invited_at")?.toString(),
            alias = resultSet.getString("alias"),
            unreadCount = resultSet.getInt("unread_count"),
            lastReadAt = resultSet.getTimestamp("last_read_at")?.toString(),
            lastMessageReadId = resultSet.getString("last_message_read_id")
        ))

        // Add remaining participants
        while (resultSet.next()) {
            participants.add(ConversationParticipant(
                conversationId = resultSet.getString("id"),
                contactId = resultSet.getString("contact_id") ?: "",
                role = resultSet.getString("role") ?: "",
                joinedAt = resultSet.getTimestamp("joined_at")?.toString() ?: "",
                invitedBy = resultSet.getString("invited_by"),
                invitedAt = resultSet.getTimestamp("invited_at")?.toString(),
                alias = resultSet.getString("alias"),
                unreadCount = resultSet.getInt("unread_count"),
                lastReadAt = resultSet.getTimestamp("last_read_at")?.toString(),
                lastMessageReadId = resultSet.getString("last_message_read_id")
            ))
        }

        conversation.copy(participants = participants)
    }

    // Read all conversations with pagination and search
    suspend fun readAll(userId: String, searchQuery: String?, cursor: String?, limit: Int?): ConversationListResponse = withContext(Dispatchers.IO) {
        val actualLimit = limit ?: paginationConfig.defaultLimit
        val actualLimitBounded = minOf(actualLimit, paginationConfig.maxLimit)
        
        val statement = when {
            searchQuery != null && cursor != null -> {
                connection.prepareStatement(SELECT_CONVERSATIONS_PAGINATED_WITH_CURSOR_AND_SEARCH)
            }
            searchQuery != null -> {
                connection.prepareStatement(SELECT_CONVERSATIONS_PAGINATED_WITH_SEARCH)
            }
            cursor != null -> {
                connection.prepareStatement(SELECT_CONVERSATIONS_PAGINATED_WITH_CURSOR)
            }
            else -> {
                connection.prepareStatement(SELECT_CONVERSATIONS_PAGINATED)
            }
        }
        
        statement.setString(1, userId)
        
        when {
            searchQuery != null && cursor != null -> {
                statement.setTimestamp(2, java.sql.Timestamp.valueOf(cursor))
                statement.setString(3, "%$searchQuery%")
                statement.setInt(4, actualLimitBounded + 1)
            }
            searchQuery != null -> {
                statement.setString(2, "%$searchQuery%")
                statement.setInt(3, actualLimitBounded + 1)
            }
            cursor != null -> {
                statement.setTimestamp(2, java.sql.Timestamp.valueOf(cursor))
                statement.setInt(3, actualLimitBounded + 1)
            }
            else -> {
                statement.setInt(2, actualLimitBounded + 1)
            }
        }
        
        val resultSet = statement.executeQuery()
        val conversations = mutableListOf<Conversation>()
        
        while (resultSet.next()) {
            conversations.add(Conversation(
                id = resultSet.getString("id"),
                name = resultSet.getString("name"),
                isGroupChat = resultSet.getBoolean("is_group_chat"),
                ownerId = resultSet.getString("owner_id"),
                avatarFileId = resultSet.getString("avatar_file_id"),
                category = resultSet.getString("category"),
                lastMessageId = resultSet.getString("last_message_id"),
                createdAt = resultSet.getTimestamp("created_at").toString(),
                updatedAt = resultSet.getTimestamp("updated_at").toString()
            ))
        }
        
        val hasMore = conversations.size > actualLimitBounded
        if (hasMore) {
            conversations.removeAt(conversations.size - 1)
        }
        
        val nextCursor = if (hasMore && conversations.isNotEmpty()) {
            conversations.last().updatedAt
        } else null
        
        ConversationListResponse(
            conversations = conversations,
            hasMore = hasMore,
            nextCursor = nextCursor
        )
    }

    // Read conversations by specific IDs
    suspend fun readByIds(userId: String, ids: List<String>): List<Conversation> = withContext(Dispatchers.IO) {
        if (ids.isEmpty()) {
            return@withContext emptyList()
        }
        
        // Создаем плейсхолдеры для SQL запроса с приведением типов
        val placeholders = ids.joinToString(",") { "?::uuid" }
        val query = """
            SELECT DISTINCT c.id, c.name, c.is_group_chat, c.owner_id, c.avatar_file_id, c.category, 
                   c.last_message_id, c.created_at, c.updated_at
            FROM conversations c
            INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
            WHERE c.id IN ($placeholders) AND cp.contact_id = ?::uuid
            ORDER BY c.updated_at DESC
        """
        
        val statement = connection.prepareStatement(query)
        
        // Устанавливаем параметры для каждого ID
        ids.forEachIndexed { index, id ->
            statement.setString(index + 1, id)
        }
        // Добавляем userId как последний параметр
        statement.setString(ids.size + 1, userId)
        
        val resultSet = statement.executeQuery()
        val conversations = mutableListOf<Conversation>()
        
        while (resultSet.next()) {
            conversations.add(Conversation(
                id = resultSet.getString("id"),
                name = resultSet.getString("name"),
                isGroupChat = resultSet.getBoolean("is_group_chat"),
                ownerId = resultSet.getString("owner_id"),
                avatarFileId = resultSet.getString("avatar_file_id"),
                category = resultSet.getString("category"),
                lastMessageId = resultSet.getString("last_message_id"),
                createdAt = resultSet.getTimestamp("created_at").toString(),
                updatedAt = resultSet.getTimestamp("updated_at").toString()
            ))
        }
        
        return@withContext conversations
    }

    // Add multiple participants to conversation
    suspend fun addParticipants(conversationId: String, contactIds: List<String>, addedBy: String): List<Participant> = withContext(Dispatchers.IO) {
        connection.autoCommit = false
        try {
            // Check if conversation exists and is a group chat
            val conversationCheck = connection.prepareStatement("SELECT is_group_chat FROM conversations WHERE id = ?::uuid")
            conversationCheck.setString(1, conversationId)
            val conversationResult = conversationCheck.executeQuery()
            if (!conversationResult.next()) {
                throw Exception("Conversation not found")
            }
            if (!conversationResult.getBoolean("is_group_chat")) {
                throw Exception("Can only add participants to group chats")
            }
            
            // Check if the user adding participants is a participant of the conversation
            val participantCheck = connection.prepareStatement("SELECT 1 FROM conversation_participants WHERE conversation_id = ?::uuid AND contact_id = ?::uuid")
            participantCheck.setString(1, conversationId)
            participantCheck.setString(2, addedBy)
            val participantResult = participantCheck.executeQuery()
            if (!participantResult.next()) {
                throw Exception("Only conversation participants can add new members")
            }
            
            val addedParticipants = mutableListOf<Participant>()
            val statement = connection.prepareStatement(INSERT_PARTICIPANT)
            
            for (contactId in contactIds) {
                if (contactId != addedBy) { // Don't add the person who is adding
                    // Check if participant already exists
                    val existsCheck = connection.prepareStatement("SELECT 1 FROM conversation_participants WHERE conversation_id = ?::uuid AND contact_id = ?::uuid")
                    existsCheck.setString(1, conversationId)
                    existsCheck.setString(2, contactId)
                    val existsResult = existsCheck.executeQuery()
                    
                    if (!existsResult.next()) {
                        statement.setString(1, conversationId)
                        statement.setString(2, contactId)
                        statement.setString(3, "member")
                        statement.executeUpdate()
                        
                        // Get the added participant
                        val participant = readParticipantByConversationAndContact(conversationId, contactId)
                        addedParticipants.add(participant)
                    }
                }
            }
            
            connection.commit()
            addedParticipants
        } catch (e: Exception) {
            connection.rollback()
            throw e
        } finally {
            connection.autoCommit = true
        }
    }

    // Remove multiple participants from conversation
    suspend fun removeParticipants(conversationId: String, contactIds: List<String>, removedBy: String): Int = withContext(Dispatchers.IO) {
        connection.autoCommit = false
        try {
            // Check if conversation exists
            val conversationCheck = connection.prepareStatement("SELECT 1 FROM conversations WHERE id = ?::uuid")
            conversationCheck.setString(1, conversationId)
            val conversationResult = conversationCheck.executeQuery()
            if (!conversationResult.next()) {
                throw Exception("Conversation not found")
            }
            
            // Check if the user removing participants is a participant of the conversation
            val participantCheck = connection.prepareStatement("SELECT 1 FROM conversation_participants WHERE conversation_id = ?::uuid AND contact_id = ?::uuid")
            participantCheck.setString(1, conversationId)
            participantCheck.setString(2, removedBy)
            val participantResult = participantCheck.executeQuery()
            if (!participantResult.next()) {
                throw Exception("Only conversation participants can remove members")
            }
            
            var removedCount = 0
            val statement = connection.prepareStatement(DELETE_PARTICIPANT)
            
            for (contactId in contactIds) {
                if (contactId != removedBy) { // Don't remove the person who is removing
                    statement.setString(1, conversationId)
                    statement.setString(2, contactId)
                    val rowsAffected = statement.executeUpdate()
                    removedCount += rowsAffected
                }
            }
            
            connection.commit()
            removedCount
        } catch (e: Exception) {
            connection.rollback()
            throw e
        } finally {
            connection.autoCommit = true
        }
    }

    // Helper method to read participant
    private suspend fun readParticipantByConversationAndContact(conversationId: String, contactId: String): Participant = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement("""
            SELECT conversation_id, contact_id, role, joined_at, invited_by, invited_at, 
                   alias, unread_count, last_read_at, last_message_read_id
            FROM conversation_participants 
            WHERE conversation_id = ?::uuid AND contact_id = ?::uuid
        """)
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

    // Update conversation
    suspend fun update(id: String, request: ConversationUpdateRequest) = withContext(Dispatchers.IO) {
        val statement = connection.prepareStatement(UPDATE_CONVERSATION)
        statement.setString(1, request.name)
        statement.setString(2, request.avatarFileId)
        statement.setString(3, request.category)
        statement.setString(4, id)
        
        val rowsAffected = statement.executeUpdate()
        if (rowsAffected == 0) {
            throw Exception("Conversation not found")
        }
    }

    // Delete conversation
    suspend fun delete(id: String) = withContext(Dispatchers.IO) {
        connection.autoCommit = false
        try {
            // Delete participants first (due to foreign key constraint)
            val deleteParticipantsStatement = connection.prepareStatement(DELETE_PARTICIPANTS)
            deleteParticipantsStatement.setString(1, id)
            deleteParticipantsStatement.executeUpdate()
            
            // Delete conversation
            val deleteConversationStatement = connection.prepareStatement(DELETE_CONVERSATION)
            deleteConversationStatement.setString(1, id)
            
            val rowsAffected = deleteConversationStatement.executeUpdate()
            if (rowsAffected == 0) {
                throw Exception("Conversation not found")
            }
            
            connection.commit()
        } catch (e: Exception) {
            connection.rollback()
            throw e
        } finally {
            connection.autoCommit = true
        }
    }
}
