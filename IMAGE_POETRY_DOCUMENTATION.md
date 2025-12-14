# Image Poetry Generation System - Comprehensive Documentation

## Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Database Schema](#database-schema)
4. [Configuration Setup](#configuration-setup)
5. [API Endpoints](#api-endpoints)
   - [Public Endpoints](#public-endpoints)
   - [User Endpoints](#user-endpoints)
   - [Admin Endpoints](#admin-endpoints)
6. [Request/Response Examples](#requestresponse-examples)
7. [Implementation Details](#implementation-details)
8. [Deployment Guide](#deployment-guide)

---

## Overview

The Image Poetry Generation System is a comprehensive feature that enables users to generate beautiful, shareable images from poetry couplets. The system supports:

- **Template-based Generation**: Use pre-designed templates with customizable layouts
- **Custom Background Generation**: Upload custom backgrounds for personalized images
- **Multi-language Support**: Generate images in Urdu, English, and Hindi
- **Mobile Optimization**: Images optimized for mobile devices (1080x1920, 9:16 aspect ratio)
- **User Collections**: Save, organize, and favorite generated images
- **Admin Management**: Complete admin interface for template and image management
- **Analytics**: Comprehensive analytics and usage statistics

### Key Features
✅ System-generated and user-created images
✅ Template library with categories (NATURE, MINIMAL, ARTISTIC, TRADITIONAL)
✅ Premium and free templates
✅ Custom background uploads
✅ Poet branding (poet image, watermark)
✅ High-quality rendering with Java2D
✅ S3 storage with automatic thumbnail generation
✅ User collections with favorites
✅ Share and view tracking
✅ Admin analytics dashboard

---

## System Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Application                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   REST API Controllers                       │
│  - ImagePoetryController (Public/User Endpoints)            │
│  - AdminImagePoetryController (Admin Endpoints)             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
│  - PoetryImageGenerationService (Core generation logic)     │
│  - ImageTemplateService (Template management)               │
│  - UserImageCollectionService (User collections)            │
│  - PoetryImageStorageService (S3 storage)                   │
│  - AdminImageAnalyticsService (Admin analytics)             │
│  - PoetBrandingService (Poet branding)                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Repository Layer                           │
│  - ImageTemplateRepository                                   │
│  - GeneratedPoetryImageRepository                           │
│  - UserImageCollectionRepository                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────┬─────────────────────────────────────┐
│   PostgreSQL Database │        AWS S3 Storage               │
│  - image_templates    │   - Template backgrounds            │
│  - generated_images   │   - Generated images                │
│  - user_collections   │   - User uploads                    │
└───────────────────────┴─────────────────────────────────────┘
```

### Technology Stack

- **Backend Framework**: Spring Boot 3.x
- **Database**: PostgreSQL (with JSONB support)
- **Storage**: AWS S3
- **Image Processing**: Java2D, Thumbnailator
- **Authentication**: Spring Security with JWT

---

## Database Schema

### 1. Image Templates (`image_templates`)

Stores pre-designed templates for image generation.

```sql
CREATE TABLE image_templates (
    id BIGSERIAL PRIMARY KEY,
    public_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    background_image_url TEXT NOT NULL,
    thumbnail_url TEXT,
    layout_config JSONB,
    is_premium BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Layout Config JSON Structure**:
```json
{
  "text": {
    "area": {
      "x": 100,
      "y": 500,
      "width": 880,
      "height": 1000
    },
    "font": {
      "name": "Arial",
      "size": 48,
      "color": "#FFFFFF",
      "style": "BOLD"
    },
    "alignment": "CENTER",
    "lineSpacing": 1.5
  },
  "poetImage": {
    "enabled": true,
    "x": 100,
    "y": 100,
    "size": 150
  },
  "watermark": {
    "text": "Poetry App",
    "x": 780,
    "y": 1860,
    "font": {
      "size": 20,
      "color": "#BDC3C7"
    }
  }
}
```

### 2. Generated Poetry Images (`generated_poetry_images`)

Stores all generated images (system and user-created).

```sql
CREATE TABLE generated_poetry_images (
    id BIGSERIAL PRIMARY KEY,
    public_id VARCHAR(50) UNIQUE NOT NULL,
    couplet_ids JSONB NOT NULL,
    poem_id BIGINT REFERENCES poems(id),
    poet_id BIGINT REFERENCES poets(id),
    template_id BIGINT REFERENCES image_templates(id),
    user_id BIGINT REFERENCES users(id),
    language_code VARCHAR(5) DEFAULT 'ur',
    is_custom BOOLEAN DEFAULT false,
    image_url TEXT NOT NULL,
    thumbnail_url TEXT,
    width INTEGER,
    height INTEGER,
    file_size_bytes INTEGER,
    format VARCHAR(10) DEFAULT 'PNG',
    share_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Couplet IDs JSON Structure**:
```json
["cpl_abc123", "cpl_def456"]
```

### 3. User Image Collections (`user_image_collections`)

Stores user's saved/favorited images.

```sql
CREATE TABLE user_image_collections (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    poetry_image_id BIGINT NOT NULL REFERENCES generated_poetry_images(id),
    collection_name VARCHAR(255) DEFAULT 'My Images',
    is_favorite BOOLEAN DEFAULT false,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, poetry_image_id)
);
```

**Indexes**:
```sql
CREATE INDEX idx_user_collections_user_id ON user_image_collections(user_id);
CREATE INDEX idx_user_collections_favorite ON user_image_collections(user_id, is_favorite);
CREATE INDEX idx_user_collections_name ON user_image_collections(user_id, collection_name);
```

---

## Configuration Setup

### 1. AWS S3 Configuration

**Yes, you MUST provide AWS S3 credentials.** Add these to your `application.yml` or `application.properties`:

#### application.yml
```yaml
aws:
  s3:
    bucket-name: your-poetry-app-bucket
    region: us-east-1
    access-key: YOUR_AWS_ACCESS_KEY
    secret-key: YOUR_AWS_SECRET_KEY
    image-templates-folder: templates/
    generated-images-folder: generated/
    user-uploads-folder: user-uploads/
    thumbnails-folder: thumbnails/
```

#### application.properties
```properties
aws.s3.bucket-name=your-poetry-app-bucket
aws.s3.region=us-east-1
aws.s3.access-key=YOUR_AWS_ACCESS_KEY
aws.s3.secret-key=YOUR_AWS_SECRET_KEY
aws.s3.image-templates-folder=templates/
aws.s3.generated-images-folder=generated/
aws.s3.user-uploads-folder=user-uploads/
aws.s3.thumbnails-folder=thumbnails/
```

### 2. AWS S3 Setup Steps

1. **Create S3 Bucket**:
   - Go to AWS Console → S3
   - Create a new bucket (e.g., `poetry-app-images`)
   - Enable public read access for generated images (or use pre-signed URLs)
   - Set CORS configuration if accessing from web browser

2. **CORS Configuration** (if needed):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

3. **Create IAM User** (for programmatic access):
   - Go to AWS Console → IAM
   - Create new user with programmatic access
   - Attach policy: `AmazonS3FullAccess` (or create custom policy with limited permissions)
   - Save Access Key ID and Secret Access Key

4. **Recommended IAM Policy** (minimal permissions):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::your-poetry-app-bucket/*",
        "arn:aws:s3:::your-poetry-app-bucket"
      ]
    }
  ]
}
```

### 3. Database Migration

Run the migration scripts to create tables:

```sql
-- Run in order:
-- 1. Create image_templates table
-- 2. Create generated_poetry_images table
-- 3. Create user_image_collections table
-- 4. Create indexes
```

### 4. Font Configuration (for Urdu/Arabic text)

Ensure your server has fonts that support Urdu/Arabic text:

**For Linux/Ubuntu**:
```bash
sudo apt-get install fonts-noto fonts-noto-cjk fonts-noto-color-emoji
```

**For Docker**:
```dockerfile
RUN apt-get update && \
    apt-get install -y fonts-noto fonts-noto-cjk
```

---

## API Endpoints

### Base URL
```
http://localhost:8080/api
```

### Authentication
Most endpoints require JWT authentication. Include in headers:
```
Authorization: Bearer YOUR_JWT_TOKEN
```

---

## Public Endpoints

### 1. Get All Active Templates

Get paginated list of active templates with optional filters.

**Endpoint**: `GET /api/image-templates`

**Query Parameters**:
- `category` (optional): Filter by category (NATURE, MINIMAL, ARTISTIC, TRADITIONAL)
- `isPremium` (optional): Filter by premium status (true/false)
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**cURL Example**:
```bash
# Get all templates
curl -X GET "http://localhost:8080/api/image-templates"

# Get free templates only
curl -X GET "http://localhost:8080/api/image-templates?isPremium=false"

# Get nature category templates
curl -X GET "http://localhost:8080/api/image-templates?category=NATURE"

# Get with pagination
curl -X GET "http://localhost:8080/api/image-templates?page=0&size=10"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Templates retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "tmpl_abc123",
        "name": "Nature Sunrise",
        "description": "Beautiful sunrise with mountains",
        "category": "NATURE",
        "backgroundImageUrl": "https://s3.amazonaws.com/bucket/templates/nature-sunrise.jpg",
        "thumbnailUrl": "https://s3.amazonaws.com/bucket/thumbnails/nature-sunrise-thumb.jpg",
        "layoutConfig": {
          "text": {
            "area": {"x": 100, "y": 500, "width": 880, "height": 1000},
            "font": {"name": "Arial", "size": 48, "color": "#FFFFFF"}
          }
        },
        "isPremium": false,
        "isActive": true,
        "displayOrder": 1,
        "usageCount": 245,
        "createdAt": "2024-01-15T10:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 1,
    "totalPages": 1
  }
}
```

---

### 2. Get Template by ID

Get a specific template by its public ID.

**Endpoint**: `GET /api/image-templates/{publicId}`

**Path Parameters**:
- `publicId`: Template public ID

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/image-templates/tmpl_abc123"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Template retrieved",
  "data": {
    "publicId": "tmpl_abc123",
    "name": "Nature Sunrise",
    "description": "Beautiful sunrise with mountains",
    "category": "NATURE",
    "backgroundImageUrl": "https://s3.amazonaws.com/bucket/templates/nature-sunrise.jpg",
    "thumbnailUrl": "https://s3.amazonaws.com/bucket/thumbnails/nature-sunrise-thumb.jpg",
    "layoutConfig": {...},
    "isPremium": false,
    "isActive": true,
    "displayOrder": 1,
    "usageCount": 245,
    "createdAt": "2024-01-15T10:30:00"
  }
}
```

---

### 3. Get Popular Templates

Get most popular templates by usage count.

**Endpoint**: `GET /api/image-templates/popular`

**Query Parameters**:
- `limit` (optional, default: 10): Number of templates to return

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/image-templates/popular?limit=5"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Popular templates retrieved",
  "data": [
    {
      "publicId": "tmpl_abc123",
      "name": "Nature Sunrise",
      "usageCount": 1234,
      ...
    },
    {
      "publicId": "tmpl_def456",
      "name": "Minimal White",
      "usageCount": 987,
      ...
    }
  ]
}
```

---

## User Endpoints

### 4. Generate Image for Couplet

Generate a poetry image for a specific couplet.

**Endpoint**: `POST /api/couplets/{coupletId}/generate-image`

**Path Parameters**:
- `coupletId`: Couplet public ID

**Authentication**: Required (JWT token)

**Request Body**:
```json
{
  "generationType": "SYSTEM",
  "templateId": "tmpl_abc123",
  "languageCode": "ur",
  "includePoetImage": true,
  "includeWatermark": true
}
```

**Request Body Fields**:
- `generationType` (required): "SYSTEM" or "CUSTOM"
- `templateId` (optional for SYSTEM): Template to use, uses default if not provided
- `customBackgroundUrl` (required for CUSTOM): URL of custom background
- `languageCode` (optional, default: "ur"): Language code (ur, en, hi)
- `includePoetImage` (optional, default: true): Include poet's image
- `includeWatermark` (optional, default: true): Include watermark
- `customTextColor` (optional): Custom text color (hex code)
- `customizations` (optional): Additional customization options

**cURL Example - System Template**:
```bash
curl -X POST "http://localhost:8080/api/couplets/cpl_xyz789/generate-image" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "generationType": "SYSTEM",
    "templateId": "tmpl_abc123",
    "languageCode": "ur"
  }'
```

**cURL Example - Custom Background**:
```bash
curl -X POST "http://localhost:8080/api/couplets/cpl_xyz789/generate-image" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "generationType": "CUSTOM",
    "customBackgroundUrl": "https://s3.amazonaws.com/bucket/user-uploads/bg123.jpg",
    "languageCode": "ur",
    "customizations": {
      "textColor": "#FFFFFF"
    }
  }'
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Image generated successfully",
  "data": {
    "publicId": "img_generated123",
    "coupletIds": ["cpl_xyz789"],
    "poemPublicId": "poem_abc456",
    "poetPublicId": "poet_def789",
    "poetName": "Mirza Ghalib",
    "languageCode": "ur",
    "templateId": "tmpl_abc123",
    "templateName": "Nature Sunrise",
    "isCustom": false,
    "imageUrl": "https://s3.amazonaws.com/bucket/generated/img_generated123.png",
    "thumbnailUrl": "https://s3.amazonaws.com/bucket/thumbnails/img_generated123_thumb.jpg",
    "width": 1080,
    "height": 1920,
    "fileSizeBytes": 524288,
    "format": "PNG",
    "shareCount": 0,
    "viewCount": 0,
    "userId": 123,
    "isUserCreated": true,
    "createdAt": "2024-01-20T14:30:00"
  }
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "message": "Custom background URL is required for CUSTOM generation",
  "data": null
}
```

---

### 5. Upload Custom Background

Upload a custom background image for image generation.

**Endpoint**: `POST /api/users/me/upload-background`

**Authentication**: Required (JWT token)

**Content-Type**: `multipart/form-data`

**Request Parameters**:
- `file` (required): Image file (JPEG, PNG, etc.)

**cURL Example**:
```bash
curl -X POST "http://localhost:8080/api/users/me/upload-background" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/background.jpg"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Background uploaded successfully",
  "data": "https://s3.amazonaws.com/bucket/user-uploads/user_123_bg_xyz.jpg"
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "message": "File must be an image",
  "data": null
}
```

---

### 6. Get Images for Couplet

Get all generated images for a specific couplet.

**Endpoint**: `GET /api/couplets/{coupletId}/images`

**Path Parameters**:
- `coupletId`: Couplet public ID

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/couplets/cpl_xyz789/images"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Images retrieved",
  "data": [
    {
      "publicId": "img_generated123",
      "coupletIds": ["cpl_xyz789"],
      "imageUrl": "https://s3.amazonaws.com/bucket/generated/img_generated123.png",
      "thumbnailUrl": "https://s3.amazonaws.com/bucket/thumbnails/img_generated123_thumb.jpg",
      "templateId": "tmpl_abc123",
      "templateName": "Nature Sunrise",
      "shareCount": 45,
      "viewCount": 234,
      "createdAt": "2024-01-20T14:30:00"
    }
  ]
}
```

---

### 7. Save Image to Collection

Save a generated image to user's collection.

**Endpoint**: `POST /api/poetry-images/{imageId}/save`

**Path Parameters**:
- `imageId`: Image public ID

**Authentication**: Required (JWT token)

**Request Body**:
```json
{
  "collectionName": "My Favorites",
  "isFavorite": true
}
```

**Request Body Fields**:
- `collectionName` (optional, default: "My Images"): Collection name
- `isFavorite` (optional, default: false): Mark as favorite

**cURL Example**:
```bash
curl -X POST "http://localhost:8080/api/poetry-images/img_generated123/save" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "collectionName": "My Favorites",
    "isFavorite": true
  }'
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Image saved to collection",
  "data": null
}
```

---

### 8. Get User's Saved Images

Get user's saved images with optional filters.

**Endpoint**: `GET /api/users/me/saved-images`

**Authentication**: Required (JWT token)

**Query Parameters**:
- `collectionName` (optional): Filter by collection name
- `favoritesOnly` (optional): Show only favorites (true/false)
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**cURL Example**:
```bash
# Get all saved images
curl -X GET "http://localhost:8080/api/users/me/saved-images" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Get favorites only
curl -X GET "http://localhost:8080/api/users/me/saved-images?favoritesOnly=true" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Get from specific collection
curl -X GET "http://localhost:8080/api/users/me/saved-images?collectionName=My%20Favorites" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Saved images retrieved",
  "data": {
    "content": [
      {
        "publicId": "img_generated123",
        "coupletIds": ["cpl_xyz789"],
        "imageUrl": "https://s3.amazonaws.com/bucket/generated/img_generated123.png",
        "templateName": "Nature Sunrise",
        "createdAt": "2024-01-20T14:30:00"
      }
    ],
    "totalElements": 1,
    "totalPages": 1
  }
}
```

---

### 9. Get User's Collection Names

Get list of user's collection names.

**Endpoint**: `GET /api/users/me/collection-names`

**Authentication**: Required (JWT token)

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/users/me/collection-names" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Collection names retrieved",
  "data": [
    "My Images",
    "My Favorites",
    "Nature Collection",
    "Ghalib Poetry"
  ]
}
```

---

### 10. Toggle Favorite Status

Toggle favorite status for a saved image.

**Endpoint**: `POST /api/poetry-images/{imageId}/toggle-favorite`

**Path Parameters**:
- `imageId`: Image public ID

**Authentication**: Required (JWT token)

**cURL Example**:
```bash
curl -X POST "http://localhost:8080/api/poetry-images/img_generated123/toggle-favorite" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Favorite toggled",
  "data": true
}
```

---

### 11. Remove Image from Collection

Remove a saved image from user's collection.

**Endpoint**: `DELETE /api/users/me/saved-images/{imageId}`

**Path Parameters**:
- `imageId`: Image public ID

**Authentication**: Required (JWT token)

**cURL Example**:
```bash
curl -X DELETE "http://localhost:8080/api/users/me/saved-images/img_generated123" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Image removed from collection",
  "data": null
}
```

---

### 12. Get Collection Statistics

Get statistics about user's image collections.

**Endpoint**: `GET /api/users/me/collection-stats`

**Authentication**: Required (JWT token)

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/users/me/collection-stats" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Stats retrieved",
  "data": {
    "totalImages": 45,
    "favoriteCount": 12,
    "collectionCount": 4,
    "collectionNames": [
      "My Images",
      "My Favorites",
      "Nature Collection",
      "Ghalib Poetry"
    ]
  }
}
```

---

## Admin Endpoints

**Note**: All admin endpoints should be protected with `@PreAuthorize("hasRole('ADMIN')")` when role-based authentication is implemented.

**Base Path**: `/api/admin/image-poetry`

---

### 13. Create Template (Admin)

Create a new image template.

**Endpoint**: `POST /api/admin/image-poetry/templates`

**Authentication**: Required (Admin JWT token)

**Request Body**:
```json
{
  "name": "Sunset Beach",
  "description": "Beautiful beach sunset scene",
  "category": "NATURE",
  "backgroundImageUrl": "https://s3.amazonaws.com/bucket/templates/sunset-beach.jpg",
  "thumbnailUrl": "https://s3.amazonaws.com/bucket/thumbnails/sunset-beach-thumb.jpg",
  "layoutConfig": {
    "text": {
      "area": {
        "x": 100,
        "y": 500,
        "width": 880,
        "height": 1000
      },
      "font": {
        "name": "Arial",
        "size": 48,
        "color": "#FFFFFF",
        "style": "BOLD"
      },
      "alignment": "CENTER",
      "lineSpacing": 1.5
    },
    "poetImage": {
      "enabled": true,
      "x": 100,
      "y": 100,
      "size": 150
    }
  },
  "isPremium": false,
  "displayOrder": 10
}
```

**cURL Example**:
```bash
curl -X POST "http://localhost:8080/api/admin/image-poetry/templates" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sunset Beach",
    "description": "Beautiful beach sunset scene",
    "category": "NATURE",
    "backgroundImageUrl": "https://s3.amazonaws.com/bucket/templates/sunset-beach.jpg",
    "isPremium": false,
    "displayOrder": 10,
    "layoutConfig": {
      "text": {
        "area": {"x": 100, "y": 500, "width": 880, "height": 1000},
        "font": {"name": "Arial", "size": 48, "color": "#FFFFFF"}
      }
    }
  }'
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Template created successfully",
  "data": {
    "publicId": "tmpl_new123",
    "name": "Sunset Beach",
    "description": "Beautiful beach sunset scene",
    "category": "NATURE",
    "backgroundImageUrl": "https://s3.amazonaws.com/bucket/templates/sunset-beach.jpg",
    "isPremium": false,
    "isActive": true,
    "displayOrder": 10,
    "usageCount": 0,
    "createdAt": "2024-01-20T15:00:00"
  }
}
```

---

### 14. Update Template (Admin)

Update an existing template.

**Endpoint**: `PUT /api/admin/image-poetry/templates/{publicId}`

**Path Parameters**:
- `publicId`: Template public ID

**Authentication**: Required (Admin JWT token)

**Request Body** (all fields optional):
```json
{
  "name": "Updated Sunset Beach",
  "description": "Updated description",
  "category": "NATURE",
  "isPremium": true,
  "isActive": true,
  "displayOrder": 5
}
```

**cURL Example**:
```bash
curl -X PUT "http://localhost:8080/api/admin/image-poetry/templates/tmpl_abc123" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Sunset Beach",
    "isPremium": true,
    "displayOrder": 5
  }'
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Template updated successfully",
  "data": {
    "publicId": "tmpl_abc123",
    "name": "Updated Sunset Beach",
    "isPremium": true,
    "displayOrder": 5,
    ...
  }
}
```

---

### 15. Delete Template (Admin)

Soft delete a template (marks as inactive).

**Endpoint**: `DELETE /api/admin/image-poetry/templates/{publicId}`

**Path Parameters**:
- `publicId`: Template public ID

**Authentication**: Required (Admin JWT token)

**cURL Example**:
```bash
curl -X DELETE "http://localhost:8080/api/admin/image-poetry/templates/tmpl_abc123" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Template deleted successfully",
  "data": null
}
```

---

### 16. Get All Templates (Admin)

Get all templates including inactive ones.

**Endpoint**: `GET /api/admin/image-poetry/templates/all`

**Authentication**: Required (Admin JWT token)

**Query Parameters**:
- `page` (optional, default: 0)
- `size` (optional, default: 20)

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/admin/image-poetry/templates/all?page=0&size=50" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "All templates retrieved",
  "data": {
    "content": [
      {
        "publicId": "tmpl_abc123",
        "name": "Nature Sunrise",
        "isActive": true,
        ...
      },
      {
        "publicId": "tmpl_def456",
        "name": "Inactive Template",
        "isActive": false,
        ...
      }
    ],
    "totalElements": 2
  }
}
```

