# API Documentation

## 📋 Overview

TedApp uses Firebase services as its backend, providing real-time data synchronization and secure authentication. This document outlines the data models, collections, and API patterns used in the application.

## 🔥 Firebase Collections

### 1. Users Collection (`users`)

**Collection Path**: `/users/{userId}`

**Document Structure**:

```json
{
  "id": "string",           // Document ID (matches Auth UID)
  "name": "string",         // User's full name
  "email": "string",        // User's email address
  "createdAt": "timestamp", // Account creation date
  "updatedAt": "timestamp", // Last profile update
  "avatar": "string?"       // Profile picture URL (optional)
}
```

**Security Rules**:

- Users can only read/write their own data
- Authenticated users required

**Example Operations**:

```dart
// Create user profile
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'createdAt': FieldValue.serverTimestamp(),
    });

// Get user profile
DocumentSnapshot userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
```

### 2. Supplies Collection (`supplies`)

**Collection Path**: `/supplies/{supplyId}`

**Document Structure**:

```json
{
  "id": "string",           // Auto-generated document ID
  "userId": "string",       // Creator's user ID
  "title": "string",        // Supply title/name
  "description": "string",  // Detailed description
  "sector": "string",       // Industry sector
  "fileUrl": "string?",     // Attached file URL (optional)
  "fileName": "string?",    // Original file name (optional)
  "status": "string",       // Supply status (active, closed, etc.)
  "createdAt": "timestamp", // Creation date
  "updatedAt": "timestamp", // Last modification date
  "tags": "array?"          // Category tags (optional)
}
```

**Security Rules**:

- All authenticated users can read
- Only the creator can update/delete
- Title and description are required fields

**Example Operations**:

```dart
// Create new supply
await FirebaseFirestore.instance
    .collection('supplies')
    .add({
      'userId': currentUserId,
      'title': 'Office Supplies Needed',
      'description': 'Looking for bulk office supplies...',
      'sector': 'Technology',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

// Get all supplies
Stream<QuerySnapshot> suppliesStream = FirebaseFirestore.instance
    .collection('supplies')
    .where('status', isEqualTo: 'active')
    .orderBy('createdAt', descending: true)
    .snapshots();

// Update supply
await FirebaseFirestore.instance
    .collection('supplies')
    .doc(supplyId)
    .update({
      'title': 'Updated Title',
      'updatedAt': FieldValue.serverTimestamp(),
    });

// Delete supply
await FirebaseFirestore.instance
    .collection('supplies')
    .doc(supplyId)
    .delete();
```

### 3. Applications Collection (`applications`)

**Collection Path**: `/applications/{applicationId}`

**Document Structure**:

```json
{
  "id": "string",           // Auto-generated document ID
  "userId": "string",       // Applicant's user ID
  "supplyId": "string",     // Referenced supply ID
  "status": "string",       // Application status
  "message": "string?",     // Optional application message
  "createdAt": "timestamp", // Application date
  "updatedAt": "timestamp", // Last status update
  "reviewedBy": "string?",  // Reviewer's user ID (optional)
  "reviewedAt": "timestamp?" // Review date (optional)
}
```

**Status Values**:

- `"Beklemede"` - Pending review
- `"Kabul Edildi"` - Approved
- `"Reddedildi"` - Rejected
- `"İptal Edildi"` - Cancelled by applicant

**Security Rules**:

- Users can only manage their own applications
- Supply owners can view applications for their supplies

**Example Operations**:

```dart
// Create application
await FirebaseFirestore.instance
    .collection('applications')
    .add({
      'userId': currentUserId,
      'supplyId': targetSupplyId,
      'status': 'Beklemede',
      'createdAt': FieldValue.serverTimestamp(),
    });

// Get user's applications
Stream<QuerySnapshot> applicationsStream = FirebaseFirestore.instance
    .collection('applications')
    .where('userId', isEqualTo: currentUserId)
    .orderBy('createdAt', descending: true)
    .snapshots();

// Update application status
await FirebaseFirestore.instance
    .collection('applications')
    .doc(applicationId)
    .update({
      'status': 'Kabul Edildi',
      'reviewedBy': reviewerUserId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
```

## 🔐 Authentication API

### User Registration

```dart
try {
  UserCredential result = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  // Create user profile in Firestore
  await FirebaseFirestore.instance
      .collection('users')
      .doc(result.user!.uid)
      .set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
} catch (e) {
  // Handle registration errors
}
```

### User Login

```dart
try {
  UserCredential result = await FirebaseAuth.instance
      .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
  // User successfully logged in
} catch (e) {
  // Handle login errors
}
```

### User Logout

```dart
await FirebaseAuth.instance.signOut();
```

