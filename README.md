# 🛍️ TedApp - Supply Chain Management System 

BIL-327 Mobile Programming Project


[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> A modern, comprehensive supply chain management application built with Flutter and Firebase, designed to streamline supply requests, applications, and management processes.


## ✨ Features

### 🔐 **Authentication & User Management**

- Secure user registration and login with Firebase Authentication
- Email/password authentication with validation
- Persistent user sessions
- Profile management with user information display

### 📦 **Supply Management**

- Create and publish supply requests with detailed information
- Real-time supply feed with live updates
- File attachment support for supply documentation
- Advanced search functionality with filters
- Category-based supply organization

### 🎯 **Application System**

- Apply to available supplies with one-click functionality
- Track application status in real-time
- Withdraw applications when needed
- View application history and status updates

### 📊 **User Dashboard**

- Personal supply management (create, edit, delete)
- Application tracking and management
- Profile customization and information updates
- Comprehensive activity overview

### 🔍 **Advanced Search & Discovery**

- Real-time search across all supplies
- Filter by category, sector, and keywords
- Instant results with live data updates
- Search history and suggestions

## 🏗️ Architecture

This application follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── main.dart                 # App entry point
├── pages/                    # UI layer
│   ├── login_page.dart      # Authentication UI
│   ├── register_page.dart   # Registration UI
│   ├── home_page.dart       # Main dashboard
│   ├── profile_page.dart    # User profile
│   ├── add_supply_page.dart # Supply creation
│   └── update_supply_page.dart # Supply editing
├── services/                 # Business logic layer
├── models/                   # Data models
└── utils/                    # Utilities and helpers
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.5.4 or later)
- **Dart SDK** (included with Flutter)
- **Firebase Project** with Authentication and Firestore enabled
- **Android Studio** or **VS Code** with Flutter extensions

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/tedapp.git
   cd tedapp
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication with Email/Password provider
   - Enable Cloud Firestore database
   - Enable Firebase Storage
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`

4. **Run the application**

   ```bash
   flutter run
   ```

### Environment Setup

Create a `.env` file in the root directory:

```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
```

## 🧪 Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/unit_tests/
flutter test test/widget_tests/
flutter test test/integration_tests/
```

### Test Coverage

- **Unit Tests**: Business logic and data models
- **Widget Tests**: UI components and interactions
- **Integration Tests**: End-to-end user flows
- **Mock Testing**: Firebase services and external dependencies

## 📚 API Documentation

### Firebase Collections

#### `users`

```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "createdAt": "timestamp"
}
```

#### `supplies`

```json
{
  "id": "string",
  "userId": "string",
  "title": "string",
  "description": "string",
  "sector": "string",
  "fileUrl": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `applications`

```json
{
  "id": "string",
  "userId": "string",
  "supplyId": "string",
  "status": "Beklemede" | "Kabul Edildi" | "Reddedildi",
  "createdAt": "timestamp"
}
```

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI framework
- **[Firebase](https://firebase.google.com/)** - Backend services
  - Authentication
  - Cloud Firestore
  - Cloud Storage
  - Cloud Messaging
- **[Provider](https://pub.dev/packages/provider)** - State management
- **[File Picker](https://pub.dev/packages/file_picker)** - File selection
- **[Mockito](https://pub.dev/packages/mockito)** - Testing framework

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Write comprehensive tests for new features
- Update documentation for API changes
- Use meaningful commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author
- Email: <ishakudrn@gmail.com>

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for robust backend services
- Open source community for valuable packages and tools
- [Material Design](https://material.io/) for design guidelines



---

**Made with ❤️ using Flutter**
