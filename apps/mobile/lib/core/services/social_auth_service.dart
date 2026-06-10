import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '342149506296-3hd76r4tbhk0385lmmu50bivnh4u8dc2.apps.googleusercontent.com',
  );

  Future<Map<String, String?>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return {'error': 'User cancelled Google sign in'};

      final GoogleSignInAuthentication auth =
          await account.authentication;

      if (auth.idToken == null) {
        return {'error': 'Failed to get Google ID token'};
      }

      return {
        'idToken': auth.idToken,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  Future<Map<String, String?>> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (credential.identityToken == null) {
        return {'error': 'Failed to get Apple identity token'};
      }

      await SharedPrefs.setSecureString('apple_nonce', rawNonce);

      return {
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
        'email': credential.email,
        'displayName':
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, String?>> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status != LoginStatus.success) {
        return {'error': 'Facebook login failed: ${result.message}'};
      }

      final AccessToken accessToken = result.accessToken!;
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'email,name',
      );

      return {
        'accessToken': accessToken.tokenString,
        'email': userData['email']?.toString(),
        'displayName': userData['name']?.toString(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
  }

  String generateNonce({int length = 32}) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = _Random();
    final result = StringBuffer();
    for (int i = 0; i < length; i++) {
      result.write(charset[random.nextInt(charset.length)]);
    }
    return result.toString();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class _Random {
  int nextInt(int max) => DateTime.now().microsecondsSinceEpoch % max;
}
