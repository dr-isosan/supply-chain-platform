import 'package:cloud_firestore/cloud_firestore.dart';

class SupplyModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String sector;
  final String? fileUrl;
  final String? fileName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status;
  final List<String>? tags;
  final int viewCount;
  final int applicationCount;

  SupplyModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.sector,
    this.fileUrl,
    this.fileName,
    required this.createdAt,
    this.updatedAt,
    this.status = 'active',
    this.tags,
    this.viewCount = 0,
    this.applicationCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'sector': sector,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'status': status,
      'tags': tags,
      'viewCount': viewCount,
      'applicationCount': applicationCount,
    };
  }

  factory SupplyModel.fromMap(Map<String, dynamic> map, String id) {
    return SupplyModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      sector: map['sector'] ?? '',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'active',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      viewCount: map['viewCount'] ?? 0,
      applicationCount: map['applicationCount'] ?? 0,
    );
  }

  SupplyModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? sector,
    String? fileUrl,
    String? fileName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<String>? tags,
    int? viewCount,
    int? applicationCount,
  }) {
    return SupplyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      applicationCount: applicationCount ?? this.applicationCount,
    );
  }

  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  @override
  String toString() {
    return 'SupplyModel{id: $id, title: $title, sector: $sector}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
