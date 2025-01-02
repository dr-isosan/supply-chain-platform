import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:tedarikapp/register_page.dart'; 
import 'mocks.mocks.dart';
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestoreInstance extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Firebase'i Mocklamak


  testWidgets('RegisterPage renders and shows error when fields are empty', (WidgetTester tester) async {
    await Firebase.initializeApp();

    // Widget'ı başlat
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterPage(),
      ),
    );

    // Kayıt ol butonuna tıkla
    await tester.tap(find.text('Kayıt Ol'));
    await tester.pump();

    // Hata mesajının göründüğünü doğrula
    expect(find.text('Lütfen tüm alanları doldurun.'), findsOneWidget);
  });

  testWidgets('RegisterPage successfully registers a user', (WidgetTester tester) async {
    await Firebase.initializeApp();

    final mockUser = MockUser();
    final mockUserCredential = MockUserCredential();
    
    when(FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'test@example.com', 
      password: 'password123',
    )).thenAnswer((_) async => mockUserCredential);
    
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testUserId');

    // Widget'ı başlat
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterPage(),
      ),
    );

    // E-posta, şifre ve ad alanlarını doldur
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');

    // Kayıt ol butonuna tıkla
    await tester.tap(find.text('Kayıt Ol'));
    await tester.pump();

    // Firestore işlemini kontrol et
    verify(FirebaseFirestore.instance.collection('users').doc(mockUser.uid).set({
      'email': 'test@example.com',
      'name': 'Test User',
      'createdAt': any,
    })).called(1);

    // Kayıt başarılı olduğunda SnackBar'ı kontrol et
    expect(find.text('Kayıt başarılı!'), findsOneWidget);
  });
}