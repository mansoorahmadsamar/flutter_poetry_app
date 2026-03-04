# Production Usage Guide - Poetry Backend API

Complete guide for developers to use and interact with the Production Poetry Backend deployment.

## 🌐 Production Environment

### Server Details
```
Server IP:      134.199.243.167
Base URL:       https://134.199.243.167 (SSL)
HTTP URL:       http://134.199.243.167:3000
Environment:    Production (prod profile)
Region:         Digital Ocean - NYC3
```

### Service Endpoints
```
API:            https://134.199.243.167/api/*
Health Check:   https://134.199.243.167/api/health
Actuator:       https://134.199.243.167/actuator/health
Admin Portal:   https://134.199.243.167/admin/*
```

---

## 🔐 Authentication

### Firebase Authentication
The API uses Firebase Authentication for user authentication.

**Headers Required:**
```http
Authorization: Bearer <firebase-id-token>
```

**How to Get Token:**
1. Authenticate with Firebase (mobile/web app)
2. Get the ID token from Firebase
3. Include in Authorization header

**Example:**
```bash
curl -H "Authorization: Bearer eyJhbGc..." \
  https://134.199.243.167/api/poems
```

### Admin Authentication
Admin endpoints require SUPER_ADMIN role.

**Login Endpoint:**
```http
POST /api/auth/admin/login
Content-Type: application/json

{
  "email": "admin@system.com",
  "password": "your-admin-password"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzM4NCJ9...",
  "refreshToken": "refresh-token-here",
  "expiresIn": 8640000000
}
```

**Use Admin Token:**
```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzM4NCJ9..." \
  https://134.199.243.167/admin/users
```

---

## 📊 Database Access

### PostgreSQL Connection

**Connection Details:**
```
Host:       134.199.243.167
Port:       5432
Database:   poetry-db
Username:   postgres
Password:   (contact DevOps for credentials)
SSL:        Disabled
```

**Connection String:**
```
jdbc:postgresql://134.199.243.167:5432/poetry-db
```

**Using psql CLI:**
```bash
psql -h 134.199.243.167 -p 5432 -U postgres -d poetry-db
```

**Using DBeaver/DataGrip:**
1. New Connection → PostgreSQL
2. Host: `134.199.243.167`
3. Port: `5432`
4. Database: `poetry-db`
5. Username: `postgres`
6. Password: (from credentials)

**Via SSH Tunnel (Recommended):**
```bash
ssh -i ~/.ssh/id_ed25519 -L 5432:localhost:5432 root@134.199.243.167

# Then connect to localhost:5432
psql -h localhost -p 5432 -U postgres -d poetry-db
```

---

## 🔍 Elasticsearch Access

**Connection Details:**
```
Internal URL:   http://elasticsearch:9200 (from backend container)
Not exposed:    Elasticsearch is not accessible from outside
```

**Access via Backend Container:**
```bash
# SSH to server
ssh -i ~/.ssh/id_ed25519 root@134.199.243.167

# Access Elasticsearch
docker exec -it poetry-backend curl http://elasticsearch:9200/_cluster/health
```

**Admin Endpoints (via API):**
```bash
# Reindex all data
POST /admin/elasticsearch/reindex-all

# Check indices
GET /admin/elasticsearch/indices
```

---

## 📱 API Endpoints Reference

### Public Endpoints (No Auth Required)

#### Health Check
```bash
# Custom health endpoint
curl https://134.199.243.167/api/health

# Actuator health
curl https://134.199.243.167/actuator/health
```

#### Public Poems
```bash
# Get all poems (paginated)
GET /api/poems?page=0&size=20

# Get poem by ID
GET /api/poems/{id}

# Search poems
GET /api/search/poems?query=محبت&language=URDU
```

#### Public Poets
```bash
# Get all poets
GET /api/poets?page=0&size=20

# Get poet by ID
GET /api/poets/{id}

# Get poet with details
GET /api/poets/{id}/profile
```

### Authenticated Endpoints

#### Bookmarks
```bash
# Get user bookmarks
GET /api/bookmarks
Authorization: Bearer <token>

# Add bookmark
POST /api/bookmarks/poem/{poemId}
Authorization: Bearer <token>

# Remove bookmark
DELETE /api/bookmarks/{bookmarkId}
Authorization: Bearer <token>
```

#### Likes
```bash
# Like a poem
POST /api/likes/poem/{poemId}
Authorization: Bearer <token>

# Get user likes
GET /api/likes/user
Authorization: Bearer <token>
```

