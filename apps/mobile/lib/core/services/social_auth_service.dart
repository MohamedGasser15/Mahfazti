import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
}
