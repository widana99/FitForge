import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isProfileComplete =>
      _userModel?.workoutGoal != null && _userModel?.trainingLevel != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _userModel = await _firestoreService.getUser(user.uid);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    }
    _setLoading(false);
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    _setLoading(true);
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    }
    _setLoading(false);
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      _error = null;
    } catch (e) {
      _error = 'Gagal masuk dengan Google. Silakan coba lagi.';
    }
    _setLoading(false);
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    }
    _setLoading(false);
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_firebaseUser == null) return;
    _setLoading(true);
    try {
      await _firestoreService.updateUser(_firebaseUser!.uid, data);
      _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
      _error = null;
    } catch (e) {
      _error = 'Gagal memperbarui profil.';
    }
    _setLoading(false);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    _firebaseUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
