import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';
import '../services/auth_service.dart' hide debugPrint;

class RewardService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RewardModel> _availableRewards = [];
  List<RewardModel> _userRewards = [];
  bool _isLoading = false;

  List<RewardModel> get availableRewards => _availableRewards;
  List<RewardModel> get userRewards => _userRewards;
  bool get isLoading => _isLoading;

  // Award for survey completion
  Future<bool> awardPoints({
    required String userId,
    required int points,
    required String reason,
    String? surveyId,
  }) async {
    try {
      if (AuthService.isGuest) {
        if (kDebugMode) {
          debugPrint('Attempt to award points for guest user blocked.');
        }
        return false;
      }

      final rewardData = {
        'userId': userId,
        'points': points,
        'reason': reason,
        'surveyId': surveyId,
        'awardedAt': FieldValue.serverTimestamp(),
        'type': 'earned',
      };

      // Add reward record
      await _firestore.collection('user_rewards').add(rewardData);

      // Update user total rewards
      await _firestore.collection('users').doc(userId).update({
        'totalRewards': FieldValue.increment(points),
      });

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error awarding points: $e');
      }
      return false;
    }
  }

  // Get available rewards 
  Future<void> getAvailableRewards() async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('rewards')
          .where('isActive', isEqualTo: true)
          .orderBy('pointsRequired')
          .get();

      _availableRewards = querySnapshot.docs
          .map((doc) => RewardModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching available rewards: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // User reward history
  Future<void> getUserRewards(String userId) async {
    try {
      if (AuthService.isGuest) {
        _userRewards = [];
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('user_rewards')
          .where('userId', isEqualTo: userId)
          .orderBy('awardedAt', descending: true)
          .get();

      _userRewards = querySnapshot.docs
          .map((doc) => RewardModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching user rewards: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Redeem reward
  Future<bool> redeemReward({
    required String userId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    try {
      if (AuthService.isGuest) {
        if (kDebugMode) {
          debugPrint('Attempt to redeem reward for guest user blocked.');
        }
        return false;
      }

      // Check enough points
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final currentPoints = userData?['totalRewards'] as int? ?? 0;

      if (currentPoints < pointsRequired) {
        throw Exception('Insufficient points');
      }

      // Create redemption record
      final redemptionData = {
        'userId': userId,
        'rewardId': rewardId,
        'pointsUsed': pointsRequired,
        'redeemedAt': FieldValue.serverTimestamp(),
        'status': 'redeemed',
        'type': 'redeemed',
      };

      final redemptionRef =
          await _firestore.collection('reward_redemptions').add(redemptionData);

      // Deduct points from user
      await _firestore.collection('users').doc(userId).update({
        'totalRewards': FieldValue.increment(-pointsRequired),
      });

      // Add negative reward record for tracking
      final negativeRewardData = {
        'userId': userId,
        'points': -pointsRequired,
        'reason': 'Reward redemption',
        'rewardId': rewardId,
        'redemptionId': redemptionRef.id,
        'awardedAt': FieldValue.serverTimestamp(),
        'type': 'redeemed',
      };

      await _firestore.collection('user_rewards').add(negativeRewardData);

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error redeeming reward: $e');
      }
      return false;
    }
  }

  // User current points
  Future<int> getUserPoints(String userId) async {
    try {
      if (AuthService.isGuest) {
        return 0;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['totalRewards'] as int? ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching user points: $e');
      }
      return 0;
    }
  }

  // Get reward redemption history
  Future<List<Map<String, dynamic>>> getRedemptionHistory(String userId) async {
    try {
      if (AuthService.isGuest) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('reward_redemptions')
          .where('userId', isEqualTo: userId)
          .orderBy('redeemedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching redemption history: $e');
      }
      return [];
    }
  }

  // Calculate points for survey completion
  int calculateSurveyPoints({
    required int questionCount,
    required bool hasLocation,
    required bool isFromBusiness,
  }) {
    const basePoints = 10; 
    final questionPoints = questionCount * 2; // 2 points per question
    final locationBonus = hasLocation ? 5 : 0; // Bonus for location sharing
    final businessBonus = isFromBusiness ? 10 : 0; // Bonus for business surveys
    return basePoints + questionPoints + locationBonus + businessBonus;
  }

  // Add business reward
  Future<bool> addBusinessReward({
    required String businessId,
    required String title,
    required String description,
    required int pointsRequired,
    required String imageUrl,
    required DateTime expiryDate,
  }) async {
    try {
      final rewardData = {
        'businessId': businessId,
        'title': title,
        'description': description,
        'pointsRequired': pointsRequired,
        'imageUrl': imageUrl,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'redeemedCount': 0,
      };

      await _firestore.collection('rewards').add(rewardData);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding business reward: $e');
      }
      return false;
    }
  }

  // Get rewards by business
  Future<List<RewardModel>> getRewardsByBusiness(String businessId) async {
    try {
      final querySnapshot = await _firestore
          .collection('rewards')
          .where('businessId', isEqualTo: businessId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RewardModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching business rewards: $e');
      }
      return [];
    }
  }

  // Generate reward QR code for redemption
  String generateRewardQRCode({
    required String userId,
    required String rewardId,
    required String redemptionId,
  }) {
    if (AuthService.isGuest) {
      return '';
    }
    return 'reward_${rewardId}_${userId}_${redemptionId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Validate reward QR code
  Future<bool> validateRewardQRCode(String qrCode) async {
    try {
      final parts = qrCode.split('_');
      if (parts.length != 5 || parts[0] != 'reward') {
        return false;
      }

      final rewardId = parts[1];
      final userId = parts[2];
      final redemptionId = parts[3];

      if (AuthService.isGuest) {
        return false;
      }

      // Check if redemption exists and is valid
      final redemptionDoc =
          await _firestore.collection('reward_redemptions').doc(redemptionId).get();

      if (!redemptionDoc.exists) {
        return false;
      }

      final data = redemptionDoc.data()!;
      return data['status'] == 'redeemed' &&
          data['userId'] == userId &&
          data['rewardId'] == rewardId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error validating reward QR code: $e');
      }
      return false;
    }
  }

  // Mark reward as used by business
  Future<bool> markRewardAsUsed(String qrCode) async {
    try {
      final parts = qrCode.split('_');
      if (parts.length != 5 || parts[0] != 'reward') {
        return false;
      }
      final redemptionId = parts[3];
      if (AuthService.isGuest) {
        return false;
      }

      await _firestore.collection('reward_redemptions').doc(redemptionId).update({
        'status': 'used',
        'usedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking reward as used: $e');
      }
      return false;
    }
  }

  // Check user can earn rewards
  bool get canEarnRewards => !AuthService.isGuest;

  // Get user total points safely
  Future<int> getCurrentUserPoints() async {
    final user = AuthService.currentUser;
    if (user == null || AuthService.isGuest) {
      return 0;
    }
    return await getUserPoints(user.uid);
  }

  // Award points to current user for survey completion
  Future<bool> awardSurveyCompletionPoints({
    required String surveyId,
    required int questionCount,
    bool hasLocation = false,
    bool isFromBusiness = false,
  }) async {
    final user = AuthService.currentUser;
    if (user == null || AuthService.isGuest) {
      return false;
    }

    final points = calculateSurveyPoints(
      questionCount: questionCount,
      hasLocation: hasLocation,
      isFromBusiness: isFromBusiness,
    );

    return await awardPoints(
      userId: user.uid,
      points: points,
      reason: 'Survey completion',
      surveyId: surveyId,
    );
  }

  // Get leaderboard for top user points
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isAnonymous', isEqualTo: false)
          .orderBy('totalRewards', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'displayName': data['displayName'] ?? 'Anonymous',
          'totalRewards': data['totalRewards'] ?? 0,
          'photoURL': data['photoURL'] ?? '',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching leaderboard: $e');
      }
      return [];
    }
  }
}

