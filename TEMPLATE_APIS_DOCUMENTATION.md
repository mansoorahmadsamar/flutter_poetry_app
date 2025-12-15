# Template APIs Documentation

Complete documentation of all Image Template APIs with request and response examples.

---

## Base URL
```
http://localhost:8080
```

---

## Public Template Endpoints

### 1. Get All Active Templates
Get all active templates with optional filters.

**Endpoint**: `GET /api/image-templates`

**Query Parameters**:
- `category` (optional): Filter by category (CLASSIC, MODERN, FLORAL, GEOMETRIC, MINIMAL, NATURE)
- `isPremium` (optional): Filter by premium status (true/false)
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**Request Example**:
```bash
# Get all templates
curl -X GET "http://localhost:8080/api/image-templates"

# Filter by category
curl -X GET "http://localhost:8080/api/image-templates?category=CLASSIC"

# Filter premium templates
curl -X GET "http://localhost:8080/api/image-templates?isPremium=true"

# With pagination
curl -X GET "http://localhost:8080/api/image-templates?page=0&size=10"
```

**Response Example**:
```json
{
  "success": true,
  "message": "Templates retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "6b03745a-23a9-4b07-b758-f334aed6cecc",
        "name": "Classic Vintage Parchment",
        "description": "Classic vintage parchment background",
        "category": "CLASSIC",
        "backgroundImageUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/...",
        "thumbnailUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/...",
        "layoutConfig": {
          "canvas": {
            "width": 1080,
            "height": 1920
          },
          "textArea": {
            "x": 100,
            "y": 700,
            "width": 880,
            "height": 800
          },
          "fonts": {
            "urdu": {
              "family": "Jameel Noori Nastaleeq",
              "size": 46,
              "color": "#3E2723"
            },
            "english": {
              "family": "Georgia",
              "size": 24,
              "color": "#4E342E"
            }
          },
          "poetImage": {
            "enabled": true,
            "x": 90,
            "y": 90,
            "size": 140,
            "borderColor": "#8D6E63",
            "borderWidth": 4
          },
          "poetInfo": {
            "x": 250,
            "y": 135,
            "nameFont": {
              "family": "Georgia",
              "size": 30,
              "color": "#3E2723",
              "weight": "bold"
            }
          },
          "watermark": {
            "enabled": true,
            "text": "Poetry App",
            "x": 880,
            "y": 1860,
            "font": {
              "size": 18,
              "color": "#A1887F",
              "alpha": 0.6
            }
          },
          "coupletType": {
            "enabled": true
          }
        },
        "isPremium": false,
        "isActive": true,
        "displayOrder": 1,
        "usageCount": 0,
        "createdAt": "2025-12-15T18:30:00.000+00:00",
        "updatedAt": "2025-12-15T19:15:00.000+00:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20,
      "sort": {
        "empty": true,
        "sorted": false,
        "unsorted": true
      },
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "last": true,
    "totalPages": 1,
    "totalElements": 5,
    "size": 20,
    "number": 0,
    "sort": {
      "empty": true,
      "sorted": false,
      "unsorted": true
    },
    "first": true,
    "numberOfElements": 5,
    "empty": false
  },
  "timestamp": "2025-12-15T19:20:00.000+00:00"
}
```

---

### 2. Get Template By ID
Get a specific template by its public ID.

**Endpoint**: `GET /api/image-templates/{publicId}`

**Path Parameters**:
- `publicId`: Template's public UUID

**Request Example**:
```bash
curl -X GET "http://localhost:8080/api/image-templates/6b03745a-23a9-4b07-b758-f334aed6cecc"
```

**Response Example**:
```json
{
  "success": true,
  "message": "Template retrieved",
  "data": {
    "publicId": "6b03745a-23a9-4b07-b758-f334aed6cecc",
    "name": "Classic Vintage Parchment",
    "description": "Classic vintage parchment background",
    "category": "CLASSIC",
    "backgroundImageUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/...",
    "thumbnailUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/...",
    "layoutConfig": { /* ... full layoutConfig ... */ },
    "isPremium": false,
    "isActive": true,
    "displayOrder": 1,
    "usageCount": 0,
    "createdAt": "2025-12-15T18:30:00.000+00:00",
    "updatedAt": "2025-12-15T19:15:00.000+00:00"
  },
  "timestamp": "2025-12-15T19:20:00.000+00:00"
}
```

