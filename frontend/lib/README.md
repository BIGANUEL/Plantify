# Clean Architecture Structure

This project follows Clean Architecture principles.

## Folder Structure

```
lib/
├── core/                          # Shared code across features
│   ├── constants/                 # App-wide constants
│   ├── errors/                    # Failure and Exception classes
│   ├── usecases/                  # Base use case interface
│   └── utils/                     # Utility functions
│
├── features/                      # Feature modules
│   └── [feature_name]/            # Add your features here
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Remote & Local data sources
│       │   ├── models/            # Data models (JSON serialization)
│       │   └── repositories/      # Repository implementations
│       ├── domain/                 # Domain layer (Business logic)
│       │   ├── entities/          # Business objects
│       │   ├── repositories/      # Repository interfaces
│       │   └── usecases/          # Business use cases
│       └── presentation/          # Presentation layer (UI)
│           ├── bloc/              # BLoC pattern (state management)
│           ├── pages/             # Full screen widgets
│           └── widgets/           # Reusable UI components
│
└── main.dart                      # App entry point
```

## Architecture Layers

### 1. **Domain Layer** (Business Logic)
- **Entities**: Pure business objects with no dependencies
- **Repositories**: Abstract interfaces defining data contracts
- **Use Cases**: Business logic operations

### 2. **Data Layer** (Implementation)
- **Models**: Data transfer objects with JSON serialization
- **Data Sources**: Remote (API) and Local (cache/database) implementations
- **Repository Implementations**: Concrete implementations of domain repositories

### 3. **Presentation Layer** (UI)
- **BLoC**: State management using BLoC pattern
- **Pages**: Full screen widgets
- **Widgets**: Reusable UI components

## Dependencies Flow

```
Presentation → Domain ← Data
```

- Presentation depends on Domain
- Data depends on Domain
- Domain has NO dependencies on other layers