### Password Reset

```dart
await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
```

## 📁 File Storage API

### File Upload

```dart
// Upload file to Firebase Storage
Future<String> uploadFile(PlatformFile file) async {
  try {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('supplies/${DateTime.now().millisecondsSinceEpoch}_${file.name}');

    final uploadTask = await storageRef.putData(file.bytes!);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    throw Exception('File upload failed: $e');
  }
}
```

### File Deletion

```dart
// Delete file from Firebase Storage
Future<void> deleteFile(String fileUrl) async {
  try {
    final storageRef = FirebaseStorage.instance.refFromURL(fileUrl);
    await storageRef.delete();
  } catch (e) {
    // Handle deletion errors
  }
}
```

## 🔍 Query Patterns

### Search Supplies

```dart
// Search by description
Stream<QuerySnapshot> searchSupplies(String query) {
  return FirebaseFirestore.instance
      .collection('supplies')
      .where('description', isGreaterThanOrEqualTo: query)
      .where('description', isLessThan: query + 'z')
      .snapshots();
}

// Filter by sector
Stream<QuerySnapshot> getSuppliesBySector(String sector) {
  return FirebaseFirestore.instance
      .collection('supplies')
      .where('sector', isEqualTo: sector)
      .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .snapshots();
}
```

### Pagination

```dart
// Paginated query
Query getSuppliesPage({DocumentSnapshot? lastDocument, int limit = 10}) {
  Query query = FirebaseFirestore.instance
      .collection('supplies')
      .orderBy('createdAt', descending: true)
      .limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  return query;
}
```

## 📊 Data Validation

### Client-side Validation

```dart
class SupplyValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }
}
```

### Server-side Rules

```javascript
// Firestore security rules for validation
match /supplies/{supplyId} {
  allow create: if request.auth != null
    && request.resource.data.title is string
    && request.resource.data.title.size() > 0
    && request.resource.data.title.size() <= 100
    && request.resource.data.description is string
    && request.resource.data.description.size() > 0
    && request.resource.data.description.size() <= 500;
}
```

## ⚡ Real-time Updates

### Listen to Collection Changes

```dart
// Listen to supplies collection
StreamSubscription suppliesSubscription = FirebaseFirestore.instance
    .collection('supplies')
    .snapshots()
    .listen((QuerySnapshot snapshot) {
      for (DocumentChange change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            // Handle new supply
            break;
          case DocumentChangeType.modified:
            // Handle updated supply
            break;
          case DocumentChangeType.removed:
            // Handle deleted supply
            break;
        }
      }
    });
```

## 🚨 Error Handling

### Common Error Codes

```dart
class FirebaseErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'User not found';
        case 'wrong-password':
          return 'Invalid password';
        case 'email-already-in-use':
          return 'Email already registered';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email address';
        default:
          return 'Authentication failed: ${error.message}';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied';
        case 'unavailable':
          return 'Service temporarily unavailable';
        default:
          return 'Database error: ${error.message}';
      }
    }
    return 'Unknown error occurred';
  }
}
```

## 📈 Performance Optimization

### Efficient Queries

```dart
// Use compound queries instead of multiple queries
Stream<QuerySnapshot> getActiveSuppliesByUser(String userId) {
  return FirebaseFirestore.instance
      .collection('supplies')
      .where('userId', isEqualTo: userId)
      .where('status', isEqualTo: 'active')
      .snapshots();
}

// Use pagination for large datasets
Future<List<QueryDocumentSnapshot>> loadMoreSupplies() async {
  return await FirebaseFirestore.instance
      .collection('supplies')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .get()
      .then((snapshot) => snapshot.docs);
}
```

### Caching Strategy

```dart
// Enable offline persistence
await FirebaseFirestore.instance.enablePersistence();

// Use cached data when offline
Source source = await FirebaseFirestore.instance
    .collection('supplies')
    .doc(supplyId)
    .get(const GetOptions(source: Source.cache));
```

## 🔄 Data Migration

### Schema Updates

When updating the data schema, follow these patterns:

1. **Additive Changes**: Add new fields with default values
2. **Field Renaming**: Use migration functions
3. **Data Type Changes**: Gradual migration with compatibility

### Migration Example

```dart
// Migrate old supplies to new schema
Future<void> migrateSupplies() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('supplies')
      .where('version', isEqualTo: 1)
      .get();

  for (DocumentSnapshot doc in snapshot.docs) {
    await doc.reference.update({
      'status': 'active', // Add new field
      'version': 2,       // Update version
    });
  }
}
```

---

This API documentation provides a comprehensive guide for working with TedApp's data layer and Firebase integration.
