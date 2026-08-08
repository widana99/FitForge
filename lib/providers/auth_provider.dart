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
  List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Selamat Datang!',
      'body': 'Mulai harimu dengan latihan yang menyegarkan.',
      'time': 'Sekarang',
      'isRead': false,
      'type': 'system'
    },
    {
      'id': '2',
      'title': 'Tips Latihan',
      'body': 'Jangan lupa lakukan pemanasan sebelum memulai.',
      'time': '5 menit lalu',
      'isRead': false,
      'type': 'tips'
    },
  ];

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n['isRead']).length;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isProfileComplete =>
      _userModel?.dateOfBirth != null &&
      _userModel?.workoutGoal != null &&
      _userModel?.trainingLevel != null;

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
      debugPrint('FirebaseAuthException during signIn: ${e.code} - ${e.message}');
      _error = _getAuthErrorMessage(e.code);
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException during signIn: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        _error = 'Akses Firestore ditolak. Periksa Rules di Firebase Console.';
      } else {
        _error = 'Kesalahan database (${e.code}): ${e.message}';
      }
    } catch (e) {
      debugPrint('Unknown error during signIn: $e');
      _error = 'Terjadi kesalahan: ${e.toString()}';
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
      debugPrint('FirebaseAuthException during signUp: ${e.code} - ${e.message}');
      _error = _getAuthErrorMessage(e.code);
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException during signUp: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        _error = 'Akses Firestore ditolak. Periksa Security Rules di Firebase Console.';
      } else {
        _error = 'Kesalahan database (${e.code}): ${e.message}';
      }
    } catch (e) {
      debugPrint('Unknown error during signUp: $e');
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }
    _setLoading(false);
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signInWithGoogle();
      _error = null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In FirebaseAuthException: ${e.code} - ${e.message}');
      _error = _getAuthErrorMessage(e.code);
    } on FirebaseException catch (e) {
      debugPrint('Google Sign-In FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        _error = 'Akses Firestore ditolak. Periksa Security Rules di Firebase Console.';
      } else {
        _error = 'Kesalahan database (${e.code}): ${e.message}';
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      _error = 'Gagal masuk dengan Google: ${e.toString()}';
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

  Future<void> refreshUser() async {
    if (_firebaseUser == null) return;
    try {
      _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
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

  void markNotificationsAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan oleh akun lain.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Metode login/daftar ini belum diaktifkan di Firebase Console.';
      case 'network-request-failed':
        return 'Gagal terhubung ke jaringan/internet.';
      default:
        return 'Terjadi kesalahan ($code). Silakan coba lagi.';
    }
  }
}
