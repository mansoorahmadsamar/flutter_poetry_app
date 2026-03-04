# Backend Database Migration Required - Bookmark Language Support

## Issue Summary

The Flutter app is experiencing **500 Internal Server Error** when users attempt to bookmark poems, couplets, or images. This is caused by a missing database column that the backend code expects.

### Error Details

**Status:** 500 Internal Server Error
**Error Message:** `column b1_0.language_code does not exist`
**Affected Endpoints:**
- `POST /api/poems/{poemId}/bookmark?lang={lang}`
- `POST /api/couplets/{coupletId}/bookmark?lang={lang}`
- `POST /api/poetry-images/{imageId}/bookmark?lang={lang}`

**SQL Error:**
```
ERROR: column b1_0.language_code does not exist
Hint: Perhaps you meant to reference the column "b1_0.poem_id" or "b1_0.user_id".
```

---

## Root Cause

The backend API correctly accepts the `lang` query parameter (e.g., `?lang=ur`, `?lang=en`, `?lang=hi`) and attempts to store it in the database to preserve language context for bookmarks. However, the database schema for the bookmark tables is missing the `language_code` column.

### Current Behavior
1. ✅ Flutter app sends `POST /api/poems/poem_xyz/bookmark?lang=ur`
2. ✅ Backend receives the request and extracts `lang=ur`
3. ❌ Backend tries to INSERT into `bookmarks` table with `language_code='ur'`
4. ❌ Database rejects the query because column doesn't exist
5. ❌ User sees "Failed to bookmark" error

---

## Required Database Changes

### Tables Affected
The following tables need the `language_code` column added:

1. **`bookmarks`** - Poem bookmarks
2. **`couplet_bookmarks`** - Couplet bookmarks
3. **`image_bookmarks`** - Image bookmarks

---

## Migration SQL

### PostgreSQL Migration Script

```sql
-- Migration: Add language_code column to bookmark tables
-- Date: 2026-01-01
-- Issue: Missing language_code column causing 500 errors

BEGIN;

-- 1. Add language_code column to bookmarks table (poem bookmarks)
ALTER TABLE bookmarks
ADD COLUMN language_code VARCHAR(10) DEFAULT 'ur' NOT NULL;

-- Add index for filtering by language
CREATE INDEX idx_bookmarks_language_code
ON bookmarks(language_code);

-- Add comment for documentation
COMMENT ON COLUMN bookmarks.language_code IS
'Language code (ur/en/hi) in which the poem was bookmarked. Preserves language context for display.';

-- 2. Add language_code column to couplet_bookmarks table
ALTER TABLE couplet_bookmarks
ADD COLUMN language_code VARCHAR(10) DEFAULT 'ur' NOT NULL;

-- Add index for filtering by language
CREATE INDEX idx_couplet_bookmarks_language_code
ON couplet_bookmarks(language_code);

-- Add comment for documentation
COMMENT ON COLUMN couplet_bookmarks.language_code IS
'Language code (ur/en/hi) in which the couplet was bookmarked. Preserves language context for display.';

-- 3. Add language_code column to image_bookmarks table
ALTER TABLE image_bookmarks
ADD COLUMN language_code VARCHAR(10) DEFAULT 'ur' NOT NULL;

-- Add index for filtering by language
CREATE INDEX idx_image_bookmarks_language_code
ON image_bookmarks(language_code);

-- Add comment for documentation
COMMENT ON COLUMN image_bookmarks.language_code IS
'Language code (ur/en/hi) in which the image was bookmarked. Preserves language context for display.';

COMMIT;
```

### Rollback Script (if needed)

```sql
-- Rollback: Remove language_code column from bookmark tables

BEGIN;

-- Remove indexes
DROP INDEX IF EXISTS idx_bookmarks_language_code;
DROP INDEX IF EXISTS idx_couplet_bookmarks_language_code;
DROP INDEX IF EXISTS idx_image_bookmarks_language_code;

-- Remove columns
ALTER TABLE bookmarks DROP COLUMN IF EXISTS language_code;
ALTER TABLE couplet_bookmarks DROP COLUMN IF EXISTS language_code;
ALTER TABLE image_bookmarks DROP COLUMN IF EXISTS language_code;

COMMIT;
```

---

## Column Specifications

### `language_code` Column Details

| Property | Value |
|----------|-------|
| **Type** | `VARCHAR(10)` |
| **Nullable** | `NOT NULL` |
| **Default** | `'ur'` (Urdu) |
| **Allowed Values** | `'ur'`, `'en'`, `'hi'` (Urdu, English, Hindi) |
| **Purpose** | Store the language context in which content was bookmarked |
| **Index** | Yes - for efficient filtering by language |

