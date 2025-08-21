import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class DraftService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveDraft({
    required bool isGuest,
    required String? bannerPath,
    required String title,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    final data = {
      'bannerPath': bannerPath,
      'title': title,
      'description': description,
      'questions': questions,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (isGuest) {
      final guestId = const Uuid().v4();
      await _firestore
          .collection('guests')
          .doc(guestId)
          .collection('drafts')
          .add({
        ...data,
        'expiresAt': DateTime.now().add(const Duration(hours: 1)),
      });
    } else {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");
      await _firestore.collection('users').doc(uid).collection('drafts').add(data);
    }
  }
}
