# 🌱 Plantify - Plant Care Reminder App

A beautiful and intuitive mobile application for tracking and managing your plant collection. Plantify helps you never forget to water your plants with smart reminders, detailed plant care information, and a delightful user experience.

## 📱 Features

### Core Features
- **Plant Management**: Add, edit, and delete plants from your collection
- **Watering Reminders**: Track watering schedules and get notified when plants need water
- **Plant Details**: View comprehensive information about each plant including:
  - Watering intervals and next watering date
  - Light and humidity requirements
  - Care tips and instructions
  - Growth progress tracking
- **Explore**: Discover new plants and learn about common plant problems
- **Dark Mode**: Beautiful dark theme support
- **Weather Integration**: Get weather information to help with plant care decisions

### User Experience
- **Onboarding**: Smooth onboarding experience for new users
- **Authentication**: Secure login with email/password or Google OAuth
- **Modern UI**: Clean, intuitive interface with smooth animations
- **Responsive Design**: Optimized for both iOS and Android

## 🏗️ Architecture

Plantify follows **Clean Architecture** principles with clear separation of concerns:

```
frontend/
├── lib/
│   ├── core/              # Core utilities, widgets, constants
│   ├── features/          # Feature modules (auth, plants, explore)
│   │   ├── auth/
│   │   ├── plants/
│   │   └── explore/
│   └── screens/           # UI screens
└── ...

backend/
├── src/
│   ├── controllers/       # Route controllers
│   ├── services/          # Business logic
│   ├── models/            # Database models
│   ├── routes/            # API routes
│   └── middleware/        # Custom middleware
└── ...
```

### State Management
- **BLoC Pattern**: Using `flutter_bloc` for predictable state management
- **Dependency Injection**: Using `get_it` for service locator pattern
- **Repository Pattern**: Clean separation between data sources and business logic

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Node.js**: 20 or higher (for backend)
- **MongoDB**: Local installation or MongoDB Atlas account
- **Android Studio / Xcode**: For mobile development

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/BIGANUEL/Plantify.git
cd Plantify
```

2. **Backend Setup**
```bash
cd backend
npm install
cp .env.example .env
# Update .env with your configuration
npm run dev
```

3. **Frontend Setup**
```bash
cd frontend
flutter pub get
flutter run
```

For detailed setup instructions, see:
- [Backend README](./backend/README.md)
- [Frontend README](./frontend/README.md)

## 📁 Project Structure

```
Plantify/
├── backend/               # Node.js/Express backend API
│   ├── src/              # Source code
│   ├── docs/             # API documentation
│   └── README.md         # Backend documentation
├── frontend/             # Flutter mobile app
│   ├── lib/              # Dart source code
│   ├── android/          # Android configuration
│   ├── ios/              # iOS configuration
│   └── README.md         # Frontend documentation
└── README.md             # This file
```

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: BLoC (flutter_bloc)
- **Dependency Injection**: get_it
- **HTTP Client**: http
- **Local Storage**: shared_preferences
- **UI**: Material Design 3 with custom theming

### Backend
- **Runtime**: Node.js 20+
- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT + Google OAuth 2.0
- **API Documentation**: Swagger/OpenAPI

## 📱 Screenshots

The app includes:
- **Onboarding Screen**: Welcome experience for new users
- **Authentication**: Login and registration with email/password or Google
- **Dashboard**: Home screen with plant collection overview
- **Plant Detail**: Detailed view of individual plants
- **Add/Edit Plant**: Forms for managing plant information
- **Explore**: Discover new plants and solutions
- **Reminders**: Watering schedule and notifications
- **Profile**: User settings and preferences

## 🔐 Authentication

Plantify supports multiple authentication methods:
- **Email/Password**: Traditional registration and login
- **Google OAuth**: One-click sign-in with Google account
- **JWT Tokens**: Secure token-based authentication
- **Token Refresh**: Automatic token refresh mechanism

## 🌿 Plant Management

### Adding Plants
- Plant name and type
- Watering interval (in days)
- Next watering date
- Light requirements (Low, Medium, Bright, Direct Sunlight)
- Humidity requirements (Low, Medium, High)
- Care tips and instructions
- Optional photo URL

### Tracking Features
- Automatic watering date calculation
- Visual status indicators (needs water, well hydrated, etc.)
- Watering history
- Growth progress tracking

## 📚 API Documentation

The backend API is fully documented:
- **Swagger UI**: Available at `http://localhost:5000/api-docs` (when running locally)
- **API Specification**: See [backend/docs/backend-specification.md](./backend/docs/backend-specification.md)

### Key Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/google` - Google OAuth
- `GET /api/plants` - Get all plants
- `POST /api/plants` - Create plant
- `PUT /api/plants/:id` - Update plant
- `DELETE /api/plants/:id` - Delete plant
- `POST /api/plants/:id/water` - Mark plant as watered

## 🧪 Development

### Running the App

**Backend (Development)**
```bash
cd backend
npm run dev
```

**Frontend (Development)**
```bash
cd frontend
flutter run
```

### Building for Production

**Backend**
```bash
cd backend
npm run build
npm start
```

**Frontend**
```bash
cd frontend
flutter build apk        # Android
flutter build ios        # iOS
```

## 🧩 Features Breakdown

### Authentication Module
- User registration and login
- Google OAuth integration
- JWT token management
- Session persistence

### Plants Module
- CRUD operations for plants
- Watering schedule management
- Plant status tracking
- Image support

### Explore Module
- Plant discovery
- Problem diagnosis
- Care tips and solutions

### UI Components
- Custom widgets (PlantifyCard, PlantifyButton, PlantifyHeader)
- Consistent color scheme
- Dark mode support
- Smooth animations

## 🔒 Security

- Passwords hashed with bcrypt
- JWT tokens with expiration
- CORS protection
- Rate limiting
- Input validation
- Secure HTTP headers (Helmet)

## 📝 Environment Variables

### Backend (.env)
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/plantify
JWT_SECRET=your-secret-key
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
CORS_ORIGIN=http://localhost:3000
```

### Frontend
Update `lib/core/constants/app_constants.dart` with your backend URL:
```dart
static const String baseUrl = 'http://localhost:5000';
```

## 🚢 Deployment

### Backend
The backend is configured for deployment on Render using Docker. See [backend/README.md](./backend/README.md) for details.

### Frontend
- **Android**: Build APK or AAB and publish to Google Play Store
- **iOS**: Build and publish to Apple App Store
- **Web**: `flutter build web` for web deployment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

ISC

## 👥 Authors

- Development Team

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source contributors whose packages made this project possible

## 📞 Support

For issues, questions, or contributions, please:
- Check the documentation in `backend/README.md` and `frontend/README.md`
- Review the API specification in `backend/docs/backend-specification.md`
- Open an issue on GitHub

---

**Made with 🌱 for plant lovers everywhere**
