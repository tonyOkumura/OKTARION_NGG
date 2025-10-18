// MongoDB инициализационный скрипт для task_micro
// Этот скрипт выполняется при первом запуске MongoDB контейнера

// Переключаемся на базу данных taskdb
db = db.getSiblingDB('taskdb');

// Создаем пользователя для приложения
db.createUser({
  user: 'taskuser',
  pwd: 'taskpass',
  roles: [
    {
      role: 'readWrite',
      db: 'taskdb'
    }
  ]
});

// Создаем коллекции и индексы
print('Creating collections and indexes...');

// Коллекции для задач
db.createCollection('tasks');
db.createCollection('task_comments');
db.createCollection('task_attachments');
db.createCollection('task_reads');

// Индексы для задач
db.tasks.createIndex({ "creatorId": 1 });
db.tasks.createIndex({ "status": 1 });
db.tasks.createIndex({ "priority": 1 });
db.tasks.createIndex({ "dueDate": 1 });
db.tasks.createIndex({ "createdAt": 1 });
db.tasks.createIndex({ "updatedAt": 1 });
db.tasks.createIndex({ "lastActivityAt": 1 });

// Индексы для встроенных полей assignees и watchers
db.tasks.createIndex({ "assignees.contactId": 1 });
db.tasks.createIndex({ "watchers.contactId": 1 });

// Индексы для других коллекций
db.task_comments.createIndex({ "taskId": 1 });
db.task_comments.createIndex({ "authorId": 1 });
db.task_comments.createIndex({ "createdAt": 1 });

db.task_attachments.createIndex({ "taskId": 1 });
db.task_attachments.createIndex({ "fileId": 1 });
db.task_attachments.createIndex({ "uploadedBy": 1 });

db.task_reads.createIndex({ "taskId": 1 });
db.task_reads.createIndex({ "contactId": 1 });
db.task_reads.createIndex({ "taskId": 1, "contactId": 1 }, { unique: true });

print('MongoDB initialization completed successfully!');
print('Database: taskdb');
print('User: taskuser');
print('Collections created: tasks, task_comments, task_attachments, task_reads');
print('Ready for task management functionality!');