---

### 3. Get Popular Templates
Get most popular templates by usage.

**Endpoint**: `GET /api/image-templates/popular`

**Query Parameters**:
- `limit` (optional, default: 10): Number of templates to return

**Request Example**:
```bash
curl -X GET "http://localhost:8080/api/image-templates/popular?limit=5"
```

**Response Example**:
```json
{
  "success": true,
  "message": "Popular templates retrieved",
  "data": [
    {
      "publicId": "9f054040-2647-4097-955c-94849960d41a",
      "name": "Modern Gradient Blue",
      "category": "MODERN",
      "usageCount": 1500,
      /* ... other fields ... */
    },
    {
      "publicId": "ad37bb12-2a94-432b-b6c4-ef1a95fe81d7",
      "name": "Floral Watercolor Pink",
      "category": "FLORAL",
      "usageCount": 1200,
      /* ... other fields ... */
    }
  ],
  "timestamp": "2025-12-15T19:20:00.000+00:00"
}
```

---

## Admin Template Endpoints

### 4. Create Template (JSON)
Create a new template with JSON data (URLs provided).

**Endpoint**: `POST /api/admin/image-poetry/templates`

**Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "name": "Minimal Soft Beige",
  "description": "Minimalist design with soft beige tones",
  "category": "MINIMAL",
  "backgroundImageUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/minimal-beige.png",
  "thumbnailUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/minimal-beige.png",
  "layoutConfig": {
    "canvas": {"width": 1080, "height": 1920},
    "textArea": {"x": 150, "y": 800, "width": 780, "height": 600},
    "fonts": {
      "urdu": {"family": "Jameel Noori Nastaleeq", "size": 44, "color": "#5D4037"},
      "english": {"family": "Arial", "size": 22, "color": "#757575"}
    },
    "poetImage": {
      "enabled": true,
      "x": 90,
      "y": 1650,
      "size": 120,
      "borderColor": "#BCAAA4",
      "borderWidth": 3
    },
    "poetInfo": {
      "x": 230,
      "y": 1685,
      "nameFont": {"family": "Arial", "size": 26, "color": "#5D4037", "weight": "normal"}
    },
    "watermark": {
      "enabled": true,
      "text": "Poetry App",
      "x": 900,
      "y": 1870,
      "font": {"size": 16, "color": "#D7CCC8", "alpha": 0.5}
    },
    "coupletType": {"enabled": false}
  },
  "isPremium": false,
  "displayOrder": 5
}
```

**Request Example**:
```bash
curl -X POST "http://localhost:8080/api/admin/image-poetry/templates" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Minimal Soft Beige",
    "category": "MINIMAL",
    "backgroundImageUrl": "https://...",
    "layoutConfig": { ... }
  }'
```

**Response Example**:
```json
{
  "success": true,
  "message": "Template created successfully",
  "data": {
    "publicId": "a1b2c3d4-5678-90ab-cdef-1234567890ab",
    "name": "Minimal Soft Beige",
    "description": "Minimalist design with soft beige tones",
    "category": "MINIMAL",
    "backgroundImageUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/minimal-beige.png",
    "thumbnailUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/minimal-beige.png",
    "layoutConfig": { /* ... */ },
    "isPremium": false,
    "isActive": true,
    "displayOrder": 5,
    "usageCount": 0,
    "createdAt": "2025-12-15T19:30:00.000+00:00",
    "updatedAt": "2025-12-15T19:30:00.000+00:00"
  },
  "timestamp": "2025-12-15T19:30:00.000+00:00"
}
```

---

### 5. Upload Template (Multipart)
Upload a template with an image file.

**Endpoint**: `POST /api/admin/image-poetry/templates/upload`

**Headers**:
```
Content-Type: multipart/form-data
```

**Form Data Fields**:
- `file` (required): Image file (PNG, JPG, JPEG)
- `name` (required): Template name
- `category` (required): Category (CLASSIC, MODERN, FLORAL, GEOMETRIC, MINIMAL, NATURE)
- `description` (optional): Template description
- `layoutConfig` (optional): Layout configuration as JSON string
- `isPremium` (optional, default: false): Premium status
- `displayOrder` (optional): Display order

**Request Example (cURL)**:
```bash
curl -X POST "http://localhost:8080/api/admin/image-poetry/templates/upload" \
  -F "file=@/path/to/template.png" \
  -F "name=Classic Vintage Parchment" \
  -F "category=CLASSIC" \
  -F "description=A classic vintage parchment background" \
  -F "isPremium=false" \
  -F "displayOrder=1"
