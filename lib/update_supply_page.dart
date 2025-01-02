import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class UpdateSupplyPage extends StatefulWidget {
  final String supplyId;
  final Map<String, dynamic> initialData;

  UpdateSupplyPage({required this.supplyId, required this.initialData});

  @override
  _UpdateSupplyPageState createState() => _UpdateSupplyPageState();
}

class _UpdateSupplyPageState extends State<UpdateSupplyPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sectorController = TextEditingController();
  String? _uploadedFileUrl;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialData['title'] ?? '';
    _descriptionController.text = widget.initialData['description'] ?? '';
    _sectorController.text = widget.initialData['sector'] ?? '';
    _uploadedFileUrl = widget.initialData['fileUrl'];
  }

  Future<void> _pickAndUploadFile() async {
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
          setState(() {
            _uploadedFileUrl = fileUrl;
          });
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

  void _updateSupply() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _sectorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    final updateData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'sector': _sectorController.text.trim(),
    };

    if (_uploadedFileUrl != null) {
      updateData['fileUrl'] = _uploadedFileUrl!;
    }

    FirebaseFirestore.instance.collection('supplies').doc(widget.supplyId).update(updateData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tedarik başarıyla güncellendi!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tedarik Güncelle'),
        centerTitle: true,
        backgroundColor: Colors.tealAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Güncelleme Bilgileri',
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
                onPressed: _pickAndUploadFile,
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
                onPressed: _updateSupply,
                icon: const Icon(Icons.update),
                label: const Text('Güncelle'),
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
