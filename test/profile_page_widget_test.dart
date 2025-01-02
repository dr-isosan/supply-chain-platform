import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarikapp/profile_page.dart';
import 'mocks.mocks.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Firebase'i Mocklama
  // Testin yapılacağı widget
  testWidgets('ProfilePage renders correctly', (WidgetTester tester) async {
    // Firebase'i başlat
    await Firebase.initializeApp();

    // Kullanıcı Id
    const userId = 'testUserId';

    // Firestore'da test verisi oluştur
    final mockUserData = {
      'name': 'Test User',
      'email': 'testuser@example.com',
    };


    // ProfilePage widget'ını başlat
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(userId: userId),
      ),
    );

    // 'Test User' ve 'testuser@example.com' verilerinin ekranda göründüğünü doğrula
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('testuser@example.com'), findsOneWidget);
  });
}