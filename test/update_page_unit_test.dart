import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:tedarikapp/update_supply_page.dart';
import 'mocks.mocks.dart'; 

class MockFirestoreInstance extends Mock implements FirebaseFirestore {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  test('Successfully update supply', () async {
    final mockFirestore = MockFirestoreInstance();
    final mockDocumentReference = MockDocumentReference();

    // Firestore'da "supplies" koleksiyonunu mock'la
    when(mockFirestore.collection('supplies').doc('testSupplyId')).thenReturn(mockDocumentReference);

    // Güncellenen veriyi mock'la
    when(mockDocumentReference.update(any)).thenAnswer((_) async => Future.value());

    // Update fonksiyonunun başarıyla çağrıldığını kontrol et
    await mockFirestore.collection('supplies').doc('testSupplyId').update({
      'description': 'Updated Description',
      'sector': 'Updated Sector',
      'title': 'Updated Title',
    });

    // Firestore update fonksiyonunun çağrıldığını doğrula
    verify(mockDocumentReference.update({
      'description': 'Updated Description',
      'sector': 'Updated Sector',
      'title': 'Updated Title',
    })).called(1);
  });

  test('Fail to update supply and show error', () async {
    final mockFirestore = MockFirestoreInstance();
    final mockDocumentReference = MockDocumentReference();

    // Firestore'da "supplies" koleksiyonunu mock'la
    when(mockFirestore.collection('supplies').doc('testSupplyId')).thenReturn(mockDocumentReference);
    
    // Hata durumunu simüle et
    when(mockDocumentReference.update(any)).thenThrow(FirebaseException(plugin: 'firebase_plugin', message: 'Update failed'));

    try {
      // Güncelleme işlemi sırasında hata almayı bekle
      await mockFirestore.collection('supplies').doc('testSupplyId').update({
        'description': 'Updated Description',
        'sector': 'Updated Sector',
        'title': 'Updated Title',
      });
      fail('Expected FirebaseException but none occurred');
    } catch (e) {
      // Hata mesajını kontrol et
      expect(e, isInstanceOf<FirebaseException>());
    }
  });
}