### Why This Column Exists

The `language_code` column preserves the **language context** in which users bookmark content. This enables:

1. **Mixed-Language Bookmarks**: A user can bookmark some poems in Urdu and others in English. Each bookmark remembers its original language.

2. **Language Filtering**: Users can filter their bookmarks by language:
   - `GET /api/users/me/bookmarks?lang=ur` → Only Urdu bookmarks
   - `GET /api/users/me/bookmarks?lang=en` → Only English bookmarks
   - `GET /api/users/me/bookmarks` → All bookmarks (mixed languages)

3. **Better UX**: When displaying bookmarks, the app can show each bookmark in the language it was originally bookmarked in, regardless of the current app language.

**Example Workflow:**
1. User switches app to Urdu (`lang=ur`)
2. User bookmarks a poem → Stored with `language_code='ur'`
3. User switches app to English (`lang=en`)
4. User bookmarks another poem → Stored with `language_code='en'`
5. Bookmarks screen shows both poems in their original languages

---

## Verification Steps

After running the migration, verify the changes:

### 1. Check Column Exists
```sql
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_name IN ('bookmarks', 'couplet_bookmarks', 'image_bookmarks')
  AND column_name = 'language_code';
```

Expected output:
```
table_name          | column_name   | data_type      | column_default | is_nullable
--------------------|---------------|----------------|----------------|------------
bookmarks           | language_code | character varying | 'ur'::character varying | NO
couplet_bookmarks   | language_code | character varying | 'ur'::character varying | NO
image_bookmarks     | language_code | character varying | 'ur'::character varying | NO
```

### 2. Check Indexes Exist
```sql
SELECT indexname, tablename, indexdef
FROM pg_indexes
WHERE indexname LIKE '%language_code%';
```

### 3. Test Bookmark Creation
```bash
# Test poem bookmark with Urdu language
curl -X POST "http://localhost:8080/api/poems/poem_abc123/bookmark?lang=ur" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Verify the bookmark was created with correct language_code
SELECT * FROM bookmarks WHERE user_id = YOUR_USER_ID ORDER BY created_at DESC LIMIT 1;
```

---

## Impact Analysis

### Before Migration
- ❌ All bookmark requests fail with 500 error
- ❌ Users cannot save poems, couplets, or images
- ❌ Critical feature completely broken

### After Migration
- ✅ Bookmark requests succeed
- ✅ Language context preserved for each bookmark
- ✅ Users can filter bookmarks by language
- ✅ Mixed-language bookmarks display correctly

### Data Impact
- **Existing Bookmarks:** If any exist (created before language feature), they will have `language_code='ur'` due to the default value
- **New Bookmarks:** Will use the language passed in the API request
- **No Data Loss:** Migration is purely additive (adding columns, not removing)

---

## Timeline & Priority

**Priority:** 🔴 **CRITICAL**
**Impact:** Bookmark feature completely broken
**Affected Users:** All users attempting to bookmark content
**Recommended Timeline:** Deploy immediately

---

## Testing Checklist

After deployment, verify:

- [ ] Poem bookmark with `?lang=ur` succeeds
- [ ] Poem bookmark with `?lang=en` succeeds
- [ ] Poem bookmark with `?lang=hi` succeeds
- [ ] Couplet bookmark with language parameter succeeds
- [ ] Image bookmark with language parameter succeeds
- [ ] Fetching bookmarks without language filter returns all bookmarks
- [ ] Fetching bookmarks with `?lang=ur` returns only Urdu bookmarks
- [ ] Existing bookmarks (if any) still display correctly
- [ ] No 500 errors in backend logs for bookmark endpoints

---

## Related Documentation

- **API Documentation:** See FLUTTER_API_DOCUMENTATION.md Section 14.5 (Multi-Language Support)
- **Bookmark Endpoints:**
  - Poem Bookmarks: `POST /api/poems/{id}/bookmark?lang={lang}`
  - Couplet Bookmarks: `POST /api/couplets/{id}/bookmark?lang={lang}`
  - Image Bookmarks: `POST /api/poetry-images/{id}/bookmark?lang={lang}`

---

## Contact

If you have questions about this migration or the language context feature, please contact the mobile development team.

**Prepared by:** Flutter Development Team
**Date:** 2026-01-01
**Issue Reference:** Bookmark 500 Error - Missing language_code column
