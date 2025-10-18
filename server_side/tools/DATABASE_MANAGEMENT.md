# Database Management Tools

## Overview
This document describes the database management tools available for the OKTARION NGG project.

## PostgreSQL Management (pgAdmin)

### Access
- **URL**: http://localhost:5050
- **Login**: admin@admin.com
- **Password**: admin

### Configured Databases
- **Contact Micro DB**: contact_postgres:5432 (contactdb)
- **Conversation Micro DB**: conversation_postgres:5432 (conversationdb)  
- **Message Micro DB**: message_postgres:5432 (messagedb)
- **Hoppscotch DB**: hoppscotch-db:5432 (hoppscotch)

### Credentials
- Contact: contactuser/contactpass
- Conversation: conversationuser/conversationpass
- Message: messageuser/messagepass
- Hoppscotch: hoppscotch/hoppscotch

## MongoDB Management (Mongo Express)

### Access
- **URL**: http://localhost:8781
- **Login**: admin
- **Password**: admin

### Configured Databases
- **Task Micro DB**: task_mongodb:27017 (taskdb)

### Credentials
- Task: taskuser/taskpass

### Future MongoDB Services
When Message and Event microservices are migrated to MongoDB:
1. Add their networks to the networks section in docker-compose.yml
2. Add depends_on for new MongoDB services
3. Mongo Express will auto-discover all MongoDB instances in connected networks

## Other Tools

### Redis Commander
- **URL**: http://localhost:8082
- **Purpose**: Redis cache management

### Portainer
- **URL**: http://localhost:9001
- **Purpose**: Docker container management

### Dozzle
- **URL**: http://localhost:9999
- **Purpose**: Container logs viewer

### Hoppscotch
- **URL**: http://localhost:3100
- **Purpose**: API testing tool