---

### 17. Bulk Update Template Status (Admin)

Activate or deactivate multiple templates at once.

**Endpoint**: `POST /api/admin/image-poetry/templates/bulk-status`

**Authentication**: Required (Admin JWT token)

**Query Parameters**:
- `templateIds` (required): Comma-separated list of template IDs
- `isActive` (required): true or false

**cURL Example**:
```bash
curl -X POST "http://localhost:8080/api/admin/image-poetry/templates/bulk-status?templateIds=tmpl_abc123,tmpl_def456,tmpl_ghi789&isActive=true" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "3 templates updated successfully",
  "data": null
}
```

---

### 18. Get All Generated Images (Admin)

Get all generated images with filters.

**Endpoint**: `GET /api/admin/image-poetry/images`

**Authentication**: Required (Admin JWT token)

**Query Parameters**:
- `isCustom` (optional): Filter by custom/system (true/false)
- `templateId` (optional): Filter by template
- `page` (optional, default: 0)
- `size` (optional, default: 20)

**cURL Example**:
```bash
# Get all images
curl -X GET "http://localhost:8080/api/admin/image-poetry/images" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"

# Get only custom images
curl -X GET "http://localhost:8080/api/admin/image-poetry/images?isCustom=true" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"

# Get images from specific template
curl -X GET "http://localhost:8080/api/admin/image-poetry/images?templateId=tmpl_abc123" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Images retrieved",
  "data": {
    "content": [
      {
        "publicId": "img_generated123",
        "coupletIds": ["cpl_xyz789"],
        "templateId": "tmpl_abc123",
        "isCustom": false,
        "imageUrl": "https://s3.amazonaws.com/bucket/generated/img_generated123.png",
        "shareCount": 45,
        "viewCount": 234,
        "userId": 123,
        "createdAt": "2024-01-20T14:30:00"
      }
    ],
    "totalElements": 1
  }
}
```

