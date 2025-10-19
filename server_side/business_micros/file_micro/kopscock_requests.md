# File Microservice - KopsCock/Postman Collection

## Environment Variables
- `base_url`: http://localhost:8060
- `user_id`: 550e8400-e29b-41d4-a716-446655440000
- `other_user_id`: 123e4567-e89b-12d3-a456-426614174000

---

## 📁 FILES API

### 1. Upload File
```bash
curl --location '{{base_url}}/files' \
--header 'Okta-User-ID: {{user_id}}' \
--form 'file=@"/path/to/your/file.jpg"' \
--form 'fileName="my-document.jpg"' \
--form 'contentType="image/jpeg"' \
--form 'metadata="category:documents,project:test"'
```

### 2. Get File List
```bash
curl --location '{{base_url}}/files' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 3. Get File List with Pagination
```bash
curl --location '{{base_url}}/files?limit=10&marker=some-marker' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 4. Get File Info
```bash
curl --location '{{base_url}}/files/{file_id}' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 5. Download File
```bash
curl --location '{{base_url}}/files/{file_id}/download' \
--header 'Okta-User-ID: {{user_id}}' \
--output 'downloaded_file.jpg'
```

### 6. Get Download URL (Presigned)
```bash
curl --location '{{base_url}}/files/{file_id}/download-url' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 7. Update File Metadata
```bash
curl --location --request PUT '{{base_url}}/files/{file_id}' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json' \
--data '{
    "fileName": "updated-name.jpg",
    "metadata": {
        "category": "updated",
        "description": "Updated file"
    }
}'
```

### 8. Delete File
```bash
curl --location --request DELETE '{{base_url}}/files/{file_id}' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

---

## 👤 AVATARS API

### 1. Upload Avatar
```bash
curl --location '{{base_url}}/avatars' \
--header 'Okta-User-ID: {{user_id}}' \
--form 'file=@"/path/to/avatar.jpg"' \
--form 'contentType="image/jpeg"'
```

### 2. Get Avatar Info
```bash
curl --location '{{base_url}}/avatars/{{user_id}}' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 3. Get Other User Avatar Info
```bash
curl --location '{{base_url}}/avatars/{{other_user_id}}' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 4. Download Avatar
```bash
curl --location '{{base_url}}/avatars/{{user_id}}/download' \
--header 'Okta-User-ID: {{user_id}}' \
--output 'avatar.jpg'
```

### 5. Download Other User Avatar
```bash
curl --location '{{base_url}}/avatars/{{other_user_id}}/download' \
--header 'Okta-User-ID: {{user_id}}' \
--output 'other_avatar.jpg'
```

### 6. Get Avatar Download URL (Presigned)
```bash
curl --location '{{base_url}}/avatars/{{user_id}}/download-url' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 7. Check Avatar Exists
```bash
curl --location '{{base_url}}/avatars/{{user_id}}/exists' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 8. Delete Avatar
```bash
curl --location --request DELETE '{{base_url}}/avatars' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

---

## 🏥 HEALTH CHECKS

### 1. Health Check
```bash
curl --location '{{base_url}}/health' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 2. Readiness Check
```bash
curl --location '{{base_url}}/health/ready' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

### 3. Liveness Check
```bash
curl --location '{{base_url}}/health/live' \
--header 'Okta-User-ID: {{user_id}}' \
--header 'Content-Type: application/json'
```

---

## 📝 POSTMAN COLLECTION JSON

