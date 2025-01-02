import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tedarikapp/register_page.dart'; // RegisterPage dosyasını import et

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestoreInstance extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await Firebase.initializeApp();
  });

  test('Register user successfully and save to Firestore', () async {
    final mockUser = MockUser();
    final mockUserCredential = MockUserCredential();
    final mockFirestore = FirebaseFirestore.instance;

    when(FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'test@example.com', 
      password: 'password123',
    )).thenAnswer((_) async => mockUserCredential);
    
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testUserId');

    // Kullanıcı kaydını Firestore'a kaydet
    when(FirebaseFirestore.instance.collection('users').doc('testUserId').set(Map<String, dynamic>())).thenAnswer((_) async => Future.value());

    // Kullanıcıyı kaydetme
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'test@example.com', 
      password: 'password123',
    );

    // Kullanıcı kaydının Firestore'a kaydedildiğini kontrol et
    verify(mockFirestore.collection('users').doc(mockUser.uid).set({
      'email': 'test@example.com',
      'name': 'Test User',
      'createdAt': any,
    })).called(1);
  });

  test('Throws error if fields are empty', () async {
    try {
      // Boş alanlarla kayıt olmaya çalış
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '', 
        password: '',
      );
      fail('Expected error but none occurred');
    } catch (e) {
      // Hata mesajını kontrol et
      expect(e, isInstanceOf<FirebaseAuthException>());
    }
  });
}