---

### 19. Delete Image (Admin)

Delete a generated image (removes from database and S3).

**Endpoint**: `DELETE /api/admin/image-poetry/images/{publicId}`

**Path Parameters**:
- `publicId`: Image public ID

**Authentication**: Required (Admin JWT token)

**cURL Example**:
```bash
curl -X DELETE "http://localhost:8080/api/admin/image-poetry/images/img_generated123" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Image deleted successfully",
  "data": null
}
```

---

### 20. Bulk Delete Images (Admin)

Delete multiple images at once.

**Endpoint**: `DELETE /api/admin/image-poetry/images/bulk`

**Authentication**: Required (Admin JWT token)

**Query Parameters**:
- `imageIds` (required): Comma-separated list of image IDs

**cURL Example**:
```bash
curl -X DELETE "http://localhost:8080/api/admin/image-poetry/images/bulk?imageIds=img_123,img_456,img_789" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "3 images deleted successfully",
  "data": null
}
```

---

### 21. Get Popular Images (Admin)

Get most popular images by shares or views.

**Endpoint**: `GET /api/admin/image-poetry/images/popular`

**Authentication**: Required (Admin JWT token)

**Query Parameters**:
- `limit` (optional, default: 50): Number of images to return
- `orderBy` (optional, default: "shares"): Order by "shares" or "views"

