# Plantify Mobile App (Flutter)

A beautiful Flutter mobile application for plant care management and reminders.

## 📱 Overview

Plantify is a comprehensive plant care application that helps users track their plant collection, manage watering schedules, and discover new plants. Built with Flutter and following Clean Architecture principles.

## ✨ Features

- **Plant Management**: Add, edit, and delete plants
- **Watering Reminders**: Track watering schedules with automatic date calculations
- **Plant Details**: View comprehensive plant information including care requirements
- **Explore**: Discover new plants and learn about common problems
- **Authentication**: Secure login with email/password or Google OAuth
- **Dark Mode**: Beautiful dark theme support
- **Weather Integration**: Weather information for better plant care decisions
- **Onboarding**: Smooth first-time user experience

## 🏗️ Architecture

The app follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and shared code
│   ├── constants/          # App constants and colors
│   ├── di/                 # Dependency injection setup
│   ├── services/           # Core services (weather, etc.)
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable UI components
├── features/               # Feature modules
│   ├── auth/               # Authentication feature
│   │   ├── data/          # Data layer (datasources, models, repositories)
│   │   ├── domain/        # Domain layer (entities, repositories, usecases)
│   │   └── presentation/  # Presentation layer (bloc, pages, widgets)
│   ├── plants/            # Plants feature
│   └── explore/           # Explore feature
└── screens/                # App screens
    ├── onboarding_screen.dart
    ├── dashboard_screen.dart
    ├── add_plant_screen.dart
    ├── edit_plant_screen.dart
    ├── plant_detail_screen.dart
    ├── explore_screen.dart
    ├── reminders_screen.dart
    └── profile_screen.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Backend API running (see [backend/README.md](../backend/README.md))

### Installation

1. **Navigate to frontend directory**
```bash
cd frontend
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure backend URL**

Update `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://localhost:5000'; // or your backend URL
```

4. **Run the app**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc` - State management using BLoC pattern
- `get_it` - Dependency injection
- `http` - HTTP client for API calls
- `shared_preferences` - Local storage
- `equatable` - Value equality for objects

### UI Dependencies
- `animations` - Page transitions and animations
- `flutter_svg` - SVG image support
- `shimmer` - Loading shimmer effects

### Development Dependencies
- `flutter_lints` - Linting rules

## 🎨 UI Components

### Custom Widgets

- **PlantifyCard**: Custom card widget with animations
- **PlantifyButton**: Styled button with gradient support
- **PlantifyHeader**: Header component with gradient background
- **PlantifyTextField**: Custom text field with focus animations

### Color Scheme

The app uses a consistent color palette defined in `lib/core/constants/app_colors.dart`:
- **Primary Green**: `#4CAF50` - Main brand color
- **Water Teal**: `#14B8A6` - Water-related actions
- **Sun Amber**: `#F59E0B` - Sun/light indicators
- **Earth Brown**: `#8B6F47` - Earth/soil related

## 🔄 State Management

The app uses **BLoC (Business Logic Component)** pattern for state management:

### BLoC Structure
- **Events**: User actions (e.g., `LoadPlants`, `PlantCreated`)
- **States**: UI states (e.g., `PlantsLoading`, `PlantsLoaded`, `PlantsError`)
- **Bloc**: Business logic handler

### Example Flow
```
User Action → Event → BLoC → State → UI Update
```

## 📱 Screens

### Onboarding Screen
First-time user experience with app introduction.

### Authentication
- Login with email/password
- Registration
- Google OAuth sign-in

### Dashboard (Home)
- Plant collection overview
- Quick actions (water plants, diagnose)
- Weather information
- Plant grid/list view

### Add Plant Screen
Form to add new plants with:
- Name and type
- Watering interval
- Next watering date picker
- Light and humidity requirements
- Care tips
- Photo URL

### Edit Plant Screen
Edit existing plant information.

### Plant Detail Screen
Comprehensive plant view with:
- Plant information
- Watering schedule and progress
- Care requirements
- Quick actions
- Growth tracking
- Recent activities

### Explore Screen
Discover new plants and solutions to common problems.

### Reminders Screen
View and manage watering reminders.

### Profile Screen
User settings, preferences, and logout.

## 🔌 API Integration

### Base Configuration
Update the backend URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-backend-url.com';
```

### Authentication
- JWT tokens stored securely
- Automatic token refresh
- Token expiration handling

### API Calls
All API calls are made through:
- **Data Sources**: Direct API communication
- **Repositories**: Business logic layer
- **Use Cases**: Feature-specific operations
- **BLoC**: State management

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

## 🏗️ Building

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 🔧 Configuration

### Android
- Minimum SDK: 21
- Target SDK: 33
- Configuration: `android/app/build.gradle`

### iOS
- Minimum iOS: 12.0
- Configuration: `ios/Runner/Info.plist`

## 📝 Code Style

The project follows Flutter/Dart best practices:
- Use `flutter_lints` for linting
- Follow Clean Architecture principles
- Use meaningful variable and function names
- Add comments for complex logic
- Keep widgets small and focused

## 🐛 Debugging

### Enable Debug Logs
The app includes debug logging throughout. Look for logs prefixed with:
- `[PLANTS_BLOC]` - Plants feature logs
- `[AUTH_BLOC]` - Authentication logs
- `[ADD_PLANT]` - Add plant screen logs
- `[LOG]` - General application logs

### Common Issues

**Build Errors**
- Run `flutter clean` and `flutter pub get`
- Check Flutter version: `flutter --version`

**API Connection Issues**
- Verify backend is running
- Check `app_constants.dart` for correct base URL
- Verify network permissions in AndroidManifest.xml / Info.plist

**Authentication Issues**
- Check JWT token expiration
- Verify Google OAuth configuration
- Check backend authentication endpoints

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Backend API Documentation](../backend/README.md)

## 🤝 Contributing

1. Follow the existing code structure
2. Use BLoC for state management
3. Follow Clean Architecture principles
4. Write meaningful commit messages
5. Test your changes thoroughly

## 📄 License

ISC

---

**Happy Plant Caring! 🌱**
