import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check guest user
  static bool get isGuest => _auth.currentUser?.isAnonymous ?? true;

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!, displayName);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword(
    String email, 
    String password
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  // Sign in guest 
  static Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      
      // Create anonymous user
      if (result.user != null) {
        await _createUserDocument(result.user!, 'Guest User');
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during guest login');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during password reset');
    }
  }

  // Convert anonymous to real account
  static Future<UserCredential?> linkWithEmailPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      if (_auth.currentUser?.isAnonymous != true) {
        throw Exception('Current user is not anonymous');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: email, 
        password: password
      );

      UserCredential result = await _auth.currentUser!.linkWithCredential(credential);
      
      // Update display name and user document
      await result.user?.updateDisplayName(displayName);
      await _updateUserDocument(result.user!, displayName, email);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during account linking');
    }
  }

  // Get user data from Firestore
  static Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user data');
    }
  }

  // Update user data in Firestore
  static Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Error updating user data');
    }
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument(User user, String displayName) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': displayName,
          'photoURL': user.photoURL ?? '',
          'isAnonymous': user.isAnonymous,
          'totalRewards': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _logError('Error creating user document', e);
    }
  }

  // Update user document in Firestore
  static Future<void> _updateUserDocument(User user, String displayName, String email) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'email': email,
        'displayName': displayName,
        'isAnonymous': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logError('Error updating user document', e);
    }
  }

  // Logging utility method
  static void _logError(String message, dynamic error) {
    debugPrint('$message: $error');
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many unsuccessful login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

void debugPrint(String s) {
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _user?.isAnonymous ?? false;

  AuthProvider() {
    _initAuthListener();
  }

  // Logging utility 
  void _logError(String message, dynamic error) {
    if (kDebugMode) {
      debugPrint('AuthProvider - $message: $error');
    }
    // Spare crashlytics 
    // FirebaseCrashlytics.instance.recordError(error, null, fatal: false);
  }

  void _initAuthListener() {
    AuthService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserModel();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      _userModel = await AuthService.getUserData(_user!.uid);
    } catch (e) {
      _logError('Error loading user model', e);
    }
  }

  // Sign up with email and password
  Future<bool> signUp(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.signUpWithEmailPassword(email, password, displayName);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.signInWithEmailPassword(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in guest
  Future<bool> signInAsGuest() async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.signInAnonymously();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.signOut();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Link anonymous account with email/password
  Future<bool> linkWithEmailPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.linkWithEmailPassword(email, password, displayName);
      await _loadUserModel(); 
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.updateUserData(updatedUser);
      _userModel = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    await _loadUserModel();
  }

  // Add rewards
  void addRewards(int amount) {
    if (_userModel != null) {
      _userModel = _userModel!.copyWith(
        totalRewards: _userModel!.totalRewards + amount,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      
      // Update in Firestore
      AuthService.updateUserData(_userModel!);
    }
  }

  // Spend rewards
  bool spendRewards(int amount) {
    if (_userModel != null && _userModel!.totalRewards >= amount) {
      _userModel = _userModel!.copyWith(
        totalRewards: _userModel!.totalRewards - amount,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      
      // Update in Firestore
      AuthService.updateUserData(_userModel!);
      return true;
    }
    return false;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }
}