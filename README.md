# Keep In Touch - Flutter Animal Adoption Tracking App

A Flutter-based mobile application for tracking animal adoption forms and managing the communication workflow for an animal adoption association.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Configuration](#configuration)
- [Models](#models)
- [State Management](#state-management)
- [Screens](#screens)
- [Widgets](#widgets)
- [Form State Machine](#form-state-machine)
- [API Endpoints](#api-endpoints)
- [Running the App](#running-the-app)

## Overview

This application provides a streamlined interface for managing animal adoption forms through a linear state machine workflow. Users can:

- Authenticate with the system
- View and filter animals by their form status
- See detailed animal and owner information
- Manage form states with an intuitive state progression system
- Track form history and progression

## Features

- **Authentication**: Secure login system with JWT token persistence
- **Animal Management**: List, filter, and view animal details
- **Form State Machine**: 4-state workflow (Created → Sent → Filled → Controlled)
- **Dynamic Form Controls**: State-specific buttons showing target state colors
- **Auto-Session Recovery**: Users stay logged in across app restarts
- **Responsive Navigation**: Back buttons with automatic data refresh

## Project Structure

```
keep_in_touch/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   └── api_config.dart          # API configuration
│   ├── models/
│   │   ├── token.dart               # Token model
│   │   ├── user.dart                # User model
│   │   ├── animal.dart              # Animal model
│   │   └── form_model.dart          # Form model with state machine
│   ├── services/
│   │   ├── api_service.dart         # Base HTTP client
│   │   ├── auth_service.dart        # Authentication service
│   │   ├── animal_service.dart      # Animal CRUD operations
│   │   └── form_service.dart        # Form CRUD & state updates
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication state
│   │   ├── animal_provider.dart     # Animal list & filtering
│   │   └── form_provider.dart       # Form operations
│   ├── screens/
│   │   ├── login_screen.dart        # Login page
│   │   ├── home_screen.dart         # Animal list with filters
│   │   ├── animal_detail_screen.dart # Animal & forms view
│   │   └── profile_screen.dart      # User profile
│   ├── widgets/
│   │   ├── animal_card.dart         # Animal list item
│   │   ├── form_card.dart           # Form with state controls
│   │   ├── form_state_indicator.dart # Visual state progress
│   │   └── status_filter.dart       # Filter chips
│   └── utils/
│       └── constants.dart           # App constants & colors
└── pubspec.yaml
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5        # State management
  http: ^1.1.0           # HTTP client
  shared_preferences: ^2.2.0  # Local storage for tokens
  intl: ^0.18.1          # Date formatting
  cupertino_icons: ^1.0.8
```

## Configuration

### API Configuration

The API base URL is configured in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String tokenKey = 'auth_token';
}
```

## Models

### Animal Model

```dart
class Animal {
  final int id;
  final String name;
  final int responsibleUserId;
  final String ownerName;
  final String ownerContactNumber;
  final String ownerContactEmail;
  final int formGenerationPeriod;
  final List<int> formIds;
  final String formStatus;  // 'created', 'sent', 'filled', 'controlled'
}
```

### FormModel

```dart
class FormModel {
  final int id;
  final int animalId;
  final String formStatus;  // 'pending', 'sent', 'filled', 'controlled'
  final DateTime createdDate;
  final String? assignedDate;
  final String? filledDate;
  final String? controlledDate;
  final String? controlDueDate;
}
```

### Token Model

```dart
class Token {
  final String accessToken;
  final String tokenType;
}
```

### User Model

```dart
class User {
  final int id;
  final String name;
  final String role;  // 'admin' or 'regular'
}
```

## State Management

The app uses **Provider** pattern with `ChangeNotifier`:

### AuthProvider
- Manages user authentication state
- Handles login/logout operations
- Stores JWT token in SharedPreferences
- Provides `username`, `token`, `isAuthenticated` getters

### AnimalProvider
- Fetches and caches animal list
- Handles status filtering
- Provides `animals`, `filteredAnimals`, `selectedFilter`

### FormProvider
- Fetches forms by animal
- Handles state transitions (next/previous)
- Provides `forms`, `latestForms`, `olderForms`

## Screens

### LoginScreen
- Username and password fields
- Login button with loading state
- Error snackbar on failure

### HomeScreen
- Status filter chips (All, Sent, Filled, Controlled)
- Animal list with status badges
- Refresh FAB (floating action button)
- Profile icon navigation

### AnimalDetailScreen
- Animal information section
- Owner information section
- Forms list (latest 3 visible, expandable for older)
- Back button with auto-refresh

### ProfileScreen
- Username display
- Email placeholder
- Role indicator
- Logout button with confirmation
- Back button with auto-refresh

## Widgets

### AnimalCard
- Displays animal name (left)
- Status badge with color (right)
- Tap to navigate to detail

### StatusFilter
- 4 filter chips: All, Sent, Filled, Controlled
- Updates animal list on selection

### FormCard
- Form ID and status badge
- Visual state indicator
- Created date
- Tap to open state dialog

### FormStateIndicator
- Visual progress bar (4 dots + 3 lines)
- Colors: Gray → Blue → Green → Purple
- Shows current position in workflow

## Form State Machine

### States
| State | Value | Color | Description |
|-------|-------|-------|-------------|
| Created | 0 | Gray (0xFF9E9E9E) | Initial state |
| Sent | 1 | Blue (0xFF2196F3) | Form sent to responsible user |
| Filled | 2 | Green (0xFF4CAF50) | Form completed by owner |
| Controlled | 3 | Purple (0xFF9C27B0) | Form reviewed and approved |

### Transition Logic
- **Forward (Next)**: Sets next available state to true
- **Backward (Previous)**: Sets last true state back to false (LIFO)

### Dialog Behavior
Each state shows tailored buttons:
- **Created**: Only "Go to Sent" (Blue arrow)
- **Sent**: "Go to Created" (Gray arrow) + "Go to Filled" (Green arrow)
- **Filled**: "Go to Sent" (Blue arrow) + "Go to Controlled" (Purple arrow)
- **Controlled**: Only "Go to Filled" (Green arrow)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/users/login` | User authentication |
| GET | `/animals/` | List all animals |
| GET | `/animals/{id}` | Get animal details |
| GET | `/forms/animal/{animalId}` | Get forms by animal |
| PUT | `/forms/{formId}` | Update form state |

### Request Headers
```dart
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer {token}'
}
```

## Running the App

### Prerequisites
- Flutter SDK installed
- Backend server running at `http://localhost:8000`

### Commands

```bash
# Navigate to project
cd keep_in_touch

# Install dependencies
flutter pub get

# Run in debug mode (Edge browser)
flutter run -d edge

# Run in release mode
flutter build apk --release
flutter build web --release

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Hot Reload
- Press `r` for hot reload (preserves state)
- Press `R` for hot restart (resets state)

## Notes

- Token is stored in SharedPreferences and persists across app restarts
- App auto-checks for existing token on startup
- Browser refresh preserves session (calls `checkAuth()`)
- Mobile app maintains session during app switches
- All date fields use ISO 8601 format

## License

This project is for educational purposes.
