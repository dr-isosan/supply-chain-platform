import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddSupplyPage extends StatelessWidget {
  final String userId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sectorController = TextEditingController();
  String? _uploadedFileUrl;

  AddSupplyPage({required this.userId});

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final fileName = file.name;
      final fileBytes = file.bytes;

      if (fileBytes != null) {
        final storageRef = FirebaseStorage.instance.ref().child('supplies/$fileName');
        try {
          final uploadTask = await storageRef.putData(fileBytes);
          final fileUrl = await uploadTask.ref.getDownloadURL();
          _uploadedFileUrl = fileUrl;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dosya başarıyla yüklendi!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dosya yükleme hatası: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dosya seçilmedi.')),
      );
    }
  }

  void _addSupply(BuildContext context) async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _sectorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    final newSupply = {
      'userId': userId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'sector': _sectorController.text.trim(),
      'createdAt': Timestamp.now(),
    };

    if (_uploadedFileUrl != null) {
      newSupply['fileUrl'] = _uploadedFileUrl as Object;
    }

    await FirebaseFirestore.instance.collection('supplies').add(newSupply);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tedarik başarıyla eklendi!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Tedarik Ekle'),
        centerTitle: true,
        backgroundColor: Colors.tealAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tedarik Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                hintText: 'Tedarik başlığını girin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Tedarik açıklamasını girin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _sectorController,
              decoration: InputDecoration(
                labelText: 'Sektör',
                hintText: 'Tedarik sektörünü girin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _pickAndUploadFile(context),
                icon: const Icon(Icons.attach_file),
                label: const Text('Dosya Ekle'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_uploadedFileUrl != null)
              Text(
                'Yüklenen Dosya: $_uploadedFileUrl',
                style: const TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _addSupply(context),
                icon: const Icon(Icons.add),
                label: const Text('Tedarik Ekle'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