```json
{
  "info": {
    "name": "File Microservice API",
    "description": "API для управления файлами и аватарками пользователей",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8060",
      "type": "string"
    },
    {
      "key": "user_id",
      "value": "550e8400-e29b-41d4-a716-446655440000",
      "type": "string"
    },
    {
      "key": "other_user_id",
      "value": "123e4567-e89b-12d3-a456-426614174000",
      "type": "string"
    }
  ],
  "item": [
    {
      "name": "Files",
      "item": [
        {
          "name": "Upload File",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "body": {
              "mode": "formdata",
              "formdata": [
                {
                  "key": "file",
                  "type": "file",
                  "src": []
                },
                {
                  "key": "fileName",
                  "value": "my-document.jpg",
                  "type": "text"
                },
                {
                  "key": "contentType",
                  "value": "image/jpeg",
                  "type": "text"
                },
                {
                  "key": "metadata",
                  "value": "category:documents,project:test",
                  "type": "text"
                }
              ]
            },
            "url": {
              "raw": "{{base_url}}/files",
              "host": ["{{base_url}}"],
              "path": ["files"]
            }
          }
        },
        {
          "name": "Get File List",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/files",
              "host": ["{{base_url}}"],
              "path": ["files"]
            }
          }
        },
        {
          "name": "Get File Info",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/files/{file_id}",
              "host": ["{{base_url}}"],
              "path": ["files", "{file_id}"]
            }
          }
        },
        {
          "name": "Download File",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/files/{file_id}/download",
              "host": ["{{base_url}}"],
              "path": ["files", "{file_id}", "download"]
            }
          }
        },
        {
          "name": "Get Download URL",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/files/{file_id}/download-url",
              "host": ["{{base_url}}"],
              "path": ["files", "{file_id}", "download-url"]
            }
          }
        },
        {
          "name": "Update File Metadata",
          "request": {
            "method": "PUT",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              },
              {
                "key": "Content-Type",
                "value": "application/json",
                "type": "text"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"fileName\": \"updated-name.jpg\",\n    \"metadata\": {\n        \"category\": \"updated\",\n        \"description\": \"Updated file\"\n    }\n}"
            },
            "url": {
              "raw": "{{base_url}}/files/{file_id}",
              "host": ["{{base_url}}"],
              "path": ["files", "{file_id}"]
            }
          }
        },
        {
          "name": "Delete File",
          "request": {
            "method": "DELETE",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/files/{file_id}",
              "host": ["{{base_url}}"],
              "path": ["files", "{file_id}"]
            }
          }
        }
      ]
    },
    {
      "name": "Avatars",
      "item": [
        {
          "name": "Upload Avatar",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "body": {
              "mode": "formdata",
              "formdata": [
                {
                  "key": "file",
                  "type": "file",
                  "src": []
                },
                {
                  "key": "contentType",
                  "value": "image/jpeg",
                  "type": "text"
                }
              ]
            },
            "url": {
              "raw": "{{base_url}}/avatars",
              "host": ["{{base_url}}"],
              "path": ["avatars"]
            }
          }
        },
        {
          "name": "Get My Avatar Info",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/avatars/{{user_id}}",
              "host": ["{{base_url}}"],
              "path": ["avatars", "{{user_id}}"]
            }
          }
        },
        {
          "name": "Get Other User Avatar Info",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/avatars/{{other_user_id}}",
              "host": ["{{base_url}}"],
              "path": ["avatars", "{{other_user_id}}"]
            }
          }
        },
        {
          "name": "Download My Avatar",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/avatars/{{user_id}}/download",
              "host": ["{{base_url}}"],
              "path": ["avatars", "{{user_id}}", "download"]
            }
          }
        },
        {
          "name": "Download Other User Avatar",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/avatars/{{other_user_id}}/download",
              "host": ["{{base_url}}"],
              "path": ["avatars", "{{other_user_id}}", "download"]
            }
          }
        },
        {
          "name": "Get Avatar Download URL",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/avatars/{{user_id}}/download-url",
              "host": ["{{base_url}}"],
              "path": ["avatars", "{{user_id}}", "download-url"]
            }
          }
        },
        {
          "name": "Check Avatar Exists",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/avatars/{{user_id}}/exists",
              "host": ["{{base_url}}"],
              "path": ["avatars", "{{user_id}}", "exists"]
            }
          }
        },
        {
          "name": "Delete Avatar",
          "request": {
            "method": "DELETE",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/avatars",
              "host": ["{{base_url}}"],
              "path": ["avatars"]
            }
          }
        }
      ]
    },
    {
      "name": "Health Checks",
      "item": [
        {
          "name": "Health Check",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/health",
              "host": ["{{base_url}}"],
              "path": ["health"]
            }
          }
        },
        {
          "name": "Readiness Check",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/health/ready",
              "host": ["{{base_url}}"],
              "path": ["health", "ready"]
            }
          }
        },
        {
          "name": "Liveness Check",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Okta-User-ID",
                "value": "{{user_id}}",
                "type": "text"
              }
            ],
            "url": {
              "raw": "{{base_url}}/health/live",
              "host": ["{{base_url}}"],
              "path": ["health", "live"]
            }
          }
        }
      ]
    }
  ]
}
```

---

## 🚀 Quick Test Commands

### Test File Upload
```bash
curl -X POST -H "Okta-User-ID: 550e8400-e29b-41d4-a716-446655440000" \
  -F "file=@test_minio/developer.jpg" \
  -F "fileName=test-file.jpg" \
  -F "contentType=image/jpeg" \
  http://localhost:8060/files
```

### Test Avatar Upload
```bash
curl -X POST -H "Okta-User-ID: 550e8400-e29b-41d4-a716-446655440000" \
  -F "file=@test_minio/developer.jpg" \
  -F "contentType=image/jpeg" \
  http://localhost:8060/avatars
```

### Test Health Check
```bash
curl -H "Okta-User-ID: 550e8400-e29b-41d4-a716-446655440000" \
  http://localhost:8060/health
```
