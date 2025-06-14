# Deployment Guide

## 📋 Overview

This guide covers the deployment process for TedApp across different platforms and environments.

## 🏗️ Build Prerequisites

### Development Environment

- Flutter SDK 3.5.4+
- Dart SDK (included with Flutter)
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)
- Git

### Firebase Setup

- Firebase project created
- Authentication enabled
- Firestore database configured
- Storage bucket set up
- Platform-specific configuration files

## 🔧 Environment Configuration

### 1. Firebase Configuration

#### Android Setup

1. Download `google-services.json` from Firebase Console
2. Place in `android/app/` directory
3. Ensure Android package name matches Firebase project

#### iOS Setup

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to `ios/Runner/` directory via Xcode
3. Ensure iOS bundle ID matches Firebase project

#### Web Setup

1. Add Firebase SDK to `web/index.html`
2. Configure Firebase options in `lib/firebase_options.dart`

### 2. Environment Variables

Create environment-specific configurations:

```dart
// lib/config/environment.dart
class Environment {
  static const String production = 'production';
  static const String development = 'development';
  static const String staging = 'staging';

  static String get current {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: development);
  }

  static bool get isProduction => current == production;
  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
}
```

## 📱 Android Deployment

### 1. Debug Build

```bash
# Build debug APK
flutter build apk --debug

# Install on connected device
flutter install
```

### 2. Release Build

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### 3. Signing Configuration

Create `android/key.properties`:

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=<your_key_alias>
storeFile=<path_to_keystore_file>
```

Update `android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. Google Play Store Deployment

1. Create developer account
2. Upload APK/AAB to Play Console
3. Configure store listing
4. Set pricing and distribution
5. Submit for review

## 🍎 iOS Deployment

### 1. Debug Build

```bash
# Build for iOS simulator
flutter build ios --simulator

# Build for physical device
flutter build ios --release
```

### 2. Release Build

```bash
# Build iOS archive
flutter build ipa --release
```

### 3. Code Signing

1. Configure signing in Xcode
2. Set up provisioning profiles
3. Configure App Store Connect

### 4. App Store Deployment

1. Archive in Xcode
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for App Store review

## 🌐 Web Deployment

### 1. Build Web App

```bash
# Build for web
flutter build web --release

# Build with custom base href
flutter build web --base-href="/tedapp/"
```

### 2. Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### 3. Custom Domain Setup

1. Configure custom domain in Firebase Console
2. Add DNS records
3. Verify domain ownership
4. Enable SSL certificate

## 🐳 Docker Deployment

### Dockerfile

```dockerfile
FROM ghcr.io/cirruslabs/flutter:3.5.4

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose

```yaml
version: '3.8'
services:
  tedapp:
    build: .
    ports:
      - "80:80"
    environment:
      - ENVIRONMENT=production
```

## ☁️ Cloud Deployment

### Google Cloud Platform

```bash
# Deploy to Cloud Run
gcloud run deploy tedapp \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### AWS Amplify

1. Connect GitHub repository
2. Configure build settings
3. Set environment variables
4. Deploy automatically on git push

### Netlify

1. Connect repository
2. Set build command: `flutter build web`
3. Set publish directory: `build/web`
4. Deploy

## 🔄 CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy TedApp

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.5.4'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test

    - name: Build web
      run: flutter build web --release

    - name: Deploy to Firebase Hosting
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        projectId: your-firebase-project-id
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.5.4"

before_script:
  - apt update && apt install -y curl git unzip
  - git clone https://github.com/flutter/flutter.git -b stable --depth 1
  - export PATH="$PATH:`pwd`/flutter/bin"

test:
  stage: test
  script:
    - flutter pub get
    - flutter test

build:
  stage: build
  script:
    - flutter build web --release
  artifacts:
    paths:
      - build/web/

deploy:
  stage: deploy
  script:
    - firebase deploy --only hosting
  only:
    - main
```

## 📊 Monitoring & Analytics

### Firebase Analytics

```dart
// Initialize Analytics
await FirebaseAnalytics.instance.logAppOpen();

// Track custom events
await FirebaseAnalytics.instance.logEvent(
  name: 'supply_created',
  parameters: {
    'sector': supply.sector,
    'user_id': userId,
  },
);
```

### Crashlytics

```dart
// Initialize Crashlytics
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

// Record custom errors
try {
  // risky operation
} catch (error, stackTrace) {
  await FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    reason: 'Supply creation failed',
  );
}
```

### Performance Monitoring

```dart
// Track custom performance metrics
final trace = FirebasePerformance.instance.newTrace('supply_load_time');
await trace.start();

// Your code here

await trace.stop();
```

## 🔒 Security Configuration

### Production Security Checklist

- [ ] Remove debug flags
- [ ] Obfuscate Dart code
- [ ] Configure proper Firebase security rules
- [ ] Enable app signing
- [ ] Set up proper CORS policies
- [ ] Configure content security policies
- [ ] Enable HTTPS everywhere
- [ ] Validate all environment variables

### Code Obfuscation

```bash
# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=debug-info/
flutter build ipa --obfuscate --split-debug-info=debug-info/
```

## 🔄 Rolling Updates

### Blue-Green Deployment

1. Deploy new version to staging environment
2. Test thoroughly in staging
3. Switch traffic to new version
4. Monitor for issues
5. Keep old version as backup

### Canary Deployment

1. Deploy to small percentage of users
2. Monitor metrics and errors
3. Gradually increase traffic
4. Full rollout if stable

## 📋 Deployment Checklist

### Pre-Deployment

- [ ] All tests passing
- [ ] Code review completed
- [ ] Security scan passed
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version number incremented

### Post-Deployment

- [ ] Health checks passing
- [ ] Monitor error rates
- [ ] Check user feedback
- [ ] Verify analytics data
- [ ] Update status page
- [ ] Notify stakeholders

## 🆘 Rollback Procedures

### Quick Rollback

```bash
# Firebase Hosting rollback
firebase hosting:rollback

# Mobile app rollback
# Use staged rollout features in app stores
```

### Database Rollback

```javascript
// Firestore security rules rollback
firebase deploy --only firestore:rules --project staging
firebase deploy --only firestore:rules --project production
```

## 📞 Support & Troubleshooting

### Common Deployment Issues

1. **Build failures**: Check Flutter/Dart versions
2. **Firebase connection**: Verify configuration files
3. **Signing issues**: Check certificates and profiles
4. **Performance issues**: Optimize bundle size

### Getting Help

- Check deployment logs
- Review Firebase console
- Monitor application metrics
- Contact platform support if needed

---

This deployment guide ensures smooth and secure deployment of TedApp across all supported platforms.
