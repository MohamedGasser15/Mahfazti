// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/profile/data/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    const fullName = 'Ahmed Mohamed';
    const userName = 'ahmed_dev';
    const email = 'ahmed@example.com';
    const phoneNumber = '+201234567890';
    const profileImageUrl = 'https://example.com/avatar.png';

    final completeJson = {
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };

    group('fromJson', () {
      test('should create UserProfile from complete JSON', () {
        final profile = UserProfile.fromJson(completeJson);

        expect(profile.fullName, fullName);
        expect(profile.userName, userName);
        expect(profile.email, email);
        expect(profile.phoneNumber, phoneNumber);
        expect(profile.profileImageUrl, profileImageUrl);
      });

      test('should create UserProfile when profileImageUrl is null', () {
        final json = {
          'fullName': fullName,
          'userName': userName,
          'email': email,
          'phoneNumber': phoneNumber,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.fullName, fullName);
        expect(profile.profileImageUrl, isNull);
      });

      test('should use empty string for missing fields', () {
        final json = <String, dynamic>{};

        final profile = UserProfile.fromJson(json);

        expect(profile.fullName, '');
        expect(profile.userName, '');
        expect(profile.email, '');
        expect(profile.phoneNumber, '');
        expect(profile.profileImageUrl, isNull);
      });

      test('should handle null values in JSON', () {
        final json = {
          'fullName': null,
          'userName': null,
          'email': null,
          'phoneNumber': null,
          'profileImageUrl': null,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.fullName, '');
        expect(profile.userName, '');
        expect(profile.email, '');
        expect(profile.phoneNumber, '');
        expect(profile.profileImageUrl, isNull);
      });

      test('should handle empty strings gracefully', () {
        final json = {
          'fullName': '',
          'userName': '',
          'email': '',
          'phoneNumber': '',
          'profileImageUrl': '',
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.fullName, '');
        expect(profile.userName, '');
        expect(profile.email, '');
        expect(profile.phoneNumber, '');
        expect(profile.profileImageUrl, '');
      });
    });

    group('toJson', () {
      test('should return correct JSON map', () {
        final profile = UserProfile(
          fullName: fullName,
          userName: userName,
          email: email,
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl,
        );

        final json = profile.toJson();

        expect(json['fullName'], fullName);
        expect(json['userName'], userName);
        expect(json['email'], email);
        expect(json['phoneNumber'], phoneNumber);
        expect(json['profileImageUrl'], profileImageUrl);
      });

      test('should include null profileImageUrl in JSON map', () {
        final profile = UserProfile(
          fullName: fullName,
          userName: userName,
          email: email,
          phoneNumber: phoneNumber,
        );

        final json = profile.toJson();

        expect(json['profileImageUrl'], isNull);
      });
    });

    group('round-trip fromJson -> toJson', () {
      test('should preserve all fields through serialization', () {
        final profile = UserProfile.fromJson(completeJson);
        final json = profile.toJson();

        expect(json['fullName'], fullName);
        expect(json['userName'], userName);
        expect(json['email'], email);
        expect(json['phoneNumber'], phoneNumber);
        expect(json['profileImageUrl'], profileImageUrl);
      });
    });
  });
}