**cURL Example**:
```bash
# Most shared images
curl -X GET "http://localhost:8080/api/admin/image-poetry/images/popular?limit=20&orderBy=shares" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"

# Most viewed images
curl -X GET "http://localhost:8080/api/admin/image-poetry/images/popular?limit=20&orderBy=views" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Popular images retrieved",
  "data": [
    {
      "publicId": "img_popular1",
      "shareCount": 1234,
      "viewCount": 5678,
      ...
    }
  ]
}
```

---

### 22. Get Comprehensive Analytics (Admin)

Get comprehensive analytics for the entire system.

**Endpoint**: `GET /api/admin/image-poetry/analytics`

**Authentication**: Required (Admin JWT token)

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/admin/image-poetry/analytics" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Analytics retrieved",
  "data": {
    "totalImagesGenerated": 5432,
    "systemGeneratedCount": 3210,
    "userCreatedCount": 2222,
    "totalViews": 123456,
    "totalShares": 45678,
    "imagesByTemplate": {
      "Nature Sunrise": 1234,
      "Minimal White": 987,
      "Artistic Gold": 654
    },
    "imagesByLanguage": {
      "ur": 3456,
      "en": 1234,
      "hi": 742
    },
    "imagesByPoet": {
      "Mirza Ghalib": 2345,
      "Allama Iqbal": 1876,
      "Faiz Ahmed Faiz": 1211
    },
    "averageFileSize": 0.512,
    "totalStorageUsed": 2781184000
  }
}
```

---

### 23. Get Template Usage Statistics (Admin)

Get templates ordered by usage count.

**Endpoint**: `GET /api/admin/image-poetry/analytics/templates`

**Authentication**: Required (Admin JWT token)

**Query Parameters**:
- `page` (optional, default: 0)
- `size` (optional, default: 20)

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/admin/image-poetry/analytics/templates?page=0&size=10" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Template usage stats retrieved",
  "data": {
    "content": [
      {
        "publicId": "tmpl_abc123",
        "name": "Nature Sunrise",
        "usageCount": 1234,
        "category": "NATURE",
        ...
      },
      {
        "publicId": "tmpl_def456",
        "name": "Minimal White",
        "usageCount": 987,
        "category": "MINIMAL",
        ...
      }
    ]
  }
}
```

