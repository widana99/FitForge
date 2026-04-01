import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);

    // Create user document in Firestore
    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());

    return credential;
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update last active
    await _firestore.collection('users').doc(credential.user!.uid).update({
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Check if user exists in Firestore, create if not
    final doc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    if (!doc.exists) {
      final user = UserModel(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? '',
        email: userCredential.user!.email ?? '',
        avatarUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());
    } else {
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastActiveAt': FieldValue.serverTimestamp()},
      );
    }

    return userCredential;
  }

  // Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).delete();
    }
    await _auth.currentUser?.delete();
  }
}
