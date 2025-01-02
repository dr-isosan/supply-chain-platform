import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tedarikapp/add_supply_page.dart';
import 'dart:typed_data';


class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}

void main() {
  late MockFirebaseStorage mockStorage;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late Widget testWidget;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();


    testWidget = MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<FirebaseFirestore>.value(value: mockFirestore),
          Provider<FirebaseStorage>.value(value: mockStorage),
        ],
        child: AddSupplyPage(userId: 'test_user_id'),
      ),
    );
  });

  testWidgets('File upload works', (WidgetTester tester) async {
    final mockFile = PlatformFile(
      name: 'test_file.txt',
      size: 100,
      bytes: Uint8List(0),
    );
    final mockResult = FilePickerResult([mockFile]);

    when(FilePicker.platform.pickFiles())
        .thenAnswer((_) async => mockResult);

    await tester.pumpWidget(testWidget);
    await tester.tap(find.text('Dosya Ekle'));
    await tester.pump();

    expect(find.text('Dosya başarıyla yüklendi!'), findsOneWidget);
  });

  testWidgets('Add Supply works', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Test Title');
    await tester.enterText(find.byType(TextField).at(1), 'Test Description');
    await tester.enterText(find.byType(TextField).at(2), 'Test Sector');

    await tester.tap(find.text('Tedarik Ekle'));
    await tester.pumpAndSettle();

    verify(mockCollectionReference.add({
      'title': 'Test Title',
      'description': 'Test Description',
      'sector': 'Test Sector',
      'userId': 'test_user_id',
      'timestamp': any,
    })).called(1);

    expect(find.text('Tedarik başarıyla eklendi!'), findsOneWidget);
  });

  testWidgets('Show error when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.tap(find.text('Tedarik Ekle'));
    await tester.pump();

    expect(find.text('Lütfen tüm alanları doldurun.'), findsOneWidget);
  });
}