---

### 24. Get Storage Statistics (Admin)

Get detailed storage usage statistics.

**Endpoint**: `GET /api/admin/image-poetry/analytics/storage`

**Authentication**: Required (Admin JWT token)

**cURL Example**:
```bash
curl -X GET "http://localhost:8080/api/admin/image-poetry/analytics/storage" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Storage stats retrieved",
  "data": {
    "totalImagesCount": 5432,
    "totalSizeBytes": 2781184000,
    "totalSizeMB": 2652.5,
    "totalSizeGB": 2.59,
    "averageImageSizeMB": 0.488,
    "largestImageBytes": 2097152,
    "smallestImageBytes": 204800
  }
}
```

---

## Implementation Details

### Phase 1: Database & Storage (Commits: d9412b0, eff1dff)

**Files Created**:
- `ImageTemplate.java` - Entity for image templates
- `GeneratedPoetryImage.java` - Entity for generated images
- `UserImageCollection.java` - Entity for user collections
- `ImageTemplateRepository.java` - Repository with custom queries
- `GeneratedPoetryImageRepository.java` - Repository with JSONB queries
- `UserImageCollectionRepository.java` - Repository for user collections
- `PoetryImageStorageService.java` - S3 storage service

**Key Features**:
- PostgreSQL JSONB support for flexible configuration storage
- Custom repository queries for complex filtering
- S3 integration with folder structure
- Automatic thumbnail generation