#### User Profile
```bash
# Get current user
GET /api/users/me
Authorization: Bearer <token>

# Update profile
PUT /api/users/me
Authorization: Bearer <token>
Content-Type: application/json

{
  "displayName": "John Doe",
  "bio": "Poetry lover"
}
```

### Admin Endpoints

All admin endpoints require `Authorization: Bearer <admin-token>`

#### User Management
```bash
# Get all users
GET /admin/users?page=0&size=20

# Get user by ID
GET /admin/users/{id}

# Update user
PUT /admin/users/{id}

# Delete user
DELETE /admin/users/{id}
```

#### Poet Management
```bash
# Create poet
POST /admin/poets

# Update poet
PUT /admin/poets/{id}

# Delete poet
DELETE /admin/poets/{id}
```

#### Category Management
```bash
# Get all categories
GET /admin/categories

# Create category
POST /admin/categories

# Update category
PUT /admin/categories/{id}
```

#### Language Management
```bash
# Get all languages
GET /admin/languages

# Create language
POST /admin/languages

# Update language
PUT /admin/languages/{id}
```

---

## 🧪 Testing with cURL

### Example: Get Poems
```bash
curl -X GET "https://134.199.243.167/api/poems?page=0&size=5" \
  -H "Accept: application/json" \
  | jq .
```

### Example: Search
```bash
curl -X GET "https://134.199.243.167/api/search?query=love&type=POEM" \
  -H "Accept: application/json" \
  | jq .
```

### Example: Get Poet Profile
```bash
curl -X GET "https://134.199.243.167/api/poets/1/profile" \
  -H "Accept: application/json" \
  | jq .
```

### Example: Admin Login
```bash
# Login
TOKEN=$(curl -X POST "https://134.199.243.167/api/auth/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@system.com","password":"your-password"}' \
  | jq -r '.token')

# Use token
curl -X GET "https://134.199.243.167/admin/users" \
  -H "Authorization: Bearer $TOKEN" \
  | jq .
```

---

## 📮 Postman Collection

### Import Production Environment

1. **Create Environment:**
   - Name: `Poetry Backend - Production`
   - Variables:
     ```
     base_url:        https://134.199.243.167
     admin_token:     {{admin_token}}
     user_token:      {{user_token}}
     ```

2. **Import Collection:**
   - See `FLUTTER_API_DOCUMENTATION.md` for complete endpoint list
   - Update all `{{base_url}}` variables to production

### Pre-request Scripts

**Auto-refresh token:**
```javascript
// In Pre-request Script for Admin endpoints
const tokenExpiry = pm.environment.get("token_expiry");
if (!tokenExpiry || Date.now() > tokenExpiry) {
  pm.sendRequest({
    url: pm.environment.get("base_url") + "/api/auth/admin/login",
    method: "POST",
    header: {"Content-Type": "application/json"},
    body: {
      mode: "raw",
      raw: JSON.stringify({
        email: "admin@system.com",
        password: "your-password"
      })
    }
  }, function(err, res) {
    const token = res.json().token;
    pm.environment.set("admin_token", token);
    pm.environment.set("token_expiry", Date.now() + 8640000000);
  });
}
```

---

## 📊 Monitoring & Logs

### View Application Logs
```bash
# SSH to server
ssh -i ~/.ssh/id_ed25519 root@134.199.243.167

# View backend logs (real-time)
docker logs -f poetry-backend

# View last 100 lines
docker logs --tail 100 poetry-backend

# View logs with timestamps
docker logs -f --timestamps poetry-backend

# Search logs for errors
docker logs poetry-backend 2>&1 | grep -i error
```

### View Nginx Logs
```bash
# Access logs
docker logs poetry-nginx

# Or from mounted volume
tail -f /opt/poetry-app/nginx/logs/access.log
tail -f /opt/poetry-app/nginx/logs/error.log
```

### Check Service Status
```bash
# All containers
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# Specific service
docker ps --filter name=poetry-backend

# Resource usage
docker stats poetry-backend
```

### Health Monitoring
```bash
# Check all services
curl https://134.199.243.167/actuator/health | jq .

# Check database connection
docker exec poetry-postgres pg_isready -U postgres

# Check Elasticsearch
docker exec poetry-backend curl http://elasticsearch:9200/_cluster/health | jq .
```

---

## 🚀 Common Operations

