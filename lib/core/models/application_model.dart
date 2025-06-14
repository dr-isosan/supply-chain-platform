import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String userId;
  final String supplyId;
  final String status;
  final String? message;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.supplyId,
    required this.status,
    this.message,
    required this.createdAt,
    this.updatedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'supplyId': supplyId,
      'status': status,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewNotes': reviewNotes,
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      userId: map['userId'] ?? '',
      supplyId: map['supplyId'] ?? '',
      status: map['status'] ?? 'Beklemede',
      message: map['message'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      reviewedBy: map['reviewedBy'],
      reviewedAt: map['reviewedAt'] != null
          ? (map['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewNotes: map['reviewNotes'],
    );
  }

  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? supplyId,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewNotes,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      supplyId: supplyId ?? this.supplyId,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }

  bool get isPending => status == 'Beklemede';
  bool get isApproved => status == 'Kabul Edildi';
  bool get isRejected => status == 'Reddedildi';
  bool get isCancelled => status == 'İptal Edildi';
  bool get isReviewed => reviewedAt != null;

  String get statusColor {
    switch (status) {
      case 'Beklemede':
        return 'orange';
      case 'Kabul Edildi':
        return 'green';
      case 'Reddedildi':
        return 'red';
      case 'İptal Edildi':
        return 'grey';
      default:
        return 'blue';
    }
  }

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

  String get formattedReviewedAt {
    if (reviewedAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(reviewedAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce değerlendirildi';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce değerlendirildi';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce değerlendirildi';
    } else {
      return 'Az önce değerlendirildi';
    }
  }

  @override
  String toString() {
    return 'ApplicationModel{id: $id, userId: $userId, supplyId: $supplyId, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApplicationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