### Phase 2: Business Logic (Commit: d0b3ca7)

**Files Created**:
- `ImageTemplateService.java` - Template management
- `UserImageCollectionService.java` - User collection management
- `PoetBrandingService.java` - Poet image/branding utilities

**Key Features**:
- Template selection and default template logic
- User collection CRUD operations
- Favorite management
- Collection statistics

### Phase 3: Image Generation (Commit: dc7eb2e)

**Files Created**:
- `PoetryImageGenerationService.java` - Core image generation with Java2D

**Key Features**:
- Mobile-optimized rendering (1080x1920, 9:16 ratio)
- Multi-language text rendering (Urdu RTL support)
- Poet image overlay with circular mask
- Automatic text wrapping and positioning
- Watermark support
- Custom background support
- High-quality output (95% JPEG quality)

**Text Rendering**:
- Automatic line breaking
- RTL (Right-to-Left) support for Urdu/Arabic
- Custom font support
- Configurable alignment (LEFT, CENTER, RIGHT)
- Line spacing control

### Phase 4: REST API (Commit: 1a0480a)

**Files Created**:
- `ImagePoetryController.java` - Public/user endpoints
- `ImagePoetryMapper.java` - Entity-to-DTO mapper
- DTOs: `ImageTemplateDto`, `GenerateImageRequest`, `GeneratedImageDto`, `SaveImageToCollectionRequest`

