import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tedarikapp/home_page.dart';

// Mock class for Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}

void main() {
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
  });

  test('Fetch data from Firestore', () async {
    // Mock Firestore query snapshot
    final querySnapshot = MockQuerySnapshot();
    when(mockFirestore.collection('supplies').get()).thenAnswer(
      (_) async => querySnapshot as QuerySnapshot<Map<String, dynamic>>,
    );

    // Test: Firestore'dan veri çekmeye çalış
    final result = await mockFirestore.collection('supplies').get();

    // Verinin doğru şekilde döndüğünü kontrol et
    expect(result, querySnapshot);
    verify(mockFirestore.collection('supplies').get()).called(1);
  });

  test('Add item to Firestore', () async {
    final data = {
      'title': 'Test Title',
      'description': 'Test Description',
      'sector': 'Test Sector',
    };

    // Mock Firestore collection add
    when(mockFirestore.collection('supplies').add(data)).thenAnswer(
      (_) async => Future.value(),
    );

    // Tedarik ekleme işlevini test et
    await mockFirestore.collection('supplies').add(data);

    // Verinin Firestore'a doğru şekilde eklenip eklenmediğini kontrol et
    verify(mockFirestore.collection('supplies').add(data)).called(1);
  });
}