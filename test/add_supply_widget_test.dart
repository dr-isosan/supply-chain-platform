import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tedarikapp/add_supply_page.dart';
import 'mocks.mocks.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock sınıflarını oluşturuyoruz
  final mockFirebaseFirestore = MockFirebaseFirestore();
  final mockFirebaseStorage = MockFirebaseStorage();

  // AddSupplyPage sayfasını test etmeden önce gerekli widget'ları yerleştireceğiz
  testWidgets('AddSupplyPage should display form fields', (WidgetTester tester) async {
    // Sayfayı test widget'ına ekle
    await tester.pumpWidget(MaterialApp(
      home: AddSupplyPage(userId: 'user_123'),
    ));

    // Başlık, açıklama ve sektör metin alanlarının doğru şekilde görüntülendiğini kontrol et
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byWidgetPredicate((widget) => widget is TextField && (widget as TextField).controller == (tester.firstWidget(find.byType(TextField)) as TextField).controller), findsOneWidget);
  });

  testWidgets('AddSupplyPage should show error when fields are empty', (WidgetTester tester) async {
    // Sayfayı test widget'ına ekle
    await tester.pumpWidget(MaterialApp(
      home: AddSupplyPage(userId: 'user_123'),
    ));

    // Tedarik ekle butonuna tıkla
    await tester.tap(find.byType(ElevatedButton).at(1));  // 'Tedarik Ekle' butonu
    await tester.pump();  // UI'yi güncelle

    // Tüm alanlar boş olduğunda hata mesajı gösterilmeli
    expect(find.text('Lütfen tüm alanları doldurun.'), findsOneWidget);
  });

  testWidgets('AddSupplyPage should upload file successfully', (WidgetTester tester) async {
    // Mock file picker
    when(FilePicker.platform.pickFiles()).thenAnswer((_) async => FilePickerResult([
          PlatformFile(name: 'testfile.txt', size: 1024, bytes: null, path: 'testfile.txt')
        ]));

    // Sayfayı test widget'ına ekle
    await tester.pumpWidget(MaterialApp(
      home: AddSupplyPage(userId: 'user_123'),
    ));

    // Dosya yükle butonuna tıkla
    await tester.tap(find.byType(ElevatedButton).first);  // 'Dosya Ekle' butonu
    await tester.pump();  // UI'yi güncelle

    // Yükleme başarılı olduğunda snack bar gösterilmeli
    expect(find.text('Dosya başarıyla yüklendi!'), findsOneWidget);
  });

  testWidgets('AddSupplyPage should add supply successfully', (WidgetTester tester) async {
    // Sayfayı test widget'ına ekle
    await tester.pumpWidget(MaterialApp(
      home: AddSupplyPage(userId: 'user_123'),
    ));

    // Metin alanlarını doldur
    await tester.enterText(find.byType(TextField).at(0), 'Tedarik Başlığı');
    await tester.enterText(find.byType(TextField).at(1), 'Tedarik Açıklaması');
    await tester.enterText(find.byType(TextField).at(2), 'Tekstil');

    // Tedarik ekle butonuna tıkla
    await tester.tap(find.byType(ElevatedButton).at(1));  // 'Tedarik Ekle' butonu
    await tester.pump();  // UI'yi güncelle

    // Başarılı tedarik ekleme sonrası snack bar gösterilmeli
    expect(find.text('Tedarik başarıyla eklendi!'), findsOneWidget);
  });
}