```

**Request Example (With layoutConfig)**:
```bash
curl -X POST "http://localhost:8080/api/admin/image-poetry/templates/upload" \
  -F "file=@/path/to/template.png" \
  -F "name=Modern Gradient Blue" \
  -F "category=MODERN" \
  -F 'layoutConfig={
    "canvas": {"width": 1080, "height": 1920},
    "fonts": {
      "urdu": {"family": "Jameel Noori Nastaleeq", "size": 50, "color": "#FFFFFF"}
    }
  }'
```

**Response Example**:
```json
{
  "success": true,
  "message": "Template uploaded and created successfully",
  "data": {
    "publicId": "9f054040-2647-4097-955c-94849960d41a",
    "name": "Classic Vintage Parchment",
    "description": "A classic vintage parchment background",
    "category": "CLASSIC",
    "backgroundImageUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/550e8400-e29b-41d4-a716-446655440000-template.png",
    "thumbnailUrl": "https://d8e5xg2x6e8y1.cloudfront.net/templates/backgrounds/550e8400-e29b-41d4-a716-446655440000-template.png",
    "layoutConfig": null,
    "isPremium": false,
    "isActive": true,
    "displayOrder": 1,
    "usageCount": 0,
    "createdAt": "2025-12-15T18:30:00.000+00:00",
    "updatedAt": "2025-12-15T18:30:00.000+00:00"
  },
  "timestamp": "2025-12-15T18:30:00.000+00:00"
}
```

---

### 6. Update Template
Update an existing template (name, description, layoutConfig, etc.).

**Endpoint**: `PUT /api/admin/image-poetry/templates/{publicId}`

**Headers**:
```
Content-Type: application/json
```

**Path Parameters**:
- `publicId`: Template's public UUID

**Request Body** (all fields optional):
```json
{
  "name": "Classic Golden Parchment",
  "description": "Updated description",
  "category": "CLASSIC",
  "backgroundImageUrl": "https://...",
  "thumbnailUrl": "https://...",
  "layoutConfig": {
    "canvas": {"width": 1080, "height": 1920},
    "textArea": {"x": 100, "y": 700, "width": 880, "height": 800},
    "fonts": {
      "urdu": {"family": "Jameel Noori Nastaleeq", "size": 46, "color": "#3E2723"},
      "english": {"family": "Georgia", "size": 24, "color": "#4E342E"}
    },
    "poetImage": {
      "enabled": true,
      "x": 90,
      "y": 90,
      "size": 140,
      "borderColor": "#8D6E63",
      "borderWidth": 4
    },
    "poetInfo": {
      "x": 250,
      "y": 135,
      "nameFont": {"family": "Georgia", "size": 30, "color": "#3E2723", "weight": "bold"}
    },
    "watermark": {
      "enabled": true,
      "text": "Poetry App",
      "x": 880,
      "y": 1860,
      "font": {"size": 18, "color": "#A1887F", "alpha": 0.6}
    },
    "coupletType": {"enabled": true}
  },
  "isPremium": false,
  "isActive": true,
  "displayOrder": 1
}
```

**Request Example**:
```bash
# Update only layoutConfig
curl -X PUT "http://localhost:8080/api/admin/image-poetry/templates/6b03745a-23a9-4b07-b758-f334aed6cecc" \
  -H "Content-Type: application/json" \
  -d '{
    "layoutConfig": {
      "canvas": {"width": 1080, "height": 1920},
      "fonts": {
        "urdu": {"family": "Jameel Noori Nastaleeq", "size": 46, "color": "#3E2723"}
      }
    }
  }'
