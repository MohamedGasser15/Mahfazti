import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  static const String _facebookAppId = '634439152779087';
  static const String _callbackScheme = 'mahfazti';
  static const String _redirectUri =
      'https://mahfazati.runasp.net/api/auth/facebook-callback';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: !kIsWeb && Platform.isIOS
        ? '45964007233-vr2d10oiv0454k0kku15mfjdnnd9dqan.apps.googleusercontent.com'
        : null,
    serverClientId:
        '45964007233-3pn2i0h0mt71f51jj2i07r6a0lidoo00.apps.googleusercontent.com',
  );

  Future<Map<String, String?>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return {'error': 'User cancelled Google sign in'};

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        return {'error': 'Failed to get Google ID token'};
      }

      return {'idToken': auth.idToken};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  /// Facebook Login using standard Web OAuth 2.0 (ASWebAuthenticationSession on iOS / CustomTabs on Android)
  /// without requiring any native Facebook SDK.
  Future<Map<String, String?>> signInWithFacebook() async {
    try {
      final authUrl = Uri.https('www.facebook.com', '/v19.0/dialog/oauth', {
        'client_id': _facebookAppId,
        'redirect_uri': _redirectUri,
        'scope': 'email,public_profile',
        'response_type': 'token',
        'display': 'touch',
      });

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: _callbackScheme,
      );

      // Facebook returns token in fragment: mahfazti://oauth-callback#access_token=...&...
      String? accessToken;
      final uri = Uri.parse(result);
      if (uri.hasFragment && uri.fragment.isNotEmpty) {
        final fragmentParams = Uri.splitQueryString(uri.fragment);
        accessToken = fragmentParams['access_token'];
      } else if (uri.queryParameters.containsKey('access_token')) {
        accessToken = uri.queryParameters['access_token'];
      }

      if (accessToken == null || accessToken.isEmpty) {
        return {'error': 'No access token returned from Facebook'};
      }

      // Fetch basic user profile info from Graph API
      String? email;
      String? name;
      try {
        final client = HttpClient();
        final request = await client.getUrl(
          Uri.https('graph.facebook.com', '/me', {
            'fields': 'id,name,email',
            'access_token': accessToken,
          }),
        );
        final profileResponse = await request.close();
        if (profileResponse.statusCode == 200) {
          final body = await profileResponse.transform(utf8.decoder).join();
          final data = jsonDecode(body) as Map<String, dynamic>;
          email = data['email']?.toString();
          name = data['name']?.toString();
        }
      } catch (_) {}

      return {'accessToken': accessToken, 'email': email, 'displayName': name};
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('CANCELED') || errorStr.contains('canceled')) {
        return {'error': 'User cancelled Facebook sign in'};
      }
      return {'error': errorStr};
    }
  }

  Future<void> signOutFacebook() async {
    // Web OAuth sessions don't maintain local SDK tokens
  }
}
