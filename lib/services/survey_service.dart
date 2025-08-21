import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/survey_model.dart';
import '../models/question_model.dart';

class SurveyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new survey
  Future<void> createSurvey(Survey survey) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final surveyData = survey.toMap();
      surveyData['ownerId'] = user.uid;
      surveyData['ownerName'] = user.displayName ?? 'Anonymous';
      surveyData['createdAt'] = FieldValue.serverTimestamp();
      surveyData['updatedAt'] = FieldValue.serverTimestamp();
      surveyData['responseCount'] = 0;
      surveyData['isPublic'] = true;

      await _firestore.collection('surveys').doc(survey.id).set(surveyData);
    } catch (e) {
      throw Exception('Error creating survey: $e');
    }
  }

  // Get all public surveys
  Stream<List<Survey>> getPublicSurveys() {
    return _firestore
        .collection('surveys')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Survey.fromFirestore(doc))
            .toList());
  }

  // Get surveys by owner
  Stream<List<Survey>> getSurveysByOwner(String ownerId) {
    return _firestore
        .collection('surveys')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Survey.fromFirestore(doc))
            .toList());
  }

  // Get survey by ID
  Future<Survey?> getSurveyById(String surveyId) async {
    try {
      final doc = await _firestore.collection('surveys').doc(surveyId).get();
      if (doc.exists) {
        return Survey.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching survey: $e');
    }
  }

  // Update survey
  Future<void> updateSurvey(Survey survey) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final surveyData = survey.toMap();
      surveyData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('surveys').doc(survey.id).update(surveyData);
    } catch (e) {
      throw Exception('Error updating survey: $e');
    }
  }

  // Delete survey
  Future<void> deleteSurvey(String surveyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user owns the survey
      final surveyDoc = await _firestore.collection('surveys').doc(surveyId).get();
      if (!surveyDoc.exists) {
        throw Exception('Survey not found');
      }

      final survey = Survey.fromFirestore(surveyDoc);
      if (survey.ownerId != user.uid) {
        throw Exception('Not authorized to delete this survey');
      }

      // Delete survey and all its responses
      final batch = _firestore.batch();
      
      // Delete survey document
      batch.delete(_firestore.collection('surveys').doc(surveyId));
      
      // Delete all responses for this survey
      final responses = await _firestore
          .collection('responses')
          .where('surveyId', isEqualTo: surveyId)
          .get();
      
      for (final responseDoc in responses.docs) {
        batch.delete(responseDoc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error deleting survey: $e');
    }
  }

  // Save survey draft
  Future<void> saveDraft(Survey survey) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final draftData = {
        'ownerId': user.uid,
        'title': survey.title,
        'description': survey.description,
        'bannerUrl': survey.bannerUrl,
        'questions': survey.questions.map((q) => q.toMap()).toList(),
        'hasReward': survey.hasReward,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Use survey ID as draft ID for easy retrieval
      await _firestore.collection('drafts').doc(survey.id).set(draftData);
    } catch (e) {
      throw Exception('Error saving draft: $e');
    }
  }

  // Get drafts by owner
  Stream<List<Map<String, dynamic>>> getDraftsByOwner(String ownerId) {
    return _firestore
        .collection('drafts')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Load draft
  Future<Survey?> loadDraft(String draftId) async {
    try {
      final doc = await _firestore.collection('drafts').doc(draftId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data == null) return null;
        
        return Survey(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          bannerUrl: data['bannerUrl'],
          questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ?? [],
          hasReward: data['hasReward'] ?? false,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ownerId: data['ownerId'] ?? '',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error loading draft: $e');
    }
  }

  // Delete draft
  Future<void> deleteDraft(String draftId) async {
    try {
      await _firestore.collection('drafts').doc(draftId).delete();
    } catch (e) {
      throw Exception('Error deleting draft: $e');
    }
  }

  // Submit survey response
  Future<void> submitResponse(String surveyId, Map<String, dynamic> answers) async {
    try {
      final user = _auth.currentUser;
      final responseId = _firestore.collection('responses').doc().id;

      final responseData = {
        'surveyId': surveyId,
        'respondentId': user?.uid ?? 'anonymous',
        'answers': answers,
        'submittedAt': FieldValue.serverTimestamp(),
        'completionTime': 0, 
      };

      // Update both response and survey response count
      final batch = _firestore.batch();
      
      // Add response
      batch.set(_firestore.collection('responses').doc(responseId), responseData);
      
      // Increment response count
      batch.update(
        _firestore.collection('surveys').doc(surveyId),
        {'responseCount': FieldValue.increment(1)}
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Error submitting response: $e');
    }
  }

  // Get responses for a survey 
  Stream<List<Map<String, dynamic>>> getSurveyResponses(String surveyId) {
    return _firestore
        .collection('responses')
        .where('surveyId', isEqualTo: surveyId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Search surveys
  Future<List<Survey>> searchSurveys(String query) async {
    try {
      if (query.isEmpty) return [];

      // Search by title
      final titleResults = await _firestore
          .collection('surveys')
          .where('isPublic', isEqualTo: true)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return titleResults.docs.map((doc) => Survey.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error searching surveys: $e');
    }
  }

  // Get survey analytics
  Future<Map<String, dynamic>> getSurveyAnalytics(String surveyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check user owns the survey
      final surveyDoc = await _firestore.collection('surveys').doc(surveyId).get();
      if (!surveyDoc.exists) {
        throw Exception('Survey not found');
      }

      final survey = Survey.fromFirestore(surveyDoc);
      if (survey.ownerId != user.uid) {
        throw Exception('Not authorized to view analytics');
      }

      // Get all responses for this survey
      final responses = await _firestore
          .collection('responses')
          .where('surveyId', isEqualTo: surveyId)
          .get();

      // Basic analytics
      final analytics = <String, dynamic>{
        'totalResponses': responses.docs.length,
        'averageCompletionTime': 0.0,
        'responsesByDate': <String, int>{},
        'questionAnalytics': <String, Map<String, dynamic>>{},
      };

      // Process responses for more detailed analytics
      for (final responseDoc in responses.docs) {
        final data = responseDoc.data();
        final submittedAt = (data['submittedAt'] as Timestamp?)?.toDate();
        
        if (submittedAt != null) {
          final dateKey = '${submittedAt.year}-${submittedAt.month.toString().padLeft(2, '0')}-${submittedAt.day.toString().padLeft(2, '0')}';
          final responsesByDate = analytics['responsesByDate'] as Map<String, int>;
          responsesByDate[dateKey] = (responsesByDate[dateKey] ?? 0) + 1;
        }

        // Process individual question responses
        final answers = data['answers'] as Map<String, dynamic>? ?? {};
        for (final entry in answers.entries) {
          final questionId = entry.key;
          final answer = entry.value;
          
          final questionAnalytics = analytics['questionAnalytics'] as Map<String, Map<String, dynamic>>;
          if (questionAnalytics[questionId] == null) {
            questionAnalytics[questionId] = {
              'responses': [],
              'responseCount': 0,
            };
          }
          
          final questionData = questionAnalytics[questionId]!;
          (questionData['responses'] as List).add(answer);
          questionData['responseCount'] = (questionData['responseCount'] as int) + 1;
        }
      }

      return analytics;
    } catch (e) {
      throw Exception('Error fetching analytics: $e');
    }
  }

  // Check already responded to survey
  Future<bool> hasUserResponded(String surveyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.isAnonymous) return false;

      final responses = await _firestore
          .collection('responses')
          .where('surveyId', isEqualTo: surveyId)
          .where('respondentId', isEqualTo: user.uid)
          .limit(1)
          .get();

      return responses.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}