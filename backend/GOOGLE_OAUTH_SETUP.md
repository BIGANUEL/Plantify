# Google OAuth Setup Guide

This guide will walk you through setting up Google OAuth for your backend.

## Prerequisites

- A Google account
- Access to [Google Cloud Console](https://console.cloud.google.com/)

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click **"New Project"**
4. Enter a project name (e.g., "Plantify App")
5. Click **"Create"**

## Step 2: Enable Google+ API

1. In your Google Cloud project, go to **"APIs & Services"** > **"Library"**
2. Search for **"Google+ API"** or **"Google Identity Services API"**
3. Click on it and click **"Enable"**

**Note:** Google+ API is deprecated. You should use **"Google Identity Services API"** instead. However, the `google-auth-library` package works with both.

## Step 3: Configure OAuth Consent Screen

1. Go to **"APIs & Services"** > **"OAuth consent screen"**
2. Choose **"External"** (unless you have a Google Workspace)
3. Fill in the required fields:
   - **App name**: Your app name (e.g., "Plantify" or "Plant Companion")
   - **User support email**: Your email
   - **Developer contact information**: Your email
4. For **Application homepage URL**, you have a few options:
   
   **Option 1: Verify your domain (Recommended for production)**
   - Use: `https://plantify-2-fre0.onrender.com`
   - If Google says "Missing domain", you need to verify domain ownership:
     1. Go to [Google Search Console](https://search.google.com/search-console)
     2. Add property: `plantify-2-fre0.onrender.com`
     3. Verify ownership using one of the methods (HTML file, DNS record, etc.)
     4. Once verified, return to OAuth consent screen and use the URL
   
   **Option 2: Use a placeholder URL (Quick setup for development)**
   - Use: `https://example.com` or `https://your-app-name.com`
   - This is just for identification - it won't affect your mobile app OAuth flow
   - You can change it later after verifying your actual domain
   
   **Option 3: Use your GitHub Pages or other verified domain**
   - If you have a GitHub Pages site or other verified domain, use that
   - Example: `https://yourusername.github.io`
   
   **Important Notes:**
   - ❌ Cannot use: `http://localhost:5000` (Google rejects localhost)
   - This URL is mainly for identification in Google's system
   - For mobile apps, the actual OAuth flow happens in the mobile app, not via redirects
   - Your backend API will work fine regardless of what URL you put here
5. Click **"Save and Continue"**
6. Add scopes (you can skip this for now or add `email` and `profile`)
7. Add test users if needed (for testing before verification)
8. Click **"Save and Continue"** until you finish

## Step 4: Create OAuth 2.0 Credentials

1. Go to **"APIs & Services"** > **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** at the top
3. Select **"OAuth client ID"**
4. **Select "Web application" as the application type**
   
   **Why "Web application"?**
   - Your backend is a web server (Express.js/Node.js)
   - The backend receives and verifies Google ID tokens from the mobile app
   - Even though you have a mobile app, the backend needs a "Web application" client ID
   - The mobile app will use this same Client ID when authenticating with Google
   - You can create separate client IDs for Android/iOS later if needed, but for now, "Web application" works for both
   
5. Give it a name (e.g., "Plantify Backend" or "Plantify Web Client")
6. For **Authorized JavaScript origins**:
   - **You can leave this EMPTY** (not needed for mobile apps)
   - OR if you want to add them (optional):
     - `https://plantify-2-fre0.onrender.com`
     - `http://localhost:5001` (for local development, but Google may reject localhost)
   
7. For **Authorized redirect URIs**:
   - **You can leave this EMPTY** (recommended for mobile apps)
   - OR if you want to add them (optional):
     - `https://plantify-2-fre0.onrender.com/api/auth/google/callback`
     - `http://localhost:5001/api/auth/google/callback` (for local development)
   
   **Important**: For mobile apps using ID token verification, these fields are NOT required because:
   - The mobile app handles the OAuth flow directly (not via browser redirects)
   - The mobile app receives the Google ID token from Google's SDK
   - The mobile app sends the token to your backend API endpoint (`POST /api/auth/google`)
   - Your backend verifies the token server-side (no redirect needed)
   - These fields are only needed if you're doing web-based OAuth redirects
7. Click **"Create"**
8. You'll see a popup with:
    - **Client ID** (copy this - it looks like: `xxxxx.apps.googleusercontent.com`)
    - **Client Secret** (copy this)
9. Click **"OK"** and save these credentials securely

## Step 5: Configure Environment Variables

1. Create a `.env` file in the `backend` directory (if it doesn't exist)
2. Add the following variables:

```env
GOOGLE_CLIENT_ID=your-client-id-here.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret-here
```

**Important Security Notes:**
- Never commit your `.env` file to version control
- Add `.env` to your `.gitignore` file
- For production, set these as environment variables in your hosting platform (e.g., Render, Heroku)

## Step 6: Verify the Setup

1. Make sure your `.env` file is in the `backend` directory
2. Restart your backend server
3. The Google OAuth endpoint should be available at: `POST /api/auth/google`

## How It Works

### Flow for Mobile Apps

1. **Mobile App**: User clicks "Sign in with Google"
2. **Mobile App**: Uses Google Sign-In SDK to authenticate
3. **Mobile App**: Receives an ID token from Google
4. **Mobile App**: Sends the ID token to your backend: `POST /api/auth/google` with `{ "token": "google-id-token" }`
5. **Backend**: Verifies the token with Google using `google-auth-library`
6. **Backend**: Creates or finds the user in your database
7. **Backend**: Returns JWT access and refresh tokens to the mobile app

### API Endpoint

**POST** `/api/auth/google`

**Request Body:**
```json
{
  "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij..."
}
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name",
      "googleId": "google_user_id"
    },
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": {
    "message": "Google authentication failed",
    "code": "UNAUTHORIZED"
  }
}
```

## Troubleshooting

### Error: "Google authentication failed"

1. **Check environment variables**: Make sure `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are set correctly
2. **Verify token**: The token from the mobile app must be a valid Google ID token
3. **Check client ID match**: The token must be issued for the same `GOOGLE_CLIENT_ID` configured in your backend

### Error: "Invalid Google token"

1. The token might be expired (Google ID tokens expire after 1 hour)
2. The token might be malformed
3. The token might not be an ID token (make sure the mobile app is requesting an ID token, not an access token)

### Testing with Postman/curl

You can test the endpoint with a valid Google ID token:

```bash
curl -X POST http://localhost:5000/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"token": "your-google-id-token-here"}'
```

## Additional Configuration for Production

### For Render/Heroku/Other Platforms

1. Go to your service's environment variables settings
2. Add:
   - `GOOGLE_CLIENT_ID` = your client ID
   - `GOOGLE_CLIENT_SECRET` = your client secret
3. Save and redeploy

### OAuth Consent Screen Verification

If you're making your app public, you'll need to:
1. Complete the OAuth consent screen
2. Submit your app for verification (if using sensitive scopes)
3. This process can take several days

For development and testing, you can add test users in the OAuth consent screen.

## Security Best Practices

1. **Never expose client secret**: The client secret should only be on your backend, never in mobile apps
2. **Use HTTPS**: Always use HTTPS in production
3. **Validate tokens**: The backend always validates tokens with Google (already implemented)
4. **Rate limiting**: Auth endpoints are rate-limited (already configured)
5. **Token expiration**: Access tokens expire after 15 minutes, refresh tokens after 7 days

## Next Steps

- Configure your mobile app to use Google Sign-In
- Test the authentication flow end-to-end
- Set up proper error handling in your mobile app
- Consider adding additional OAuth providers if needed

