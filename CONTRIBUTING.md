# Contributing to TedApp

Thank you for your interest in contributing to TedApp! We welcome contributions from the community and are pleased to have you aboard.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)
- [License](#license)

## 🤝 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

### Our Standards

- Be respectful and inclusive
- Exercise consideration and empathy
- Focus on what is best for the community
- Show courtesy and respect towards other community members

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.5.4 or later)
- Dart SDK (included with Flutter)
- Git
- Your favorite IDE (VS Code, Android Studio, IntelliJ IDEA)

### Development Setup

1. **Fork the repository**

   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**

   ```bash
   git clone https://github.com/your-username/tedapp.git
   cd tedapp
   ```

3. **Add upstream remote**

   ```bash
   git remote add upstream https://github.com/original-repo/tedapp.git
   ```

4. **Install dependencies**

   ```bash
   flutter pub get
   ```

5. **Set up Firebase**
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase Authentication and Firestore

6. **Run the app**

   ```bash
   flutter run
   ```

## 🛠 How to Contribute

### Types of Contributions

We welcome several types of contributions:

- **Bug fixes**
- **Feature implementations**
- **Documentation improvements**
- **Code refactoring**
- **Performance optimizations**
- **UI/UX improvements**
- **Test coverage improvements**

### Workflow

1. **Create an issue** (for new features or bugs)
2. **Fork the repository**
3. **Create a feature branch**
4. **Make your changes**
5. **Test your changes**
6. **Submit a pull request**

## 💻 Development Guidelines

### Branch Naming

Use descriptive branch names:

- `feature/user-authentication`
- `fix/login-validation-bug`
- `docs/contributing-guidelines`
- `refactor/home-page-components`

### Commit Messages

Follow conventional commit format:

```
type(scope): description

feat(auth): add biometric authentication
fix(ui): resolve login button positioning
docs(readme): update installation instructions
test(auth): add unit tests for login validation
```

### Code Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── theme/             # App theming
│   ├── widgets/           # Reusable widgets
│   └── utils/             # Utility functions
├── pages/                  # UI screens
├── services/              # Business logic
├── models/                # Data models
└── main.dart              # App entry point
```

## 🎨 Coding Standards

### Dart Style Guide

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- Use `lowerCamelCase` for variables and functions
- Use `UpperCamelCase` for classes and enums
- Use `lowercase_with_underscores` for libraries and packages
- Prefer `final` over `var` when possible
- Use meaningful variable and function names

### Flutter Best Practices

- Use `const` constructors when possible
- Implement proper error handling
- Follow the single responsibility principle
- Use meaningful widget names
- Implement proper state management
- Optimize for performance

### Code Formatting

```bash
# Format your code before committing
flutter format .

# Analyze code for issues
flutter analyze

# Run linter
dart analyze
```

## 🧪 Testing Guidelines

### Test Structure

```
test/
├── unit_tests/            # Unit tests
├── widget_tests/          # Widget tests
├── integration_tests/     # Integration tests
└── mocks/                 # Mock objects
```

### Writing Tests

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for complete user flows
- Aim for good test coverage (>80%)
- Use descriptive test names

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit_tests/auth_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 📝 Pull Request Process

### Before Submitting

1. **Update your branch**

   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests**

   ```bash
   flutter test
   flutter analyze
   ```

3. **Format code**

   ```bash
   flutter format .
   ```

### PR Requirements

- [ ] Code follows project style guidelines
- [ ] Tests pass and coverage is maintained
- [ ] Documentation is updated (if needed)
- [ ] No breaking changes (unless discussed)
- [ ] PR description clearly explains changes
- [ ] Screenshots included (for UI changes)

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass
- [ ] New tests added
- [ ] Manual testing completed

## Screenshots
(if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## 🐛 Issue Guidelines

### Bug Reports

Include:

- Flutter/Dart version
- Device/platform information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/logs (if applicable)

### Feature Requests

Include:

- Clear description of the feature
- Use case/motivation
- Proposed implementation (if any)
- Alternative solutions considered

## 📚 Documentation

### Code Documentation

- Add dartdoc comments for public APIs
- Include usage examples
- Document complex algorithms
- Keep documentation up to date

### README Updates

- Update feature lists
- Add new screenshots
- Update installation instructions
- Keep changelog current

## 🏆 Recognition

Contributors will be recognized in:

- README contributors section
- Release notes
- GitHub contributors page

## 📞 Getting Help

If you need help:

1. Check existing issues and documentation
2. Create a discussion thread
3. Join our community chat
4. Contact maintainers directly

## 📄 License

By contributing to TedApp, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to TedApp! 🚀
