import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../lib/core/services/auth_service.dart';
import '../lib/core/utils/validation_utils.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  group('AuthService Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();
    });

    test('Sign in with valid email and password should succeed', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      // Act
      final result = await mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, isNotNull);
      expect(result.user?.uid, equals('test-uid'));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('Sign in with invalid credentials should throw exception', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'invalid@example.com',
        password: 'wrongpassword',
      )).thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      ));

      // Act & Assert
      expect(
        () async => await mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'invalid@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('ValidationUtils Tests', () {
    test('Valid email should return null', () {
      expect(ValidationUtils.validateEmail('test@example.com'), isNull);
      expect(ValidationUtils.validateEmail('user.name@domain.co.uk'), isNull);
    });

    test('Invalid email should return error message', () {
      expect(ValidationUtils.validateEmail(''), isNotNull);
      expect(ValidationUtils.validateEmail('invalid-email'), isNotNull);
      expect(ValidationUtils.validateEmail('@domain.com'), isNotNull);
      expect(ValidationUtils.validateEmail('test@'), isNotNull);
    });

    test('Valid password should return null', () {
      expect(ValidationUtils.validatePassword('password123', 'Password'), isNull);
      expect(ValidationUtils.validatePassword('MySecurePass!', 'Password'), isNull);
    });

    test('Invalid password should return error message', () {
      expect(ValidationUtils.validatePassword('', 'Password'), isNotNull);
      expect(ValidationUtils.validatePassword('123', 'Password'), isNotNull);
      expect(ValidationUtils.validatePassword('short', 'Password'), isNotNull);
    });

    test('Matching passwords should return null for confirmation', () {
      expect(ValidationUtils.validateConfirmPassword('password123', 'password123'), isNull);
    });

    test('Non-matching passwords should return error message', () {
      expect(ValidationUtils.validateConfirmPassword('password123', 'different'), isNotNull);
      expect(ValidationUtils.validateConfirmPassword('password123', ''), isNotNull);
    });

    test('Valid name should return null', () {
      expect(ValidationUtils.validateName('John', 'First Name'), isNull);
      expect(ValidationUtils.validateName('Jane Doe', 'Full Name'), isNull);
    });

    test('Invalid name should return error message', () {
      expect(ValidationUtils.validateName('', 'Name'), isNotNull);
      expect(ValidationUtils.validateName('   ', 'Name'), isNotNull);
    });

    test('Valid phone should return null', () {
      expect(ValidationUtils.validatePhone('05551234567'), isNull);
      expect(ValidationUtils.validatePhone('+905551234567'), isNull);
    });

    test('Invalid phone should return error message', () {
      expect(ValidationUtils.validatePhone(''), isNotNull);
      expect(ValidationUtils.validatePhone('123'), isNotNull);
      expect(ValidationUtils.validatePhone('invalid-phone'), isNotNull);
    });
  });
      password: 'correctpassword',
    );

    // Doğru giriş yapıldığında, userCredential döndürülmeli
    expect(userCredential, mockUserCredential);
  });

  test('Login with invalid credentials', () async {
    // Mock giriş hatası
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'invalid@example.com',
      password: 'wrongpassword',
    )).thenThrow(FirebaseAuthException(code: 'wrong-password', message: 'Hatalı e-posta veya şifre'));

    // Test: Hatalı giriş yapma
    try {
      await mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'invalid@example.com',
        password: 'wrongpassword',
      );
    } catch (e) {
      // Hata mesajı bekleniyor
      expect(e, isA<FirebaseAuthException>());
    }
  });
}
