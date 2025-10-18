CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100),
    is_group_chat BOOLEAN NOT NULL DEFAULT FALSE,
    owner_id UUID ,
    avatar_file_id UUID,
    category VARCHAR(50),
    last_message_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS conversation_participants (
    conversation_id UUID NOT NULL,
    contact_id UUID NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    invited_by UUID,
    invited_at TIMESTAMP,
    alias VARCHAR(100),
    unread_count INTEGER NOT NULL DEFAULT 0,
    last_read_at TIMESTAMP,
    last_message_read_id UUID,
    PRIMARY KEY (conversation_id, contact_id)
);

ALTER TABLE conversation_participants ADD FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE;