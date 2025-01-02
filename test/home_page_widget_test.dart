import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tedarikapp/home_page.dart';

// Mock class for Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Mock class for QuerySnapshot
class QuerySnapshotMock extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
  });

  testWidgets('HomePage UI test', (WidgetTester tester) async {
    // Sayfayı yükle
    await tester.pumpWidget(MaterialApp(home: HomePage(userId: 'testUserId')));

    // Sayfada belirli metinlerin veya widget'ların varlığını kontrol et
    expect(find.text('Tedarik Akışı'), findsOneWidget); // Başlık kontrolü
    expect(find.byType(ElevatedButton), findsOneWidget); // Buton kontrolü

    // Firestore'dan veri çekmeye çalışıp, listeleme kısmının düzgün çalışıp çalışmadığını kontrol et
    // Örneğin, veritabanında veri varsa ve listeleme yapılabiliyorsa,
    // liste görünmelidir.
    expect(find.byType(ListView), findsOneWidget); // ListView kontrolü
  });

  testWidgets('HomePage displays items from Firestore', (WidgetTester tester) async {
    // Mock Firestore'dan veri çekmek
    final querySnapshot = QuerySnapshotMock();
    when(mockFirestore.collection('supplies').get()).thenAnswer(
      (_) async => querySnapshot,
    );

    // Sayfayı yükle
    await tester.pumpWidget(MaterialApp(home: HomePage(userId: 'testUserId')));

    // Verilerin ekranda görünüp görünmediğini kontrol et
    expect(find.text('Test Title'), findsOneWidget); // Test Title, veritabanından çekilen bir başlık
  });
}