```

**Response Example**:
```json
{
  "success": true,
  "message": "Template updated successfully",
  "data": {
    "publicId": "6b03745a-23a9-4b07-b758-f334aed6cecc",
    "name": "Classic Golden Parchment",
    "description": "Updated description",
    "category": "CLASSIC",
    "backgroundImageUrl": "https://...",
    "thumbnailUrl": "https://...",
    "layoutConfig": { /* updated layoutConfig */ },
    "isPremium": false,
    "isActive": true,
    "displayOrder": 1,
    "usageCount": 0,
    "createdAt": "2025-12-15T18:30:00.000+00:00",
    "updatedAt": "2025-12-15T19:40:00.000+00:00"
  },
  "timestamp": "2025-12-15T19:40:00.000+00:00"
}
```

---

### 7. Delete Template
Soft delete a template (marks as inactive).

**Endpoint**: `DELETE /api/admin/image-poetry/templates/{publicId}`

**Path Parameters**:
- `publicId`: Template's public UUID

**Request Example**:
```bash
curl -X DELETE "http://localhost:8080/api/admin/image-poetry/templates/6b03745a-23a9-4b07-b758-f334aed6cecc"
```

**Response Example**:
```json
{
  "success": true,
  "message": "Template deleted successfully",
  "data": null,
  "timestamp": "2025-12-15T19:45:00.000+00:00"
}
```

---

### 8. Get All Templates (Including Inactive)
Admin endpoint to get all templates including inactive ones.

**Endpoint**: `GET /api/admin/image-poetry/templates/all`

**Query Parameters**:
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**Request Example**:
```bash
curl -X GET "http://localhost:8080/api/admin/image-poetry/templates/all?page=0&size=20"
```

**Response Example**:
```json
{
  "success": true,
  "message": "All templates retrieved",
  "data": {
    "content": [
      {
        "publicId": "6b03745a-23a9-4b07-b758-f334aed6cecc",
        "name": "Classic Vintage Parchment",
        "isActive": true,
        /* ... */
      },
      {
        "publicId": "abc123...",
        "name": "Deleted Template",
        "isActive": false,
        /* ... */
      }
    ],
    "pageable": { /* ... */ },
    "totalElements": 15,
    "totalPages": 1
  },
  "timestamp": "2025-12-15T19:50:00.000+00:00"
}
```

---

### 9. Bulk Update Template Status
Activate or deactivate multiple templates at once.

**Endpoint**: `POST /api/admin/image-poetry/templates/bulk-status`

**Query Parameters**:
- `templateIds`: List of template public IDs (comma-separated or multiple params)
- `isActive`: Boolean (true to activate, false to deactivate)

**Request Example**:
```bash
curl -X POST "http://localhost:8080/api/admin/image-poetry/templates/bulk-status?isActive=false" \
  -G \
  --data-urlencode "templateIds=6b03745a-23a9-4b07-b758-f334aed6cecc" \
  --data-urlencode "templateIds=9f054040-2647-4097-955c-94849960d41a"
