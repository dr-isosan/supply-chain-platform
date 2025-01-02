import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarikapp/login_page.dart';

// Mock class for FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
  });

  test('Login with valid credentials', () async {
    // Mock Firestore signInWithEmailAndPassword method
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'valid@example.com',
      password: 'correctpassword',
    )).thenAnswer(
      (_) async => mockUserCredential,
    );

    // Test: Valid giriş yapma
    final userCredential = await mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'valid@example.com',
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