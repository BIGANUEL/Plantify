# Testing Google OAuth on Localhost

## Yes, You Can Test Google OAuth on Localhost! ✅

Your backend Google OAuth endpoint works perfectly on localhost. Here's what you need to know:

## What You Can Test

When testing the backend on localhost (`http://localhost:5001`), you can verify:

1. ✅ **Endpoint is accessible** - The `/api/auth/google` endpoint responds
2. ✅ **Environment variables are set correctly** - `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
3. ✅ **Token verification works** - Backend can verify Google ID tokens with Google's servers
4. ✅ **User creation/retrieval** - Database operations work correctly
5. ✅ **JWT token generation** - Access and refresh tokens are generated
6. ✅ **Error handling** - Invalid tokens, missing fields, etc.

## Prerequisites

1. **Backend server running** on localhost (default port: `5001`)
2. **Environment variables set** in `backend/.env`:
   ```env
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-client-secret
   MONGODB_URI=mongodb://localhost:27017/plantify
   JWT_SECRET=your-jwt-secret
   ```
3. **MongoDB running** (if using local database)
4. **Internet connection** (backend needs to verify tokens with Google's servers)

## How to Test

### Method 1: Using Your Mobile App (Recommended)

1. **Start your backend server:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Configure your mobile app** to point to localhost:
   - Update the base URL in your Flutter app to: `http://localhost:5001` or `http://10.0.2.2:5001` (for Android emulator)
   - Or use your computer's local IP: `http://192.168.x.x:5001` (for physical device)

3. **Test Google Sign-In** from your mobile app
   - The app will get a Google ID token
   - Send it to your localhost backend
   - Check the response

### Method 2: Using Postman/Thunder Client

1. **Get a Google ID token** (you need a real token from Google):
   
   **Option A: From your mobile app**
   - Sign in with Google in your app
   - Log the `idToken` from `GoogleSignInAuthentication`
   - Copy it to use in Postman
   
   **Option B: Using Google OAuth Playground**
   - Go to https://developers.google.com/oauthplayground/
   - Configure it with your `GOOGLE_CLIENT_ID`
   - Get an ID token

2. **Test the endpoint in Postman:**
   - **Method:** `POST`
   - **URL:** `http://localhost:5001/api/auth/google`
   - **Headers:**
     ```
     Content-Type: application/json
     ```
   - **Body (JSON):**
     ```json
     {
       "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij..."
     }
     ```

3. **Expected Success Response (200):**
   ```json
   {
     "success": true,
     "data": {
       "user": {
         "id": "user_id",
         "email": "user@gmail.com",
         "name": "User Name",
         "googleId": "google_user_id"
       },
       "accessToken": "jwt_access_token",
       "refreshToken": "jwt_refresh_token"
     }
   }
   ```

### Method 3: Using curl

```bash
curl -X POST http://localhost:5001/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"token": "your-google-id-token-here"}'
```

### Method 4: Using Swagger UI

1. **Start your backend server**
2. **Open Swagger UI:** `http://localhost:5001/api-docs`
3. **Find the `/api/auth/google` endpoint**
4. **Click "Try it out"**
5. **Enter a Google ID token** in the request body
6. **Execute** and see the response

## What to Look For

### ✅ Success Indicators

- **Status 200** with user data and tokens
- **User created/retrieved** in your database
- **Valid JWT tokens** returned (you can decode them at jwt.io)
- **Console logs** showing successful authentication

### ❌ Common Issues

1. **"Google authentication failed"**
   - Check `GOOGLE_CLIENT_ID` matches the token's audience
   - Verify `GOOGLE_CLIENT_SECRET` is correct
   - Ensure token is not expired (Google ID tokens expire after 1 hour)

2. **"Invalid Google token"**
   - Token might be malformed
   - Token might be an access token instead of ID token
   - Token might be expired

3. **Connection errors**
   - Backend can't reach Google's servers (check internet)
   - MongoDB connection issues (check MongoDB is running)

4. **CORS errors** (if testing from browser)
   - Backend CORS is configured to allow localhost
   - Should work with Postman/curl (no CORS)

## Testing Checklist

- [ ] Backend server starts without errors
- [ ] Environment variables are loaded (check console logs)
- [ ] MongoDB connection successful
- [ ] Endpoint responds: `GET http://localhost:5001/health`
- [ ] Can send POST request to `/api/auth/google`
- [ ] Valid Google ID token returns 200 with user data
- [ ] Invalid token returns 401 error
- [ ] Missing token returns 400 error
- [ ] User is created in database on first login
- [ ] Existing user is retrieved on subsequent logins

## Important Notes

1. **Localhost works fine** - Your backend doesn't need to be deployed to test Google OAuth
2. **Internet required** - Backend verifies tokens with Google's servers (needs internet)
3. **Token expiration** - Google ID tokens expire after 1 hour, get fresh tokens for testing
4. **Client ID must match** - The token must be issued for the same `GOOGLE_CLIENT_ID` in your `.env`
5. **Mobile app testing** - For Android emulator, use `10.0.2.2` instead of `localhost`
6. **Physical device testing** - Use your computer's local IP address (e.g., `192.168.1.100:5001`)

## Quick Test Script

You can also check if your backend is ready:

```bash
# Check if server is running
curl http://localhost:5001/health

# Should return:
# {"success":true,"message":"Server is running","timestamp":"..."}
```

## Next Steps

Once localhost testing works:
1. Test with your mobile app pointing to localhost
2. Test error scenarios (invalid tokens, expired tokens)
3. Verify database operations (user creation, updates)
4. Test token refresh functionality
5. Move to production URL when ready







