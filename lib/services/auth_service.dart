import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return await getUser(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('ログインに失敗しました: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final now = DateTime.now();
        final appUser = AppUser(
          id: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('users')
            .doc(appUser.id)
            .set(appUser.toFirestore());

        return appUser;
      }
      return null;
    } catch (e) {
      throw Exception('アカウント作成に失敗しました: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(
            user.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('プロフィールの更新に失敗しました: ${e.toString()}');
    }
  }
}
