import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarikapp/update_supply_page.dart';
class MockFirestoreInstance extends Mock implements FirebaseFirestore {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Firebase'i Mocklamak

  testWidgets('UpdateSupplyPage renders and updates supply successfully', (WidgetTester tester) async {
    await Firebase.initializeApp();

    final mockDocumentSnapshot = MockDocumentSnapshot();
    final mockDocumentReference = MockDocumentReference();

    // Mock veri
    when(mockDocumentSnapshot.data()).thenReturn({
      'description': 'Test Description',
      'sector': 'Test Sector',
      'title': 'Test Title',
    });

    when(FirebaseFirestore.instance.collection('supplies').doc('testSupplyId')).thenReturn(mockDocumentReference as DocumentReference<Map<String, dynamic>>);
    when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

    // Widget'ı başlat
    await tester.pumpWidget(
      MaterialApp(
        home: UpdateSupplyPage(supplyId: 'testSupplyId', initialData: {
          'description': 'Test Description',
          'sector': 'Test Sector',
          'title': 'Test Title',
        }),
      ),
    );

    // Formun başlangıç verilerini kontrol et
    expect(find.byType(TextField).at(0), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('Test Sector'), findsOneWidget);
    expect(find.text('Test Title'), findsOneWidget);

    // Yeni veriyi gir
    await tester.enterText(find.byType(TextField).at(0), 'Updated Description');
    await tester.enterText(find.byType(TextField).at(1), 'Updated Sector');
    await tester.enterText(find.byType(TextField).at(2), 'Updated Title');

    // Güncelle butonuna tıkla
    await tester.tap(find.text('Güncelle'));
    await tester.pump();

    // Verilerin Firestore'a kaydedildiğini doğrula
    verify(FirebaseFirestore.instance.collection('supplies').doc('testSupplyId').update({
      'description': 'Updated Description',
      'sector': 'Updated Sector',
      'title': 'Updated Title',
    })).called(1);

    // Başarı mesajının göründüğünü kontrol et
    expect(find.text('Tedarik başarıyla güncellendi!'), findsOneWidget);
  });

  testWidgets('UpdateSupplyPage shows error if supply update fails', (WidgetTester tester) async {
    await Firebase.initializeApp();

    final mockDocumentSnapshot = MockDocumentSnapshot();
    final mockDocumentReference = MockDocumentReference();

    // Mock veri
    when(mockDocumentSnapshot.data()).thenReturn({
      'description': 'Test Description',
      'sector': 'Test Sector',
      'title': 'Test Title',
    });

    when(FirebaseFirestore.instance.collection('supplies').doc('testSupplyId')).thenReturn(mockDocumentReference as DocumentReference<Map<String, dynamic>>);
    when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
    when(mockDocumentReference.update(Map<String, dynamic>())).thenThrow(FirebaseException(plugin: 'firebase_plugin', message: 'Update failed'));

    // Widget'ı başlat
    await tester.pumpWidget(
      MaterialApp(
        home: UpdateSupplyPage(supplyId: 'testSupplyId', initialData: {
          'description': 'Test Description',
          'sector': 'Test Sector',
          'title': 'Test Title',
        }),
      ),
    );

    // Formu doldur
    await tester.enterText(find.byType(TextField).at(0), 'Updated Description');
    await tester.enterText(find.byType(TextField).at(1), 'Updated Sector');
    await tester.enterText(find.byType(TextField).at(2), 'Updated Title');

    // Güncelle butonuna tıkla
    await tester.tap(find.text('Güncelle'));
    await tester.pump();

    // Hata mesajının göründüğünü kontrol et
    expect(find.text('Tedarik güncellenemedi!'), findsOneWidget);
  });
}