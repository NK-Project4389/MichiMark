import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<String> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    final uid = result.user?.uid;
    if (uid == null) {
      throw Exception('Anonymous sign in failed: uid is null');
    }
    return uid;
  }

  @override
  Future<String> signInWithApple() async {
    final credential = await _buildAppleCredential();
    final result = await _auth.signInWithCredential(credential);
    final uid = result.user?.uid;
    if (uid == null) {
      throw Exception('Apple sign in failed: uid is null');
    }
    return uid;
  }

  @override
  Future<void> linkWithApple() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('linkWithApple: currentUser is null');
    }
    final credential = await _buildAppleCredential();
    await currentUser.linkWithCredential(credential);
  }

  @override
  bool get isAppleLinked {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;
    return currentUser.providerData.any((p) => p.providerId == 'apple.com');
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<OAuthCredential> _buildAppleCredential() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    return OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
