# Backend API Specification for Plantify Mobile App

## Overview

This document provides comprehensive documentation for the Plantify backend API. The backend is built with Node.js, Express, TypeScript, and MongoDB, designed to support the Plantify mobile application.

## Base URL

```
Production: https://your-app-name.onrender.com
Development: http://localhost:5000
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. Most endpoints require a valid access token in the Authorization header.

### Authentication Flow

```mermaid
sequenceDiagram
    participant Client as Mobile App
    participant API as Backend API
    participant DB as MongoDB
    participant Google as Google OAuth

    Note over Client,Google: Email/Password Flow
    Client->>API: POST /api/auth/register
    API->>DB: Create user
    DB-->>API: User created
    API-->>Client: Access + Refresh tokens

    Client->>API: POST /api/auth/login
    API->>DB: Verify credentials
    DB-->>API: User verified
    API-->>Client: Access + Refresh tokens

    Note over Client,Google: Google OAuth Flow
    Client->>API: POST /api/auth/google
    API->>Google: Verify Google token
    Google-->>API: User info
    API->>DB: Find or create user
    DB-->>API: User data
    API-->>Client: Access + Refresh tokens

    Note over Client,Google: Token Refresh Flow
    Client->>API: POST /api/auth/refresh
    API->>DB: Verify refresh token
    DB-->>API: Token valid
    API-->>Client: New access token
```

### Token Structure

- **Access Token**: Short-lived (15 minutes), used for API requests
- **Refresh Token**: Long-lived (7 days), used to obtain new access tokens

Tokens are sent in the Authorization header:
```
Authorization: Bearer <access_token>
```

## API Endpoints

### Authentication Endpoints

#### Register User

Register a new user with email and password.

**Endpoint:** `POST /api/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "name": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "name": "John Doe"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**
- `400 Bad Request`: Invalid input or email already exists
- `500 Internal Server Error`: Server error

#### Login

Authenticate user with email and password.

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "name": "John Doe"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid credentials
- `400 Bad Request`: Missing email or password

#### Google OAuth Authentication

Authenticate or register user using Google OAuth token.

**Endpoint:** `POST /api/auth/google`

**Request Body:**
```json
{
  "token": "google_oauth_token_from_mobile_app"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@gmail.com",
      "name": "John Doe",
      "googleId": "123456789"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid Google token
- `400 Bad Request`: Missing token

#### Refresh Access Token

Get a new access token using a refresh token.

**Endpoint:** `POST /api/auth/refresh`

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid or expired refresh token

#### Get Current User

Get the authenticated user's profile.

**Endpoint:** `GET /api/auth/me`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "name": "John Doe",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid or missing token

#### Logout

Invalidate refresh token (logout).

**Endpoint:** `POST /api/auth/logout`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### Plants Endpoints

All plants endpoints require authentication.

#### Get All Plants

Get all plants for the authenticated user.

**Endpoint:** `GET /api/plants`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "plants": [
      {
        "id": "507f1f77bcf86cd799439012",
        "name": "Monstera Deliciosa",
        "type": "Indoor",
        "careInstructions": "Water weekly, indirect sunlight",
        "lastWatered": "2024-01-15T10:00:00.000Z",
        "nextWatering": "2024-01-22T10:00:00.000Z",
        "imageUrl": "https://example.com/image.jpg",
        "createdAt": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

#### Get Plant by ID

Get a specific plant by ID.

**Endpoint:** `GET /api/plants/:id`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "plant": {
      "id": "507f1f77bcf86cd799439012",
      "name": "Monstera Deliciosa",
      "type": "Indoor",
      "careInstructions": "Water weekly, indirect sunlight",
      "lastWatered": "2024-01-15T10:00:00.000Z",
      "nextWatering": "2024-01-22T10:00:00.000Z",
      "imageUrl": "https://example.com/image.jpg",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

**Error Responses:**
- `404 Not Found`: Plant not found
- `403 Forbidden`: Plant belongs to another user

#### Create Plant

Create a new plant for the authenticated user.

**Endpoint:** `POST /api/plants`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "name": "Monstera Deliciosa",
  "type": "Indoor",
  "careInstructions": "Water weekly, indirect sunlight",
  "wateringFrequency": 7,
  "imageUrl": "https://example.com/image.jpg"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "plant": {
      "id": "507f1f77bcf86cd799439012",
      "name": "Monstera Deliciosa",
      "type": "Indoor",
      "careInstructions": "Water weekly, indirect sunlight",
      "wateringFrequency": 7,
      "lastWatered": null,
      "nextWatering": null,
      "imageUrl": "https://example.com/image.jpg",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

**Error Responses:**
- `400 Bad Request`: Invalid input
- `500 Internal Server Error`: Server error

#### Update Plant

Update an existing plant.

**Endpoint:** `PUT /api/plants/:id`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "name": "Updated Plant Name",
  "careInstructions": "Updated care instructions",
  "wateringFrequency": 5
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "plant": {
      "id": "507f1f77bcf86cd799439012",
      "name": "Updated Plant Name",
      "type": "Indoor",
      "careInstructions": "Updated care instructions",
      "wateringFrequency": 5,
      "lastWatered": "2024-01-15T10:00:00.000Z",
      "nextWatering": "2024-01-20T10:00:00.000Z",
      "imageUrl": "https://example.com/image.jpg",
      "updatedAt": "2024-01-16T00:00:00.000Z"
    }
  }
}
```