### Restart Services
```bash
# Restart backend only
cd /opt/poetry-app
docker compose -f docker-compose.production.yml restart backend

# Restart all services
docker compose -f docker-compose.production.yml restart

# View restart status
docker ps
```

### View Environment Variables
```bash
# Backend environment
docker exec poetry-backend env | grep -E 'DB_|ELASTIC|SPRING'

# Full config
docker inspect poetry-backend | jq '.[0].Config.Env'
```

### Database Operations
```bash
# Run SQL query
docker exec poetry-postgres psql -U postgres -d poetry-db -c "SELECT COUNT(*) FROM poems;"

# Backup database
docker exec poetry-postgres pg_dump -U postgres poetry-db > backup.sql

# List all tables
docker exec poetry-postgres psql -U postgres -d poetry-db -c "\dt"
```

### Clear Cache/Restart Fresh
```bash
# Stop backend
docker compose -f docker-compose.production.yml stop backend

# Clear any cached data (if applicable)
docker exec poetry-backend rm -rf /tmp/*

# Start backend
docker compose -f docker-compose.production.yml start backend
```

---

## 🔧 Troubleshooting

### Issue: Cannot Connect to API
```bash
# Check if services are running
docker ps | grep poetry

# Check backend logs
docker logs poetry-backend --tail 50

# Check nginx
docker logs poetry-nginx --tail 50

# Test direct connection (bypass nginx)
curl http://134.199.243.167:3000/api/health
```

### Issue: 401 Unauthorized
```bash
# Verify token is valid
# Check token expiration (JWT tokens expire after 100 days by default)

# For admin: Login again to get new token
curl -X POST "https://134.199.243.167/api/auth/admin/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@system.com","password":"your-password"}'
```

### Issue: Slow Responses
```bash
# Check system resources
docker stats

# Check database connections
docker exec poetry-postgres psql -U postgres -d poetry-db \
  -c "SELECT count(*) FROM pg_stat_activity;"

# Check Elasticsearch health
docker exec poetry-backend curl http://elasticsearch:9200/_cluster/health
```

### Issue: Database Connection Error
```bash
# Verify PostgreSQL is running
docker ps | grep postgres

# Check PostgreSQL logs
docker logs poetry-postgres --tail 50

# Test connection from backend
docker exec poetry-backend psql -h postgres -U postgres -d poetry-db -c "SELECT 1;"
```

---

## 📞 Support & Contacts

**Infrastructure Issues:**
- Server access, deployment, Docker issues
- Contact: DevOps Team

**API Issues:**
- Endpoint errors, authentication problems
- Contact: Backend Team
- Check: `docker logs poetry-backend`

**Database Issues:**
- Data inconsistencies, migrations
- Contact: Backend Team / DBA
- Check: Database logs

**Emergency:**
- Service down, critical issues
- Rollback: See deployment team
- Check: GitHub Actions deployment logs

---

## 📚 Additional Documentation

- **API Endpoints:** See `FLUTTER_API_DOCUMENTATION.md`
- **Admin Portal:** See `ADMIN_PORTAL_DOCUMENTATION.md`
- **Deployment:** See `PRODUCTION_DEPLOYMENT.md`
- **Couplet API:** See `COUPLET_API_DOCUMENTATION.md`
- **Search API:** See `TEMPLATE_SEARCH_API_GUIDE.md`
- **Image Poetry:** See `IMAGE_POETRY_DOCUMENTATION.md`

---

## 🔒 Security Notes

1. **Never commit credentials** to Git
2. **Use environment variables** for all secrets
3. **Rotate tokens** regularly (especially admin tokens)
4. **Use HTTPS** for all production API calls
5. **Monitor access logs** for suspicious activity
6. **Keep dependencies updated** via GitHub Actions
7. **Backup database** regularly (automated daily)

---

## ⚡ Quick Reference

```bash
# SSH to server
ssh -i ~/.ssh/id_ed25519 root@134.199.243.167

# View logs
docker logs -f poetry-backend

# Restart backend
cd /opt/poetry-app && docker compose -f docker-compose.production.yml restart backend

# Check health
curl https://134.199.243.167/api/health

# Database access
docker exec -it poetry-postgres psql -U postgres -d poetry-db

# List all containers
docker ps --format 'table {{.Names}}\t{{.Status}}'
```

---

**Last Updated:** 2026-01-13  
**Environment:** Production  
**Version:** Latest (auto-deployed via GitHub Actions)
