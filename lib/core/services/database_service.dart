import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../models/supply_model.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update(data..addAll({'updatedAt': FieldValue.serverTimestamp()}));
  }

  // Supply operations
  Future<String> createSupply(SupplyModel supply) async {
    final docRef = await _firestore
        .collection(AppConstants.suppliesCollection)
        .add(supply.toMap());
    return docRef.id;
  }

  Future<SupplyModel?> getSupply(String supplyId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.suppliesCollection)
          .doc(supplyId)
          .get();

      if (doc.exists) {
        return SupplyModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      throw Exception('Failed to get supply: $e');
    }
    return null;
  }

  Stream<List<SupplyModel>> getSuppliesStream({
    String? userId,
    String? sector,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(AppConstants.suppliesCollection)
        .orderBy('createdAt', descending: true);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    if (sector != null) {
      query = query.where('sector', isEqualTo: sector);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SupplyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateSupply(String supplyId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.suppliesCollection)
        .doc(supplyId)
        .update(data..addAll({'updatedAt': FieldValue.serverTimestamp()}));
  }

  Future<void> deleteSupply(String supplyId) async {
    await _firestore
        .collection(AppConstants.suppliesCollection)
        .doc(supplyId)
        .delete();
  }

  // Search functionality
  Stream<List<SupplyModel>> searchSupplies(String query) {
    return _firestore
        .collection(AppConstants.suppliesCollection)
        .where('description', isGreaterThanOrEqualTo: query)
        .where('description', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SupplyModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Application operations
  Future<String> createApplication(ApplicationModel application) async {
    final docRef = await _firestore
        .collection(AppConstants.applicationsCollection)
        .add(application.toMap());
    return docRef.id;
  }

  Stream<List<ApplicationModel>> getUserApplicationsStream(String userId) {
    return _firestore
        .collection(AppConstants.applicationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ApplicationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateApplicationStatus(
    String applicationId,
    String status, {
    String? reviewerId,
  }) async {
    final data = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (reviewerId != null) {
      data['reviewedBy'] = reviewerId;
      data['reviewedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection(AppConstants.applicationsCollection)
        .doc(applicationId)
        .update(data);
  }

  Future<void> deleteApplication(String applicationId) async {
    await _firestore
        .collection(AppConstants.applicationsCollection)
        .doc(applicationId)
        .delete();
  }

  // Check if user has already applied to a supply
  Future<bool> hasUserApplied(String userId, String supplyId) async {
    final querySnapshot = await _firestore
        .collection(AppConstants.applicationsCollection)
        .where('userId', isEqualTo: userId)
        .where('supplyId', isEqualTo: supplyId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Pagination support
  Future<List<SupplyModel>> getSuppliesPage({
    DocumentSnapshot? lastDocument,
    int limit = AppConstants.itemsPerPage,
    String? sector,
  }) async {
    Query query = _firestore
        .collection(AppConstants.suppliesCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (sector != null) {
      query = query.where('sector', isEqualTo: sector);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return SupplyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Analytics and stats
  Future<Map<String, int>> getUserStats(String userId) async {
    final suppliesSnapshot = await _firestore
        .collection(AppConstants.suppliesCollection)
        .where('userId', isEqualTo: userId)
        .get();

    final applicationsSnapshot = await _firestore
        .collection(AppConstants.applicationsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    final pendingApplications = applicationsSnapshot.docs
        .where((doc) => doc.data()['status'] == AppConstants.statusPending)
        .length;

    return {
      'totalSupplies': suppliesSnapshot.docs.length,
      'totalApplications': applicationsSnapshot.docs.length,
      'pendingApplications': pendingApplications,
    };
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await batchDeleteUserData(userId);
  }

  // Batch operations for better performance
  Future<void> batchDeleteUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete user's supplies
    final suppliesSnapshot = await _firestore
        .collection(AppConstants.suppliesCollection)
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in suppliesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's applications
    final applicationsSnapshot = await _firestore
        .collection(AppConstants.applicationsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in applicationsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete user profile
    batch.delete(_firestore.collection(AppConstants.usersCollection).doc(userId));

    await batch.commit();
  }
}
