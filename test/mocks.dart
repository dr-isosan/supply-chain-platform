import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  FirebaseStorage,
  CollectionReference,
  DocumentReference,
  Query,
  User,
])
void main() {}