**Key Features**:
- Complete REST API for all operations
- Request validation with Jakarta Validation
- Pagination support
- Error handling
- Authentication integration

### Phase 5: Admin & Analytics (Commit: 0af5cae)

**Files Created**:
- `AdminImagePoetryController.java` - Admin endpoints
- `AdminImageAnalyticsService.java` - Analytics service
- Admin DTOs: `CreateTemplateRequest`, `UpdateTemplateRequest`, `ImageAnalyticsDto`

**Key Features**:
- Complete admin CRUD operations
- Bulk operations
- Comprehensive analytics
- Storage statistics
- Template popularity tracking

---

## Deployment Guide

### 1. Pre-deployment Checklist

- [ ] AWS S3 bucket created and configured
- [ ] IAM user created with S3 access
- [ ] S3 credentials added to application.yml
- [ ] Database migrations applied
- [ ] Fonts installed on server (for Urdu support)
- [ ] Spring Boot application built
- [ ] Environment variables configured

### 2. Environment Variables

For production, use environment variables instead of hardcoding credentials:

```bash
export AWS_S3_BUCKET_NAME=your-poetry-app-bucket
export AWS_S3_REGION=us-east-1
export AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY
```

Update `application.yml`:
```yaml
aws:
  s3:
    bucket-name: ${AWS_S3_BUCKET_NAME}
    region: ${AWS_S3_REGION}
    access-key: ${AWS_ACCESS_KEY_ID}
    secret-key: ${AWS_SECRET_ACCESS_KEY}
```

### 3. Database Setup

```bash
# Connect to PostgreSQL
psql -U postgres -d poetry_db

# Run migrations
\i migrations/001_create_image_templates.sql
\i migrations/002_create_generated_images.sql
\i migrations/003_create_user_collections.sql
\i migrations/004_create_indexes.sql
```

### 4. Initial Template Data

Create some initial templates:

