import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_constants.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  Future<FileUploadResult> uploadFile({
    required PlatformFile file,
    required String folder,
    String? customFileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file
      _validateFile(file);

      // Generate unique filename
      final fileName = customFileName ?? _generateFileName(file.name);
      final filePath = '$folder/$fileName';

      // Create storage reference
      final ref = _storage.ref().child(filePath);

      // Upload file
      final uploadTask = ref.putData(
        file.bytes!,
        SettableMetadata(
          contentType: _getContentType(file.extension),
          customMetadata: {
            'originalName': file.name,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Monitor progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return FileUploadResult(
        success: true,
        downloadUrl: downloadUrl,
        fileName: fileName,
        filePath: filePath,
        fileSize: file.size,
      );
    } catch (e) {
      return FileUploadResult(
        success: false,
        error: 'Upload failed: ${e.toString()}',
      );
    }
  }

  /// Upload multiple files
  Future<List<FileUploadResult>> uploadMultipleFiles({
    required List<PlatformFile> files,
    required String folder,
    Function(int completed, int total)? onProgress,
  }) async {
    final results = <FileUploadResult>[];

    for (int i = 0; i < files.length; i++) {
      final result = await uploadFile(
        file: files[i],
        folder: folder,
      );
      results.add(result);

      if (onProgress != null) {
        onProgress(i + 1, files.length);
      }
    }

    return results;
  }

  /// Delete a file from Firebase Storage
  Future<bool> deleteFile(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete file by URL
  Future<bool> deleteFileByUrl(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata
  Future<FileMetadata?> getFileMetadata(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      final metadata = await ref.getMetadata();

      return FileMetadata(
        name: metadata.name ?? '',
        size: metadata.size ?? 0,
        contentType: metadata.contentType ?? '',
        createdAt: metadata.timeCreated,
        updatedAt: metadata.updated,
        downloadUrl: await ref.getDownloadURL(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Pick and upload a document file
  Future<Map<String, String>?> pickAndUploadDocument({
    required String folder,
    required String userId,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      _validateFile(file);

      final fileName = _generateFileName(file.name);
      final uploadPath = '$folder/$userId/$fileName';

      final downloadUrl = await _uploadFile(
        file.bytes!,
        uploadPath,
        file.name.split('.').last,
      );

      return {
        'url': downloadUrl,
        'name': file.name,
        'path': uploadPath,
      };
    } catch (e) {
      throw Exception('Document upload failed: $e');
    }
  }

  /// Generate a unique filename
  String _generateFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    return '${timestamp}_$originalName';
  }

  /// Validate file before upload
  void _validateFile(PlatformFile file) {
    // Check file size
    if (file.size > AppConstants.maxFileSize) {
      throw Exception('File size exceeds ${AppConstants.maxFileSize / (1024 * 1024)}MB limit');
    }

    // Check if file has bytes
    if (file.bytes == null) {
      throw Exception('File data is null');
    }

    // Check file extension (optional - add your allowed extensions)
    final allowedExtensions = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'];
    final extension = file.extension?.toLowerCase();

    if (extension == null || !allowedExtensions.contains(extension)) {
      throw Exception('File type not supported. Allowed: ${allowedExtensions.join(', ')}');
    }
  }

  /// Get content type based on file extension
  String? _getContentType(String? extension) {
    if (extension == null) return null;

    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Compress image before upload (for mobile images)
  Future<Uint8List?> compressImage(Uint8List imageBytes, {int quality = 70}) async {
    // Note: You might want to add image compression library
    // like flutter_image_compress for actual compression
    return imageBytes;
  }

  /// Get storage usage statistics
  Future<StorageStats> getStorageStats(String userId) async {
    try {
      // Note: Firebase doesn't provide direct storage usage API
      // You would need to track this in Firestore or implement custom solution
      return StorageStats(
        totalFiles: 0,
        totalSize: 0,
        usedSpace: 0,
        availableSpace: 0,
      );
    } catch (e) {
      return StorageStats(
        totalFiles: 0,
        totalSize: 0,
        usedSpace: 0,
        availableSpace: 0,
      );
    }
  }
}

/// Result class for file upload operations
class FileUploadResult {
  final bool success;
  final String? downloadUrl;
  final String? fileName;
  final String? filePath;
  final int? fileSize;
  final String? error;

  FileUploadResult({
    required this.success,
    this.downloadUrl,
    this.fileName,
    this.filePath,
    this.fileSize,
    this.error,
  });
}

/// File metadata class
class FileMetadata {
  final String name;
  final int size;
  final String contentType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String downloadUrl;

  FileMetadata({
    required this.name,
    required this.size,
    required this.contentType,
    this.createdAt,
    this.updatedAt,
    required this.downloadUrl,
  });
}

/// Storage statistics class
class StorageStats {
  final int totalFiles;
  final int totalSize;
  final int usedSpace;
  final int availableSpace;

  StorageStats({
    required this.totalFiles,
    required this.totalSize,
    required this.usedSpace,
    required this.availableSpace,
  });
}