```

**Response Example**:
```json
{
  "success": true,
  "message": "2 templates updated successfully",
  "data": "2 templates updated successfully",
  "timestamp": "2025-12-15T19:55:00.000+00:00"
}
```

---

### 10. Get Template Usage Statistics
Get templates ordered by usage count.

**Endpoint**: `GET /api/admin/image-poetry/analytics/templates`

**Query Parameters**:
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**Request Example**:
```bash
curl -X GET "http://localhost:8080/api/admin/image-poetry/analytics/templates?page=0&size=10"
```

**Response Example**:
```json
{
  "success": true,
  "message": "Template usage stats retrieved",
  "data": {
    "content": [
      {
        "publicId": "9f054040-2647-4097-955c-94849960d41a",
        "name": "Modern Gradient Blue",
        "category": "MODERN",
        "usageCount": 2500,
        /* ... */
      },
      {
        "publicId": "ad37bb12-2a94-432b-b6c4-ef1a95fe81d7",
        "name": "Floral Watercolor Pink",
        "category": "FLORAL",
        "usageCount": 1800,
        /* ... */
      }
    ],
    "totalElements": 10
  },
  "timestamp": "2025-12-15T20:00:00.000+00:00"
}
```

---

## LayoutConfig Schema

The `layoutConfig` field controls how poetry images are generated. Here's the complete schema:

```json
{
  "canvas": {
    "width": 1080,      // Canvas width in pixels (recommended: 1080)
    "height": 1920      // Canvas height in pixels (recommended: 1920 for mobile 9:16)
  },
  "textArea": {
    "x": 100,           // Text area X position (pixels from left)
    "y": 700,           // Text area Y position (pixels from top)
    "width": 880,       // Text area width
    "height": 800       // Text area height
  },
  "fonts": {
    "urdu": {
      "family": "Jameel Noori Nastaleeq",  // Font family for Urdu text
      "size": 46,                          // Font size
      "color": "#3E2723"                   // Hex color code
    },
    "english": {
      "family": "Georgia",  // Font family for English text
      "size": 24,
      "color": "#4E342E"
    }
  },
  "poetImage": {
    "enabled": true,        // Show poet image
    "x": 90,                // X position
    "y": 90,                // Y position
    "size": 140,            // Image diameter (circular)
    "borderColor": "#8D6E63",  // Border color
    "borderWidth": 4        // Border thickness
  },
  "poetInfo": {
    "x": 250,               // Poet name X position
    "y": 135,               // Poet name Y position
    "nameFont": {
      "family": "Georgia",
      "size": 30,
      "color": "#3E2723",
      "weight": "bold"      // Font weight
    }
  },
  "watermark": {
    "enabled": true,
    "text": "Poetry App",
    "x": 880,
    "y": 1860,
    "font": {
      "size": 18,
      "color": "#A1887F",
      "alpha": 0.6          // Transparency (0.0 to 1.0)
    }
  },
  "coupletType": {
    "enabled": true         // Show couplet type label (شعر، غزل، etc.)
  }
}
```

---

## Category-Specific LayoutConfigs

### CLASSIC
```json
{
  "fonts": {
    "urdu": {"family": "Jameel Noori Nastaleeq", "size": 46, "color": "#3E2723"},
    "english": {"family": "Georgia", "size": 24, "color": "#4E342E"}
  },
  "poetImage": {"x": 90, "y": 90, "size": 140, "borderColor": "#8D6E63"}
}
```

### MODERN
```json
{
  "fonts": {
    "urdu": {"family": "Jameel Noori Nastaleeq", "size": 50, "color": "#FFFFFF"},
    "english": {"family": "Montserrat", "size": 26, "color": "#E3F2FD"}
  },
  "poetImage": {"x": 90, "y": 90, "size": 150, "borderColor": "#64B5F6"}
}
```

### FLORAL
```json
{
  "fonts": {
    "urdu": {"family": "Jameel Noori Nastaleeq", "size": 48, "color": "#880E4F"},
    "english": {"family": "Playfair Display", "size": 25, "color": "#AD1457"}
  },
  "poetImage": {"x": 90, "y": 1650, "size": 130, "borderColor": "#F48FB1"}
}
```

### GEOMETRIC
```json
{
  "fonts": {
    "urdu": {"family": "Jameel Noori Nastaleeq", "size": 47, "color": "#1A237E"},
    "english": {"family": "Roboto", "size": 24, "color": "#283593"}
  },
  "poetImage": {"x": 465, "y": 90, "size": 150, "borderColor": "#3F51B5"}
}
```

### MINIMAL
```json
{
  "fonts": {
    "urdu": {"family": "Jameel Noori Nastaleeq", "size": 44, "color": "#5D4037"},
    "english": {"family": "Arial", "size": 22, "color": "#757575"}
  },
  "poetImage": {"x": 90, "y": 1650, "size": 120, "borderColor": "#BCAAA4"},
  "coupletType": {"enabled": false}
}
```

### NATURE
```json
{
  "fonts": {
    "urdu": {"family": "Jameel Noori Nastaleeq", "size": 48, "color": "#1B5E20"},
    "english": {"family": "Georgia", "size": 24, "color": "#2E7D32"}
  },
  "poetImage": {"x": 90, "y": 90, "size": 145, "borderColor": "#66BB6A"}
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error: name is required",
  "data": null,
  "timestamp": "2025-12-15T20:05:00.000+00:00"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Template not found: 6b03745a-23a9-4b07-b758-f334aed6cecc",
  "data": null,
  "timestamp": "2025-12-15T20:05:00.000+00:00"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Failed to upload image to S3",
  "data": null,
  "timestamp": "2025-12-15T20:05:00.000+00:00"
}
```

---

## Notes

1. **Authentication**: Currently, admin endpoints are open for development. Add proper authentication before production.

2. **File Upload Limits**: Max file size is configured in `application.yaml` (typically 5-10MB).

3. **Supported Image Formats**: PNG, JPG, JPEG

4. **CloudFront CDN**: All uploaded images are automatically served via CloudFront for better performance.

5. **Soft Delete**: Templates are never hard-deleted, only marked as `isActive: false`.

6. **Usage Tracking**: The `usageCount` field is automatically incremented when a template is used for image generation.

7. **Display Order**: Templates with lower `displayOrder` values appear first in listings.
