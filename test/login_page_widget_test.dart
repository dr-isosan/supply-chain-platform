import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tedarikapp/login_page.dart';
import 'package:tedarikapp/home_page.dart';
import 'package:tedarikapp/register_page.dart';


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

  testWidgets('LoginPage UI Test - All Elements Present', (WidgetTester tester) async {
    // Sayfayı başlat
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );

    // UI bileşenlerinin varlığını kontrol et
    expect(find.text('Giriş Yap'), findsOneWidget); // AppBar başlığı
    expect(find.byType(TextField), findsNWidgets(2)); // E-posta ve Şifre inputları
    expect(find.byType(ElevatedButton), findsOneWidget); // Giriş yap butonu
    expect(find.byType(TextButton), findsOneWidget); // Kayıt ol butonu
  });

  testWidgets('Login Button press calls _loginUser', (WidgetTester tester) async {
    // Mock FirebaseAuth signInWithEmailAndPassword metodu
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password',
    )).thenAnswer(
      (_) async => mockUserCredential,
    );

    // Sayfayı başlat
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );

    // E-posta ve şifre alanlarını doldur
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');

    // Giriş yap butonuna tıkla
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Firebase'e giriş yapıldığında HomePage'e geçişi kontrol et
    verify(mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password',
    )).called(1);
  });

  testWidgets('LoginPage shows error message on failed login', (WidgetTester tester) async {
    // FirebaseAuth'un giriş yapma fonksiyonunu başarısız yap
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'wrong@example.com',
      password: 'wrongpassword',
    )).thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'Hatalı e-posta veya şifre'));

    // Sayfayı başlat
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );

    // E-posta ve şifre alanlarını doldur
    await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

    // Giriş yap butonuna tıkla
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Hata mesajının görünmesini kontrol et
    expect(find.text('Giriş başarısız: [FirebaseAuthException]'), findsOneWidget);
  });
}