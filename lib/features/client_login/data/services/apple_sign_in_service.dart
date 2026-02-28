import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthResult {
  final String identityToken; // Apple JWT
  final String authorizationCode;
  final String? email; // only first time usually
  final String? fullName; // only first time usually
  final String? userIdentifier;

  AppleAuthResult({
    required this.identityToken,
    required this.authorizationCode,
    this.email,
    this.fullName,
    this.userIdentifier,
  });
}

class AppleSignInService {
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => charset[rand.nextInt(charset.length)])
        .join();
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<AppleAuthResult> signIn() async {
    final isAvailable = await SignInWithApple.isAvailable();
    if (!isAvailable) {
      throw Exception("Sign in with Apple not available on this device.");
    }

    // Nonce for backend validation (recommended)
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final identityToken = credential.identityToken;
    final authorizationCode = credential.authorizationCode;

    if (identityToken == null || identityToken.isEmpty) {
      throw Exception("Apple identityToken is null/empty");
    }
    if (authorizationCode.isEmpty) {
      throw Exception("Apple authorizationCode is empty");
    }

    final fullName = [
      credential.givenName,
      credential.familyName,
    ].where((e) => (e ?? '').trim().isNotEmpty).join(' ').trim();

    return AppleAuthResult(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      email: credential.email,
      fullName: fullName.isEmpty ? null : fullName,
      userIdentifier: credential.userIdentifier,
    );
  }
}
