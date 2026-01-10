# Plantify Backend API

Backend API for the Plantify mobile application built with Node.js, Express, TypeScript, and MongoDB.

## Features

- **Authentication**: Email/password and Google OAuth authentication
- **JWT Tokens**: Secure access and refresh token system
- **Plants Management**: CRUD operations for plant tracking
- **Water Reminders**: Track watering schedules for plants
- **Security**: Rate limiting, CORS, Helmet security headers
- **TypeScript**: Full type safety throughout the codebase

## Tech Stack

- **Runtime**: Node.js 20
- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT, Google OAuth 2.0
- **Security**: bcrypt, Helmet, CORS, Rate Limiting

## Prerequisites

- Node.js 20 or higher
- MongoDB (local or MongoDB Atlas)
- npm or yarn

## Installation

1. Clone the repository and navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the backend directory:
```bash
cp .env.example .env
```

4. Update the `.env` file with your configuration:
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/plantify
JWT_SECRET=your-secret-key-here
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
CORS_ORIGIN=http://localhost:3000
```

## Running the Application

### Development Mode

```bash
npm run dev
```

The server will start on `http://localhost:5000` with hot-reload enabled.

### Production Mode

1. Build the TypeScript code:
```bash
npm run build
```

2. Start the server:
```bash
npm start
```

## API Documentation

### Swagger UI

Once the server is running, you can access the interactive Swagger documentation at:

**http://localhost:5000/api-docs**

The Swagger UI provides:
- Interactive API documentation
- Try-it-out functionality to test endpoints
- Request/response schemas
- Authentication support (click "Authorize" button to add JWT token)

### API Specification

Complete API documentation is also available in [docs/backend-specification.md](./docs/backend-specification.md).

### Quick Start - API Endpoints

**Authentication:**
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login with email/password
- `POST /api/auth/google` - Google OAuth authentication
- `POST /api/auth/refresh` - Refresh access token
- `GET /api/auth/me` - Get current user (protected)
- `POST /api/auth/logout` - Logout (protected)

**Plants:**
- `GET /api/plants` - Get all user's plants (protected)
- `GET /api/plants/:id` - Get plant by ID (protected)
- `POST /api/plants` - Create new plant (protected)
- `PUT /api/plants/:id` - Update plant (protected)
- `DELETE /api/plants/:id` - Delete plant (protected)
- `POST /api/plants/:id/water` - Mark plant as watered (protected)

## Project Structure

```
backend/
├── src/
│   ├── config/          # Configuration files
│   ├── controllers/     # Route controllers
│   ├── services/        # Business logic
│   ├── models/          # MongoDB models
│   ├── routes/          # API routes
│   ├── middleware/      # Custom middleware
│   ├── utils/           # Utility functions
│   ├── types/           # TypeScript types
│   ├── app.ts           # Express app setup
│   └── server.ts        # Server entry point
├── docs/                # Documentation
├── dist/                # Compiled JavaScript (generated)
└── package.json
```

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `PORT` | Server port | No | 5000 |
| `NODE_ENV` | Environment | No | development |
| `MONGODB_URI` | MongoDB connection string | Yes | - |
| `JWT_SECRET` | JWT signing secret | Yes | - |
| `JWT_ACCESS_EXPIRY` | Access token expiry | No | 15m |
| `JWT_REFRESH_EXPIRY` | Refresh token expiry | No | 7d |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID | Yes | - |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret | Yes | - |
| `CORS_ORIGIN` | Allowed CORS origin | No | http://localhost:3000 |

## Database Setup

### Local MongoDB

1. Install MongoDB locally
2. Start MongoDB service
3. Update `MONGODB_URI` in `.env`:
```env
MONGODB_URI=mongodb://localhost:27017/plantify
```

### MongoDB Atlas

1. Create a MongoDB Atlas account
2. Create a new cluster
3. Create a database user
4. Whitelist IP addresses (use `0.0.0.0/0` for Render)
5. Get connection string and update `MONGODB_URI` in `.env`:
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/plantify?retryWrites=true&w=majority
```

## Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs
6. Copy Client ID and Client Secret to `.env`

## Deployment

### Render Deployment

The backend is configured for deployment on Render using Docker.

1. Push your code to GitHub
2. Create a new Web Service on Render
3. Connect your GitHub repository
4. Set the following:
   - **Build Command**: (handled by Dockerfile)
   - **Start Command**: (handled by Dockerfile)
   - **Dockerfile Path**: `backend/Dockerfile`
   - **Docker Context**: `backend`
5. Add environment variables in Render dashboard
6. Deploy

See `render.yaml` for service configuration.

## Security

- Passwords are hashed using bcrypt with 10 salt rounds
- JWT tokens are signed and have expiration times
- CORS is configured to allow requests only from authorized origins
- Rate limiting prevents abuse (5 requests/15min for auth, 100 requests/15min for others)
- Helmet sets security headers
- Input validation using express-validator

## Logging

The application uses custom logging middleware. All logs follow the format:
```
([LOG log_name] ========= message)
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

## Development

### Scripts

- `npm run dev` - Start development server with hot-reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run lint` - Run ESLint

### Code Style

- TypeScript strict mode enabled
- ESLint for code quality
- Consistent error handling
- Logging at important points

## License

ISC

## Support

For issues or questions, please refer to the [API Documentation](./docs/backend-specification.md) or contact the development team.