**Error Responses:**
- `404 Not Found`: Plant not found
- `403 Forbidden`: Plant belongs to another user
- `400 Bad Request`: Invalid input

#### Delete Plant

Delete a plant.

**Endpoint:** `DELETE /api/plants/:id`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Plant deleted successfully"
}
```

**Error Responses:**
- `404 Not Found`: Plant not found
- `403 Forbidden`: Plant belongs to another user

#### Water Plant

Mark a plant as watered and update the next watering date.

**Endpoint:** `POST /api/plants/:id/water`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "plant": {
      "id": "507f1f77bcf86cd799439012",
      "name": "Monstera Deliciosa",
      "lastWatered": "2024-01-16T10:00:00.000Z",
      "nextWatering": "2024-01-23T10:00:00.000Z"
    }
  }
}
```

**Error Responses:**
- `404 Not Found`: Plant not found
- `403 Forbidden`: Plant belongs to another user

## Database Schema

### User Model

```typescript
{
  _id: ObjectId,
  email: String (required, unique, lowercase),
  password: String (hashed, required if not Google user),
  name: String (required),
  googleId: String (optional, unique),
  refreshTokens: [String] (array of refresh tokens),
  createdAt: Date,
  updatedAt: Date
}
```

### Plant Model

```typescript
{
  _id: ObjectId,
  userId: ObjectId (reference to User, required),
  name: String (required),
  type: String (required),
  careInstructions: String,
  wateringFrequency: Number (days, default: 7),
  lastWatered: Date,
  nextWatering: Date (calculated),
  imageUrl: String,
  createdAt: Date,
  updatedAt: Date
}
```

## Error Handling

All errors follow a consistent format:

```json
{
  "success": false,
  "error": {
    "message": "Error message",
    "code": "ERROR_CODE"
  }
}
```

### Common Error Codes

- `VALIDATION_ERROR`: Input validation failed
- `UNAUTHORIZED`: Authentication required or failed
- `FORBIDDEN`: Access denied
- `NOT_FOUND`: Resource not found
- `DUPLICATE_ENTRY`: Resource already exists
- `INTERNAL_ERROR`: Server error

### HTTP Status Codes

- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Environment Variables

Required environment variables:

```env
# Server
PORT=5000
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb://localhost:27017/plantify
# Or for MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/plantify

# JWT
JWT_SECRET=your-secret-key-here
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# CORS
CORS_ORIGIN=http://localhost:3000
```

## Rate Limiting

API endpoints are rate-limited to prevent abuse:
- Authentication endpoints: 5 requests per 15 minutes per IP
- Other endpoints: 100 requests per 15 minutes per IP

## Security Considerations

1. **Password Hashing**: Passwords are hashed using bcrypt with salt rounds of 10
2. **JWT Tokens**: Tokens are signed with a secret key and have expiration times
3. **CORS**: Configured to allow requests only from authorized origins
4. **Input Validation**: All inputs are validated using express-validator
5. **Helmet**: Security headers are set using Helmet middleware
6. **HTTPS**: Production API should always use HTTPS

## Deployment

### Render Deployment

The backend is configured for deployment on Render using Docker.

1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Set environment variables in Render dashboard
4. Deploy

See `render.yaml` for service configuration.

### MongoDB Atlas Setup

1. Create a MongoDB Atlas account
2. Create a new cluster
3. Create a database user
4. Whitelist IP addresses (or use 0.0.0.0/0 for Render)
5. Get connection string and set `MONGODB_URI`

## Testing

### Manual Testing with cURL

**Register:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!","name":"Test User"}'
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

**Get Plants:**
```bash
curl -X GET http://localhost:5000/api/plants \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Support

For issues or questions, please contact the development team or create an issue in the repository.

