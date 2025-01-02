import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:tedarikapp/profile_page.dart';
import 'mocks.mocks.dart'; // ProfilePage dosyasını import et

class MockFirestoreInstance extends Mock implements FirebaseFirestore {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  setUp(() async {
    await Firebase.initializeApp();
  });

  test('Firestore fetches user data correctly', () async {
    // Mock veriyi ayarla
    final mockUserData = {
      'name': 'Test User',
      'email': 'testuser@example.com',
    };

    // Firestore mock verisi
    final firestore = MockFirestoreInstance();
    final mockDocSnapshot = MockDocumentSnapshot();
    
    // Set up the mock to return the mock data
    when(mockDocSnapshot.data()).thenReturn(mockUserData);
    when(firestore.collection('users').doc('testUserId').get()).thenAnswer(
      (_) async => mockDocSnapshot,
    );

    // Firestore verisini al
    final snapshot = await firestore.collection('users').doc('testUserId').get();

    // Verilerin doğru şekilde alındığını kontrol et
    final userData = snapshot.data();
    expect(userData!['name'], 'Test User');
    expect(userData['email'], 'testuser@example.com');
  });

  test('Handles Firestore errors gracefully', () async {
    final firestore = MockFirestoreInstance();

    // Firestore hatasını taklit et
    when(firestore.collection('users').doc('invalidUserId').get()).thenThrow(FirebaseException(plugin: 'cloud_firestore', message: 'Error'));

    try {
      await firestore.collection('users').doc('invalidUserId').get();
      fail('FirebaseException expected');
    } catch (e) {
      expect(e, isInstanceOf<FirebaseException>());
    }
  });
}