```sql
INSERT INTO image_templates (public_id, name, description, category, background_image_url, thumbnail_url, layout_config, is_premium, is_active, display_order, usage_count)
VALUES
  ('tmpl_default1', 'Nature Sunrise', 'Beautiful sunrise with mountains', 'NATURE',
   'https://your-bucket.s3.amazonaws.com/templates/nature-sunrise.jpg',
   'https://your-bucket.s3.amazonaws.com/thumbnails/nature-sunrise-thumb.jpg',
   '{"text": {"area": {"x": 100, "y": 500, "width": 880, "height": 1000}, "font": {"name": "Arial", "size": 48, "color": "#FFFFFF"}}}',
   false, true, 1, 0);
```

### 5. Testing

**Test Image Generation**:
```bash
# 1. Get templates
curl -X GET "http://your-api.com/api/image-templates"

# 2. Generate test image
curl -X POST "http://your-api.com/api/couplets/TEST_COUPLET_ID/generate-image" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "generationType": "SYSTEM",
    "languageCode": "ur"
  }'

# 3. Verify image URL in response
# 4. Check S3 bucket for uploaded image
```

### 6. Performance Optimization

**Recommended Settings**:

```yaml
# application.yml
spring:
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB

  jpa:
    properties:
      hibernate:
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true

# Connection pooling
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
```

**Image Generation Optimization**:
- Images are generated synchronously (consider async for production)
- Thumbnails are created automatically
- S3 uploads use parallel streams where possible

### 7. Monitoring

**Key Metrics to Monitor**:
- Image generation time (should be < 5 seconds)
- S3 upload success rate
- Storage usage (via admin analytics)
- Template usage distribution
- User engagement (shares, views)

**Logging**:
```yaml
logging:
  level:
    com.techhikes.poetry.services.PoetryImageGenerationService: DEBUG
    com.techhikes.poetry.services.PoetryImageStorageService: DEBUG
```

### 8. Scaling Considerations

**For High Traffic**:
1. Use async image generation with job queues (RabbitMQ, SQS)
2. Implement CDN for S3 images (CloudFront)
3. Add Redis caching for popular templates
4. Consider horizontal scaling with load balancer
5. Separate read replicas for analytics queries

---

## Security Considerations

### 1. File Upload Security

**Current Implementation**:
- File type validation (must be image)
- Size limits enforced by Spring Boot
- Unique filenames prevent overwrites

**Recommendations**:
- Scan uploaded files for malware
- Validate image dimensions
- Limit file types to JPEG, PNG only
- Implement rate limiting on uploads

### 2. S3 Security

**Recommendations**:
- Use IAM roles instead of access keys (for EC2/ECS)
- Enable S3 bucket versioning
- Enable S3 server-side encryption
- Use signed URLs for private images
- Set lifecycle policies to archive old images

### 3. Admin Endpoints

**IMPORTANT**: Add role-based access control:

```java
@PreAuthorize("hasRole('ADMIN')")
@PostMapping("/templates")
public ResponseEntity<ApiResponse<ImageTemplateDto>> createTemplate(...) {
    // ...
}
```

### 4. Rate Limiting

Implement rate limiting to prevent abuse:

```java
@RateLimiter(name = "imageGeneration", fallbackMethod = "rateLimitFallback")
@PostMapping("/couplets/{coupletId}/generate-image")
public ResponseEntity<...> generateImage(...) {
    // ...
}
```

---

## Troubleshooting

### Common Issues

**1. Images not generating**
- Check S3 credentials
- Verify template exists and is active
- Check logs for font errors
- Ensure couplet exists in database

**2. Urdu text not rendering**
- Install Noto fonts on server
- Verify font files are accessible
- Check file permissions

**3. S3 upload failures**
- Verify bucket permissions
- Check IAM user has PutObject permission
- Verify bucket name and region

**4. Out of memory errors**
- Increase JVM heap size: `-Xmx2g`
- Optimize image generation batch size
- Consider async processing

**5. Slow image generation**
- Check image resolution settings
- Optimize layout config
- Consider caching rendered poet images

---

## Future Enhancements

### Planned Features
- [ ] Async image generation with job queues
- [ ] Image templates with video backgrounds
- [ ] Animated GIF generation
- [ ] Social media sharing integration
- [ ] Image editing (crop, filters, effects)
- [ ] Collaborative collections
- [ ] Template marketplace
- [ ] AI-powered template recommendations
- [ ] Batch image generation API
- [ ] WebSocket for real-time generation status

---

## Support & Contact

For questions or issues:
- GitHub Issues: [Repository Issues Page]
- Email: support@poetryapp.com
- Documentation: This file

---

## Changelog

### Version 1.0.0 (2024-01-20)
- ✅ Initial release
- ✅ Template-based image generation
- ✅ Custom background support
- ✅ Multi-language support (Urdu, English, Hindi)
- ✅ User collections and favorites
- ✅ Admin management interface
- ✅ Comprehensive analytics
- ✅ S3 storage integration
- ✅ Mobile-optimized output

---

**End of Documentation**
